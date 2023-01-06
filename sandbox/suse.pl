#!/pro/bin/perl

use 5.018002;
use warnings;

use Spreadsheet::Read;

my $ss = Spreadsheet::Read->new ("OpenSUSE-perl.ods")->sheet (1);

foreach my $r (1 .. $ss->maxrow) {
    my ($version, $name, $date, $perl) = map { $_ // "" } $ss->row ($r);
    $version && $perl or next;

    $date =~ s/\.//;

    say "  { os_name => '$name',";
    say "    os_version => '$version',";
    say "    os_release => '$date',";
    say "    perl_version => '$perl',";
    say "    },";
    }
