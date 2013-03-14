GenOO Cookbook
Introduction
GenOO is an open-source perl framework which models biological entities into Perl objects and provides methods and objects that allow for the manipulation of common file types used in sequencing such as SAM, BED, FASTQ and others. Bioinformaticians can greatly benefit by this framework since it will allow them to focus on the actual analysis required instead of coping with the boilerplate of managing the data at hand. In contrast to other existing frameworks such as BioPerl, GenOO has been designed from scratch in a modular way with minimal requirements on external libraries.
Installation

Download the latest version of the library from <LINK>

Run tests <command>

Include in PERL5 or use in your scripts:
use lib 'path/GenOO/version/lib/';
where the path to the lib/ folder of the GenOO installation is given.
	

Each specific library used in the script has to be called as well:
use GenOO::Data::File::SAM;
Data Input / Output
GenOO can use data from several common formats.
BED
The BED file format is essentially a tab delimited file containing Chromosome, Start, Stop, Name, Score, Strand information. To read a BED file into GenOO objects:

```perl
use GenOO::Data::File::BED;
my $inputfile = shift;
my $file_parser = GenOO::Data::File::BED->new({
	FILE => $inputfile,
});
while (my $read = $file_parser>next_record) {
	#code goes here
}
```

This sample code will read a BED file and execute some code on the $read object that is of the type GenOO::Data::File::BED::Record.

Code that could be run on each record could be:

print $read->name.”\n”; #prints name
print $read->strand.”\n”; #prints strand

Since the BED::Record object consumes the Region role, we can run any method from the Region role as well.

	print $read->length.”\n”; #prints length
print $read->head_position.”\n”; #prints read 5’ end genomic location

SAM
In a similar way one can access the SAM format that is commonly used for sequencing data.

my $inputfile = shift;
my $file_parser = GenOO::Data::File::SAM->new({
FILE => $inputfile,
});
while (my $read = $file_parser>next_record) {
	#code goes here
}

the SAM record object consumes the Region role as well, but also contains SAM specific information such as:

print $read->query_seq.”\n”; # prints the read sequence
print $read->number_of_suboptimal_hits.”\n”; # prints the number of alignments with less than the best score
print $read->is_mapped.”\n”; # prints 0 or 1 depending on if the read was mapped on the genome

FASTA/FASTQ
These formats are used to store raw sequences often together with information about the sequencing quality score. They can be read in a similar way as the other files, however their records do not consume the Region role as they do not have positional information.

my $inputfile = shift;
my $file_parser = GenOO::Data::File::FASTA->new({
FILE => $inputfile,
});
while (my $read = $file_parser>next_record) {
	print $read->sequence.”\n”;
print $read->quality.”\n”; #only available for FASTQ

}
Output
Each of the Record classes for different types of input files contain the method ->to_string that outputs the record in the specific format. For example in the BED example above:

use GenOO::Data::File::BED;
my $inputfile = shift;
my $file_parser = GenOO::Data::File::BED->new({
FILE => $inputfile,
});
while (my $read = $file_parser>next_record) {
	print $read->to_string.”\n”;
}

should output the whole file back in standard out.
Reading in Transcripts / Collections

Genes and gene transcripts are very important for sequencing analyses and so extra care has been taken to make their use easier. The main file type for reading in transcripts is ncbi’s GTF format (gene transfer format).

Usually when dealing with transcripts/gene we want to store them in a convenient format so that we can get information from them collectively. Let’s say we have a GTF formatted file containing transcripts for a species:

use GenOO::TranscriptCollection::Factory;
my $transcript_gtf_file = shift;
my $transcript_collection = GenOO::TranscriptCollection::Factory->create(
	'GTF', {
		file => $transcript_gtf_file
	}
)->read_collection;

We are using the TranscriptCollection::Factory object to create a collection of transcripts that can be accessed independently or together. A TranscriptCollection is a special type of RegionCollection in which each member is in fact a Transcript object. RegionCollections have useful functions such as:

$transcript_collection->longest_record_length; #returns the length of the longest record in the collection
$transcript_collection->records_count; # number of records

One of the most useful methods for Collections is to loop through the whole Collection and perform an action on each entry:

$transcript_collection->foreach_record_do(sub{...});

this method allows the user to access all entries one after the other and perform arbitrary operations on them.


Recipe #1 - Get reads overlapping Coding Transcripts
Our input is two files - a BED file with aligned sequencing reads and a GTF file with transcript locations. We want to return a BED file containing only these reads overlapping at least one transcript.

#!/usr/bin/perl
use warnings;
use strict;
use lib '<path>/GenOO/v1.0/lib';
use GenOO::Data::File::BED;
use GenOO::TranscriptCollection::Factory;

my $bed_file = shift;
my $transcript_gtf_file = shift;

my $transcript_collection = GenOO::TranscriptCollection::Factory->create(
	'GTF', {
		file => $transcript_gtf_file
	}
)->read_collection;

my $bed_parser = GenOO::Data::File::BED->new({
	file => $bed_file
});

while (my $read = $bed_parser->next_record){
	my @overlapping_transcripts = $transcript_collection->records_overlapping_region($record->strand, $record->chr, $record->start, $record->stop);
	if (scalar(@overlapping_transcripts) > 0){
		print $record->to_string.”\n”;
	}
}

Let’s say that our transcript file contained coding and non-coding genes as well. Maybe we only want to get reads that overlap coding genes. We just need to check each overlapping transcript and see if it is coding or not.

while (my $read = $bed_parser->next_record){
	my @overlapping_transcripts = $transcript_collection->records_overlapping_region($record->strand, $record->chr, $record->start, $record->stop);
	foreach my $transcript (@overlapping_transcripts){
		if ($transcript->is_coding == 1){
print $record->to_string.”\n”;
last; #we don’t want to print multiple times for all potentially overlapping transcripts
}
	}
}

Recipe #2 - RPKM
Our input is a database table that contains aligned reads and a GTF file with transcript locations. We want to count the number of reads that overlap each transcript and return the RPKM value of said transcript (reads per million per kb of coding region).

#!/usr/bin/perl
use warnings;
use strict;
use lib '<path>/GenOO/v1.0/lib';
use GenOO::RegionCollection::Factory;
use GenOO::TranscriptCollection::Factory;

my $transcript_gtf_file = shift;

my $database = shift;
my $table = shift;
my $user = shift;
my $pass = shift;

my $reads_collection = GenOO::RegionCollection::Factory->create('DBIC', {
	driver      => 'mysql',
	host        => ‘localhost’,
	database    => $database,
	table       => $table,
	user        => $user,
	password    => $pass,
})->read_collection;
my $total_reads = $reads_collection->total_copy_number;

my $transcript_collection = GenOO::TranscriptCollection::Factory->create(
	'GTF', {
		file => $transcript_gtf_file
	}
)->read_collection;

$transcript_collection->foreach_record_do( sub {
	my ($transcript) = @_;
	my $transcript_expression = 0;
	foreach my $exon (@{$transcript->exons}) {
		$transcript_expression += $reads_collection->total_copy_number_for_records_overlapping_region($exon->strand, $exon->chromosome, $exon->start, $exon->stop); #we only want reads overlapping exons
	}
	my $rpkm = 10**9 * ($transcript_expression/$transcript->exonic_length) / $total_reads;
	print $transcript->id.”\t”.$rpkm.”\n”;
});


Recipe #3 - Distances 5’ - 5’ between reads
We have a single reads track and we want to count pairwise 5’-5’ distances for all overlapping reads. Note that the 5’ end of a read can be the “start” or the “stop” of the read depending on strand. We’ll use a BED file for input.

#!/usr/bin/perl
use warnings;
use strict;
use lib '<path>/GenOO/v1.0/lib';
use GenOO::RegionCollection::Factory;

my $bed_file = shift;

my $reads_collection = GenOO::RegionCollection::Factory->create(‘BED’, {
	file => $bed_file
});

my %counts;
$reads_collection->foreach_record_do( sub {
my ($read) = @_;
my @overlapping_reads = $reads_collection->records_overlapping_region($read->strand, $read->chr, $read->start, $read->stop);
	foreach my $overlapping_read (@overlapping_reads){
		if ($read == $overlapping_read){next;} #we don’t want to count vs. itself
		my $distance $read->head_head_distance_from($overlapping_read);
		$counts{$distance}++;
	}
});

foreach my $distance (keys %counts){
	print $distance.”\t”.$counts{$distance}.”\n”;
}

Similar methods: tail_tail_distance_from, head_tail_distance_from etc.




Calculate the transcript expression based only on the exonic regions.

use GenOO::RegionCollection::Factory;
use GenOO::TranscriptCollection::Factory;

my $reads = GenOO::RegionCollection::Factory->create('DBIC', {
  driver      => ‘mysql’,
  host        => ‘localhost’,
  database    => ‘test_db’,
  table       => ‘test_table’,
  user        => ‘user’,
  password    => ‘pass’,
})->read_collection;

my $transcripts = GenOO::TranscriptCollection::Factory->create('GTF', {
  file => $transcript_gtf_file
})->read_collection;

my $total_reads = $reads->total_copy_number;

$transcripts->foreach_record_do( sub {
  my ($transcript) = @_;
  
  my $expression = 0;
  foreach my $exon (@{$transcript->exons}) {
    $expression += $reads->total_copy_number_for_records_overlapping_region(
                     $exon->strand,
                     $exon->chromosome,
                     $exon->start,
                     $exon->stop
                   );
  }
  my $expr_per_nt = $expression / $transcript->exonic_length;
  print $transcript->id.”\t”.$expr_per_nt.”\n”;
});