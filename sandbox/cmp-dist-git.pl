#!/pro/bin/perl

use 5.018002;
use warnings;

use CSV;
use Text::Wrap;

my $tag = shift || "HEAD";

my %n;
csv (
    in      => "dist-perl.csv",
    out     => undef,
    bom     => 1,
    headers => [qw( dist version date perl )],
    on_in   => sub {
	$_{dist} =~ m/dist.name/i or
	    push @{$n{$_{dist}}}, [ $_{version}, $_{perl} ];
	});

open my $gh, "-|", "git", "show", "$tag:sandbox/dist-perl.csv";
my %o;
csv (
    in      => $gh,
    out     => undef,
    headers => [qw( dist version date perl )],
    on_in   => sub {
	$_{dist} =~ m/dist.name/i or
	    push @{$o{$_{dist}}}, [ $_{version}, $_{perl} ];
	},
    );
close $gh;

my %d;
foreach my $dn (sort keys %n) {
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

say "Added:   ", scalar keys %{$d{new}};
say "Removed: ", scalar keys %{$d{old}};
say "Updated: ", scalar keys %{$d{upd}};
