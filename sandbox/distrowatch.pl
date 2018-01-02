#!/pro/bin/perl

use 5.18.2;
use warnings;

BEGIN { $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0; }
use CSV;
use LWP;
use LWP::UserAgent;
use WWW::Mechanize;
use HTML::TreeBuilder;

my $ua = LWP::UserAgent->new;
$ua->agent ("Opera/11.10");

sub page {
    my ($url, $tag, @options) = @_;
    my $rsp = $ua->request (HTTP::Request->new (GET => $url));
    unless ($rsp->is_success) {
	warn "get failed: ", $rsp->status_line, "\n";
	return;
	}
    my $tree = HTML::TreeBuilder->new;
    unless ($tree->parse_content ($rsp->content)) {
	warn "Cannot parse as HTML\n";
	return;
	}
    $tag ? $tree->look_down (_tag => $tag, @options) : $tree;
    } # page

my @dist;
{   my @dw = page ("http://distrowatch.org/table.php",
		   "select", name => "distribution") or exit;
    my %os;
    foreach my $s (@dw) {
	$os{$_->attr ("value")}++ for $s->look_down (_tag => "option");
	}
    @dist = sort grep m/\S/ => keys %os;
    }
#say "@dist";
@dist or die "Cannot get list of recorded distributions\n";

my @csv = ([ "dist name", "dist version ", "release date", "perl version" ]);
foreach my $dist (@dist) {
    my @tbl = page ("http://distrowatch.org/table.php?distribution=$dist", "table");

    # We need two tables, one with the dist release info
    #     <table>
    #      <tr>
    #        <th class="TablesInvert">Feature</th>
    #        <td class="TablesInvert">7-1708</td>
    #        <td class="TablesInvert">6.9</td>
    #        <td class="TablesInvert">5.11</td>
    #        <td class="TablesInvert">4.8</td>
    #        <td class="TablesInvert">3.9</td>
    #        <td class="TablesInvert">2.0</td>
    #      </tr>
    #      <tr>
    #        <th>Release Date</th>
    #        <td class="Date">2017-09-13</td>
    #        <td class="Date">2017-04-05</td>
    #        <td class="Date">2014-09-30</td>
    #        <td class="Date">2009-08-22</td>
    #        <td class="Date">2007-07-27</td>
    #        <td class="Date">2004-05-24</td>
    #      </tr>
    #    ...
    my @vsn;
    my @rdt;
    foreach my $t (@tbl) {
	foreach my $th ($t->look_down (_tag => "th")) {
	    $th->as_text eq "Feature" or next;
	    my @tr  = $t->look_down (_tag => "tr");
	    @vsn = map { $_->as_text } $tr[0]->look_down (_tag => "td");
	    @rdt = map { $_->as_text } $tr[1]->look_down (_tag => "td");
	    }
	}

    # And one with the perl info
    #       <tr class="Background">
    #         <th><a href="https://www.perl.org" title="Perl: Larry Wall&#39;s Practical Extraction and Reporting Language
    # ">perl</a> (<a href="http://www.cpan.org/src/5.0/perl-5.26.1.tar.gz">5.26.1</a>)</th>
    #         <td>5.16.3</td>
    #         <td>5.10.1</td>
    #         <td>5.8.8</td>
    #         <td>5.8.5</td>
    #         <td>5.8.0</td>
    #         <td>5.6.1</td>
    #       </tr>
    my @perl =
	map  { $_->as_text }
	map  { $_->look_down (_tag => "td") }
	grep { $_->look_down (_tag => "a", title => qr{^Perl:}i) }
	map  { $_->look_down (_tag => "tr") }
	@tbl or next;

    push @csv, [ $dist, $vsn[$_], $rdt[$_], $perl[$_] ] for 0 .. $#vsn;
    }

csv (in => \@csv, out => "dist-perl.csv");
