# NAME

System::Info - Factory for system specific information objects

# SYNOPSIS

    use System::Info;

    my $si = System::Info->new;

    printf "Hostname:              %s\n", $si->host;
    printf "Number of CPU's:       %s\n", $si->ncpu;
    printf "Processor type:        %s\n", $si->cpu_type; # short
    printf "Processor description: %s\n", $si->cpu;      # long
    printf "OS and version:        %s\n", $si->os;

or

    use System::Info qw( sysinfo );
    printf "[%s]\n", sysinfo ();

or

    $ perl -MSystem::Info=si_uname -le print+si_uname

# DESCRIPTION

System::Info tries to present system-related information, like number of CPU's,
architecture, OS and release related information in a system-independent way.
This releases the user of this module of the need to know if the information
comes from Windows, Linux, HP-UX, AIX, Solaris, Irix, or VMS, and if the
architecture is i386, x64, pa-risc2, or arm.

# METHODS

## System::Info->new

Factory method, with fallback to the information in `POSIX::uname ()`.

## sysinfo

`sysinfo` returns a string with `host`, `os` and `cpu_type`.

## sysinfo\_hash

`sysinfo_hash` returns a hash reference with basic system information, like:

    { cpu       => 'Intel(R) Core(TM) i7-6820HQ CPU @ 2.70GHz (GenuineIntel 2700MHz)',
      cpu_count => '1 [8 cores]',
      cpu_cores => 8,
      cpu_type  => 'x86_64',
      distro    => 'openSUSE Tumbleweed 20171030',
      hostname  => 'foobar',
      os        => 'linux - 4.13.10-1-default [openSUSE Tumbleweed 20171030]',
      osname    => 'Linux',
      osvers    => '4.13.10-1-default'
      }

The `cpu_cores` count refers to logical cores. On MacOS there is also a
`physical_cores` count, which will be the same as `cpu_cores` for Apple Silicon,
but not for an Intel Mac with SMT enabled:

    { cpu            => 'Quad-Core Intel Core i7 (2 GHz)',
      cpu_count      => '1 [4 cores]',
      cpu_cores      => '8',
      physical_cores => '4',
      cpu_type       => 'x86_64',
      distro         => 'Darwin 11.7.10',
      hostname       => '192.168.1.6',
      os             => 'darwin - 20.6.0 (Mac OS X - macOS 11.7.10 (20G1427))',
      osname         => 'Darwin',
      osvers         => '11.7.10'
      }

## si\_uname (@args)

This class gathers most of the `uname(1)` info, make a comparable
version. Takes almost the same arguments:

    a for all (can be omitted)
    n for nodename
    s for os name and version
    m for cpu name
    c for cpu count
    p for cpu_type

# SEE ALSO

There are more modules that provide system and/or architectural information.

Where System::Info aims at returning the information that is useful for
bug reports, some other modules focus on a single aspect (possibly with
way more variables and methods than System::Info does supports), or are
limited to use on a specific architecture, like Windows or Linux.

Here are some of the alternatives and how to replace that code with what
System::Info offers. Not all returned values will be exactly the same.

## Sys::Hostname

    use Sys::Hostname;
    say "Hostname: ", hostname;

    ->

    use System::Info;
    my $si = System::Info->new;
    say "Hostname: ", $si->host;

Sys::Hostname is a CORE module, and will always be available.

## Unix::Processors

    use Unix::Processors;
    my $up = Unix::Processors->new;
    say "CPU type : ", $up->processors->[0]->type; # Intel(R) Core(TM) i7-6820HQ CPU @ 2.70GHz
    say "CPU count: ", $up->max_physical;          # 4
    say "CPU cores: ", $up->max_online;            # 8
    say "CPU speed: ", $up->max_clock;             # 2700

    ->

    use System::Info;
    my $si = System::Info->new;
    say "CPU type : ", $si->cpu;
    say "CPU count: ", $si->ncpu;
    say "CPU cores: ", $si->ncore;
    say "CPU speed: ", $si->cpu =~ s{^.*\b([0-9.]+)\s*[A-Z]Hz.*}{$1}r;

The number reported by max\_physical is inaccurate for modern CPU's

## Sys::Info

Sys::Info has a somewhat rigid configuration, which causes it to fail
installation on e.g. (modern versions of) CentOS and openSUSE Tumbleweed.

It aims at returning a complete set of information, but as I cannot
install it on openSUSE Tumbleweed, I cannot test it and show the analogies.

## Sys::CPU

    use Sys::CPU;
    say "CPU type : ", Sys::CPU::cpu_type;  # Intel(R) Core(TM) i7-6820HQ CPU @ 2.70GHz
    say "CPU count: ", Sys::CPU::cpu_count; # 8
    say "CPU speed: ", Sys::CPU::cpu_clock; # 2700

    ->

    use System::Info;
    my $si = System::Info->new;
    say "CPU type : ", $si->get_cpu;         # or ->cpu
    say "CPU count: ", $si->get_core_count;  # or ->ncore
    say "CPU speed: ", $si->get_cpu =~ s{^.*\b([0-9.]+)\s*[A-Z]Hz.*}{$1}r;

The speed reported by Sys::CPU is the _current_ speed, and it will change
from call to call. YMMV.

Sys::CPU is not available on CPAN anymore, but you can still get is from
BackPAN.

## Devel::Platform::Info

[Devel::Platform::Info](https://metacpan.org/pod/Devel%3A%3APlatform%3A%3AInfo) derives information from the files `/etc/issue`,
`/etc/.issue` and the output of the commands `uname -a` (and `-m`, `-o`,
`-r`, and `-s`) and `lsb_release -a`. It returns no information on CPU
type, CPU speed, or Memory.

    use Devel::Platform::Info;
    my $info = Devel::Platform::Info->new->get_info ();
    # { archname => 'x86_64',
    #   codename => 'n/a',
    #   is32bit  => 0,
    #   is64bit  => 1,
    #   kernel   => 'linux-5.17.4-1-default',
    #   kname    => 'Linux',
    #   kvers    => '5.17.4-1-default',
    #   osflag   => 'linux',
    #   oslabel  => 'openSUSE',
    #   osname   => 'GNU/Linux',
    #   osvers   => '20220426',
    #   }

    ->

    use System::Info;
    my $si = System::Info->new;
    my $info = {
       archname => $si->cpu_type,       # x86_64
       codename => undef,
       is32bit  => undef,
       is64bit  => undef,
       kernel   => "$^O-".$si->_osvers, # linux-5.17.4-1-default
       kname    => $si->_osname,        # Linux
       kvers    => $si->_osvers,        # 5.17.4-1-default
       osflag   => $^O,                 # linux
       oslabel  => $si->distro,         # openSUSE Tumbleweed 20220426
       osname   => undef,
       osvers   => $si->distro,         # openSUSE Tumbleweed 20220426
       };

## Devel::CheckOS

This one does not return the OS information as such, but features an
alternative to `$^O`.

## Sys::OsRelease

Interface to FreeDesktop.Org's os-release standard.

    use Sys::OsRealease;
    Sys::OsRelease->init;
    my $i = Sys::OsRelease->instance;
    say $i->ansi_color;                 # 0;32
    say $i->bug_report_url;             # https://bugs.opensuse.org
    say $i->cpe_name;                   # cpe:/o:opensuse:tumbleweed:20220426
    say $i->documentation_url;          # https://en.opensuse.org/Portal:Tumbleweed
    say $i->home_url;                   # https://www.opensuse.org/
    say $i->id;                         # opensuse-tumbleweed
    say $i->id_like;                    # opensuse suse
    say $i->logo;                       # distributor-logo-Tumbleweed
    say $i->name;                       # openSUSE Tumbleweed
    say $i->pretty_name;                # openSUSE Tumbleweed
    say $i->version_id;                 # 20220426

# COPYRIGHT AND LICENSE

(c) 2016-2025, Abe Timmerman & H.Merijn Brand, All rights reserved.

With contributions from Jarkko Hietaniemi, Campo Weijerman, Alan Burlison,
Allen Smith, Alain Barbet, Dominic Dunlop, Rich Rauenzahn, David Cantrell.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

See:

- [http://www.perl.com/perl/misc/Artistic.html](http://www.perl.com/perl/misc/Artistic.html)
- [http://www.gnu.org/copyleft/gpl.html](http://www.gnu.org/copyleft/gpl.html)

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
