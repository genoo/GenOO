GenOO: A Modern Perl Framework for High Throughput Sequencing analysis
==========================================================================

Summary
--------------
GenOO [jee-noo] is an open-source; object-oriented Perl framework specifically developed for the design of High Throughput Sequencing (HTS) analysis tools. The primary aim of GenOO is to make simple HTS analyses easy and complicated analyses possible. GenOO models biological entities into Perl objects and provides relevant attributes and methods that allow for the manipulation of high throughput sequencing data. Using GenOO as a core development module reduces the overhead and complexity of managing the data and the biological entities at hand. GenOO has been designed to be flexible, easily extendable with modular structure and minimal requirements for external tools and libraries. 

Focus
--------------
* Organize **biological** entities as perl objects (genomic regions, genes, transcripts, introns/exons, etc)
* Organize **sequencing** entities as perl objects/attributes (sequencing reads, alignments, etc)
* Make I/O from widely used **file** formats easy (SAM, BED, FASTA, FASTQ)
* Be **consistent** and easily **extendable**

We want to keep this framework focused on the real issues found in sequencing analyses and balance being easily extendable with being focused and efficient.

Installation
--------------
* **Using CPAN** - Easier
  1. If you have cpanm installed. `cpanm GenOO`.
  2. If you do not have cpanm. See [here](http://www.cpan.org/modules/INSTALL.html).
* **Using Git** - Preferred so you may contribute
  1. Install git ([directions](http://git-scm.com/downloads)).
  2. Install GenOO dependencies (listed below) from CPAN. [How to install CPAN modules](http://www.cpan.org/modules/INSTALL.html).
  3. Clone the GenOO repository on your machine
     `git clone https://github.com/genoo/GenOO.git`.
  4. To verify that everything works 
     `cd path/to/genoo/clone/; prove -l t/*.t;`.
  5. In the beginning of your perl script write the following
     `use lib 'path/to/genoo/clone/lib/'`.
  6. You are done! Happy coding!

Dependencies (maybe not exhaustive)
--------------
* Moose
* MooseX::AbstractFactory
* MooseX::MarkAsMethods
* DBIx::Class
* PerlIO::gzip
* namespace::autoclean
* Test::Most
* Test::Class
* Test::Exception
* Modern::Perl

Important Notes
--------------
* Backwards compatibility is particularly important and GenOO will attempt to be as backwards compatible as possible. However we all know that bugs exist and things might change. If a change breaks backwards compatibility and particularly if it breaks the test suite it **must** be logged in the changelog file. This will help users track important changes and will make updates much more safe.

State
--------------
The framework is under development and functionality is added regularly.
The core of the framework is considered stable.

Copyright
--------------
Copyright (c) 2013 Emmanouil "Manolis" Maragkakis and Panagiotis Alexiou.

License
--------------
This library is free software and may be distributed under the same terms as perl itself.

This library is distributed in the hope that it will be useful, but **WITHOUT ANY WARRANTY**; without even the implied warranty of merchantability or fitness for a particular purpose.