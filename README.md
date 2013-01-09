GenOO: A postmodern Perl framework for High Throughput Sequencing analysis
==========================================================================

Summary
--------------
GenOO is an Object Oriented Genomic analysis framework for Perl which is based on Moose.

The framework supports genomic and transcriptomic deep sequencing analyses.

Focus
--------------
* Organize **biological** entities as perl objects (Gene, Transcript, Region, Exon, 3'UTR etc)
* Organize **sequencing** entities as perl objects/attributes (Tag, Quality, Alignment Match/Mismatch etc)
* Make simple analyses easy, complicated analyses possible
* Make I/O from widely used **file** formats easy (SAM, BED, FASTA, FASTQ, QSeq)
* Be **consistent** and easily **extendable**

We want to keep this framework focused on the real issues found in sequencing analyses and balance being easily extendable with being focused and efficient.

State
--------------
The library is under heavy development and functionality is added on a daily basis.

Prerequisites
--------------
*Moose
*MooseX::AbstractFactory
*DBIx::Class
*PerlIO::gzip
*namespace::autoclean
*Test::Most
*Test::Class
*Modern::Perl
