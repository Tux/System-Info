#!/pro/bin/perl

use 5.14.2;
use warnings;

our $VERSION = "0.02 - 20200102";
our $CMD = $0 =~ s{.*/}{}r;

sub usage {
    my $err = shift and select STDERR;
    say "usage: $CMD ...";
    exit $err;
    } # usage

use CSV;
use Getopt::Long qw(:config bundling);
GetOptions (
    "help|?"		=> sub { usage (0); },
    "V|version"		=> sub { say "$CMD [$VERSION]"; exit 0; },

    "v|verbose:1"	=> \(my $opt_v = 0),
    ) or usage (1);

my (%o, %d);
csv (in => "dist-perl.csv", out => undef, bom => 1, on_in => sub {
    $o{$_{"dist name"}}++ and return; # Only count most recent OS version
    $d{$_{"perl version"}}++;
    });

my (%x, %n);
foreach my $pv (keys %d) {
    $pv =~ m/^5\.(\d+)\.(\d+)/ or next;
    my ($r, $v) = ($1, $2);
    my $c = $d{$pv};
    $x{$r}{$v} = $c;
    $n{$r} += $c;
    }
foreach my $r (sort { $a <=> $b } keys %n) {
    my $s = sprintf "5.%-2s  %3d # ", $r, $n{$r};
    $s .= sprintf ".%-1d:%3d, ", $_, $x{$r}{$_} for sort { $a <=> $b } keys %{$x{$r}};
    say $s =~ s{,\s+$}{}r;
    }
