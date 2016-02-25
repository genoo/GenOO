[![Build Status](https://travis-ci.org/genoo/GenOO.svg?branch=master)](https://travis-ci.org/genoo/GenOO)
[![Coverage Status](https://coveralls.io/repos/genoo/GenOO/badge.svg?branch=master&service=github)](https://coveralls.io/github/genoo/GenOO?branch=master)

# GenOO - A Modern Perl Framework for High Throughput Sequencing analysis

## Summary

GenOO [jee-noo] is an open-source; object-oriented Perl framework specifically developed for the design of High Throughput Sequencing (HTS) analysis tools. The primary aim of GenOO is to make simple HTS analyses easy and complicated analyses possible. GenOO models biological entities into Perl objects and provides relevant attributes and methods that allow for the manipulation of high throughput sequencing data. Using GenOO as a core development module reduces the overhead and complexity of managing the data and the biological entities at hand. GenOO has been designed to be flexible, easily extendable with modular structure and minimal requirements for external tools and libraries. 

## Features

* Organize **biological** entities as perl objects (genomic regions, genes, transcripts, introns/exons, etc)
* Organize **sequencing** entities as perl objects/attributes (sequencing reads, alignments, etc)
* Make I/O from widely used **file** formats easy (SAM, BED, FASTA, FASTQ)
* Be **consistent** and easily **extendable**

We want to keep this framework focused on the real issues found in sequencing analyses and balance being easily extendable with being focused and efficient.

## Installation

`cpanm GenOO`.

## Important Notes

* We consider backwards compatibility very important so we will try to keep the API as backwards compatible as possible. If a change breaks backwards compatibility and particularly if it breaks the test suite it will be mentioned in `CHANGES.md`.

## Publication
A version of the accompanying manuscript has been deposited in [BioRxiv](http://biorxiv.org/content/early/2015/05/13/019265).

## State

The core of the framework is considered stable.

## Copyright

Copyright (c) 2013 Emmanouil "Manolis" Maragkakis and Panagiotis Alexiou.

License
--------------
This library is free software and may be distributed under the same terms as perl itself.

This library is distributed in the hope that it will be useful, but **WITHOUT ANY WARRANTY**; without even the implied warranty of merchantability or fitness for a particular purpose.
