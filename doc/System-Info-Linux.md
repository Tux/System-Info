# NAME

System::Info::Linux - Object for specific Linux info.

# DESCRIPTION

## $si->prepare\_sysinfo

Use os-specific tools to find out more about the system.

## $si->prepare\_os

Use os-specific tools to find out more about the operating system.

## $si->linux\_generic

Check `/proc/cpuinfo` for these keys:

- "processor"  (count occurrence for \_\_cpu\_count)
- "model name" (part of \_\_cpu)
- "vendor\_id"  (part of \_\_cpu)
- "cpu mhz"    (part of \_\_cpu)
- "cpu cores"  (add values to add to \_\_cpu\_count)

## $si->linux\_arm

Check `/proc/cpuinfo` for these keys:

- "processor"  (count occurrence for \_\_cpu\_count)
- "Processor" (part of \_\_cpu)
- "BogoMIPS"  (part of \_\_cpu)

## $si->linux\_ppc

Check `/proc/cpuinfo` for these keys:

- "processor"  (count occurrence for \_\_cpu\_count)
- "cpu"     (part of \_\_cpu)
- "machine" (part of \_\_cpu)
- "clock"   (part of \_\_cpu)
- "detected" (alters machine if present)

## $si->linux\_sparc

Check `/proc/cpuinfo` for these keys:

- "processor"  (count occurrence for \_\_cpu\_count)
- "cpu"        (part of \_\_cpu)
- "Cpu0ClkTck" (part of \_\_cpu)

## $si->linux\_s390x

Check `/proc/cpuinfo` for these keys:

- "processor"  (count occurrence for \_\_cpu\_count)
- "Processor" (part of \_\_cpu)
- "BogoMIPS"  (part of \_\_cpu)

## $si->prepare\_proc\_cpuinfo

Read the complete `/proc/cpuinfo`.

## $si->count\_in\_cpuinfo ($regex)

Returns the number of lines $regex matches for.

## $si->count\_unique\_in\_cpuinfo ($regex)

Returns the number of lines $regex matches for.

## $si->from\_cpuinfo ($key)

Returns the first value of that key in `/proc/cpuinfo`.

# COPYRIGHT AND LICENSE

(c) 2016-2024, Abe Timmerman & H.Merijn Brand, All rights reserved.

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
