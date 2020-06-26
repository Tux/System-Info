#!/pro/bin/perl

use 5.18.2;
use warnings;

our $VERSION = "0.04 - 20200626";
our $CMD = $0 =~ s{.*/}{}r;

sub usage {
    my $err = shift and select STDERR;
    say "usage: $CMD [-d n]";
    say "   -d 500 --delay=500   Set delay between calls in ms";
    exit $err;
    } # usage

BEGIN { $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0; }
use CSV;
use LWP;
use LWP::UserAgent;
use WWW::Mechanize;
use HTML::TreeBuilder;
use Text::Wrap;
use Time::HiRes  qw( usleep);
use Getopt::Long qw(:config bundling);
GetOptions (
    "help|?"		=> sub { usage (0); },
    "V|version"		=> sub { say "$CMD [$VERSION]"; exit 0; },

    "d|delay=i"		=> \(my $delay = 500),

    "v|verbose:2"	=> \(my $opt_v = 1),
    ) or usage (1);

$| = 1;
my $ua = LWP::UserAgent->new;
$ua->agent ("Opera/11.10");

sub page {
    my ($url, $tag, @options) = @_;
    $opt_v > 4 and say "Fetch $url";
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
{   my @dw = page ("https://distrowatch.org/table.php",
		   "select", name => "distribution") or exit;
    my %os;
    foreach my $s (@dw) {
	$os{$_->attr ("value")}++ for $s->look_down (_tag => "option");
	}
    @dist = sort grep m/\S/ => keys %os;
    }
#say "@dist";
@dist or die "Cannot get list of recorded distributions\n";
$opt_v and say "Fetch info for ", scalar @dist, " distributions";

my %n;
my @csv = ([ "dist name", "dist version ", "release date", "perl version" ]);
foreach my $dist (@dist) {
    if ($opt_v) {
	print $opt_v > 1 ? "$dist ...\n" : ".";
	}
    usleep ($delay * 1000);
    my @tbl = page ("https://distrowatch.org/table.php?distribution=$dist", "table");

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

    for (0 .. $#vsn) {
	push @csv, [ $dist, $vsn[$_], $rdt[$_], $perl[$_] ];
	push @{$n{$dist}}, [ $vsn[$_], $perl[$_] ];
	}
    }
$opt_v == 1 and say "";

csv (in => \@csv, out => "dist-perl.csv");

open my $gh, "-|", "git", "show", "HEAD:sandbox/dist-perl.csv";
my %o;
my $ao = csv (
    in      => $gh,
    headers => [qw( dist version date perl )],
    on_in   => sub {
	$_{dist} =~ m/dist.name/i or
	    push @{$o{$_{dist}}}, [ $_{version}, $_{perl} ];
	},
    );
close $gh;

my %d;
foreach my $dn (sort keys %n) {
    $dn =~ m/dist.name/i and next;
    unless (exists $o{$dn}) {
	$d{new}{$dn}++;
	next;
	}
    my $n = $n{$dn};
    my $o = delete $o{$dn};
    if ($n->[0][0] ne $o->[0][0] or $n->[0][1] ne $o->[0][1]) {
	$d{upd}{$dn}++;
	next;
	}
    }
$d{old}{$_}++ for keys %o;

sub modline {
    my ($tag, $dnr) = @_;
    my $dst = join ", " => sort keys %$dnr;
    wrap "\x{2022} ", "  ", $tag . ($dst || "-");
    } # modline

binmode STDOUT, ":encoding(utf-8)";
$Text::Wrap::columns = 79;
say "Update distro list\n";
say modline "Added   ", $d{new};
say modline "Removed ", $d{old};
say modline "Updated ", $d{upd};
__END__
SUSE distributions (SLES)

Version Released    EOL         Linux kernel version

S.u.S.E Linux (Slackware-based)
 3/94   1994-03-29  ????        1.0
 7/94   1994-07     ????        1.0.9
11/94   1994-11     ????        1.1.62
 4/95   1995-04     ????        1.2.9
 8/95   1995-08     ????        1.1.12
11/95   1995-11     ????        1.2.13

S.u.S.E Linux (jurix-based)
4.2     1996-05     ????        2.0.0
4.3     1996-09     ????        2.0.18
4.4     1997-05     ????        2.0.23(25?)
4.4.1   ????        ????        2.0.28
5.0     1997-07     ????        2.0.30
5.1     1997-10     ????        2.0.32
5.2     1998-03-23  2000        2.0.33
5.3     1998-09-10  2000        2.0.35

SuSE Linux
6.0     1998-12-21  2000        2.0.36
6.1     1999-04-07  2001        2.2.6
6.2     1999-08-12  2001        2.2.10
6.3     1999-11-25  2001-12-10  2.2.13
6.4     2000-03-09  2002-06-17  2.2.14
7.0     2000-09-27  2002-11-04  2.2.16
7.1     2001-04-21  2003-05-16  2.2.18 / 2.4.0
7.2     2001-06-15  2003-10-01  2.2.19 / 2.4.4
7.3     2001-10-13  2003-12-15  2.4.9
8.0     2002-04-22  2004-06-30  2.4.18
8.1     2002-09-30  2005-01-31  2.4.19
8.2     2003-04-07  2005-07-14  2.4.20

SUSE Linux Enterprise
 9.0    2003-10-15  2005-12-15  2.4.21 / 2.6.1
 9.1    2004-04-23  2006-06-30  2.6.4
 9.2    2004-10-25  2006-10-31  2.6.8
 9.3    2005-04-16  2007-04-30  2.6.11
10.0    2006-07-17  2007-12-31  2.6.16
10.1    2007-06-18  2008-11-30  2.6.16.46
10.2    2008-05-19  2010-04-11  2.6.16.60
10.3    2009-10-12  2011-10-11  2.6.16.60
10.4    2011-04-12  2013-07-31  2.6.16.60
11.0    2009-03-24  2010-12-31  2.6.27
11.1    2010-06-02  2012-08-31  2.6.32
11.2    2012-02-29  2014-01-31  3.0.13
11.3    2013-07-01  2016-01-31  3.0.76
11.4    2015-10-13  2019-03-31  3.0.101
12.0    2014-10-10  2016-06-30  3.12
12.1    2015-12-22  2017-05-31  3.12
12.2    2016-11-08  TBD         4.4
