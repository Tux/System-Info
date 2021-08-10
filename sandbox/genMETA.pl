#!/pro/bin/perl

use strict;
use warnings;

use Getopt::Long qw(:config bundling nopermute);
my $check = 0;
my $opt_v = 0;
GetOptions (
    "c|check"		=> \$check,
    "v|verbose:1"	=> \$opt_v,
    ) or die "usage: $0 [--check]\n";

use lib "sandbox";
use genMETA;
my $meta = genMETA->new (
    from    => "lib/System/Info.pm",
    verbose => $opt_v,
    );

$meta->from_data (<DATA>);
$meta->gen_cpanfile ();

if ($check) {
    $meta->check_encoding ();
    $meta->check_required ();
    $meta->check_minimum ([ "examples" ]);
    $meta->done_testing ();
    }
elsif ($opt_v) {
    $meta->print_yaml ();
    }
else {
    $meta->fix_meta ();
    }

__END__
--- #YAML:1.0
name:                    System-Info
version:                 VERSION
abstract:                Basic information about the system
license:                 perl
author:
    - H.Merijn Brand <h.m.brand@xs4all.nl>
    - Abe Timmerman <abeltje@cpan.org>
generated_by:            Author
distribution_type:       module
provides:
    System::Info:
        file:            lib/System/Info.pm
        version:         VERSION
    System::Info::Base:
        file:            lib/System/Info/Base.pm
        version:         0.050
    System::Info::Generic:
        file:            lib/System/Info/Generic.pm
        version:         0.050
    System::Info::AIX:
        file:            lib/System/Info/AIX.pm
        version:         0.050
    System::Info::BSD:
        file:            lib/System/Info/BSD.pm
        version:         0.051
    System::Info::Cygwin:
        file:            lib/System/Info/Cygwin.pm
        version:         0.050
    System::Info::Darwin:
        file:            lib/System/Info/Darwin.pm
        version:         0.055
    System::Info::Haiku:
        file:            lib/System/Info/Haiku.pm
        version:         0.050
    System::Info::HPUX:
        file:            lib/System/Info/HPUX.pm
        version:         0.051
    System::Info::Irix:
        file:            lib/System/Info/Irix.pm
        version:         0.050
    System::Info::Linux:
        file:            lib/System/Info/Linux.pm
        version:         0.052
    System::Info::Solaris:
        file:            lib/System/Info/Solaris.pm
        version:         0.050
    System::Info::VMS:
        file:            lib/System/Info/VMS.pm
        version:         0.050
    System::Info::Windows:
        file:            lib/System/Info/Windows.pm
        version:         0.051
requires:
    perl:                5.008003
    POSIX:               0
configure_requires:
    ExtUtils::MakeMaker: 0
build_requires:
    perl:                5.008
test_requires:
    Test::More:          0.88
    Test::Warnings:      0
test_recommends:
    Test::More:          1.302186
resources:
    license:             http://dev.perl.org/licenses/
    repository:          https://github.com/Tux/System-Info
    bugtracker:          https://github.com/Tux/System-Info/issues
    IRC:                 irc://irc.perl.org/#perl-qa
meta-spec:
    version:             1.4
    url:                 http://module-build.sourceforge.net/META-spec-v1.4.html
