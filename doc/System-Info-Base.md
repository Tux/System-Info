# NAME

System::Info::Base - Baseclass for system information.

# ATTRIBUTES

- cpu
- cpu\_type
- ncpu
- os
- host

# DESCRIPTION

## System::Info::Base->new()

Return a new instance for $^O

## $si->prepare\_sysinfo

This method should be overridden by platform specific subclasses.

The generic information is taken from `POSIX::uname()`.

- $self->\_hostname  => (POSIX::uname)\[1\]
- $self->\_os        => join " - " => (POSIX::uname)\[0,2\]
- $self->\_osname    => (POSIX::uname)\[0\]
- $self->\_osvers    => (POSIX::uname)\[2\]
- $self->\_cpu\_type  => (POSIX::uname)\[4\]
- $self->\_cpu       => (POSIX::uname)\[4\]
- $self->\_cpu\_count => ""

## $si->get\_os

Returns $self->\_os

## $si->get\_hostname

Returns $self->\_hostname

## $si->get\_cpu\_type

Returns $self->\_cpu\_type

## $si->get\_cpu

Returns $self->\_cpu

## $si->get\_cpu\_count

Returns $self->\_cpu\_count

## $si->get\_core\_count

Returns $self->get\_cpu\_count as a number

If `get_cpu_count` returns `2 [8 cores]`, `get_core_count` returns `8`

## $si->get\_dist\_name

Returns the name of the distribution.

## si\_uname (@args)

This class gathers most of the `uname(1)` info, make a comparable
version. Takes almost the same arguments:

    a for all (can be omitted)
    n for nodename
    s for os name and version
    m for cpu name
    c for cpu count
    p for cpu_type

## $si->old\_dump

Just a backward compatible way to dump the object (for test suite).

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
