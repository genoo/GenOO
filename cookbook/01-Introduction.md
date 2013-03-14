GenOO Cookbook
==============
Introduction
------------
GenOO is an open-source perl framework which models biological entities into Perl objects and provides methods and objects that allow for the manipulation of common file types used in sequencing such as SAM, BED, FASTQ and others. Bioinformaticians can greatly benefit by this framework since it will allow them to focus on the actual analysis required instead of coping with the boilerplate of managing the data at hand. In contrast to other existing frameworks such as BioPerl, GenOO has been designed from scratch in a modular way with minimal requirements on external libraries.

### Installation

1.  Install git for your machine (git install)[http://git-scm.com/downloads]
2.  Install GenOO dependencies (listed below) from CPAN
3.  Clone the GenOO repository on your machine
    `git clone https://github.com/genoo/GenOO.git`
4.  In the beginning of your perl script write the following
    `use lib 'path/to/genoo/clone/lib/'`
5.  You are done. No, seriously, you are done
6.  Happy coding

If you want to verify that everything works
```bash
cd path/to/genoo/clone/
prove -l t/test_all.t
```

### Dependencies

* Moose
* MooseX::AbstractFactory
* DBIx::Class
* PerlIO::gzip
* namespace::autoclean
* Test::Most
* Test::Class
* Modern::Perl

### Important Notes

Backwards compatibility is particularly important and GenOO will attempt to be as backwards compatible as possible.
However we all know that bugs exist and things might change. If a change breaks backwards compatibility
and particularly if it breaks the test suite it **must** be logged in the changelog file. 
This will help users track important changes and will make updates much more safe.

Using GenOO
-----------

### Data Input / Output

GenOO can use data from several common formats.

#### BED

The BED file format is essentially a tab delimited file with the following main columns `chromosome`, `start`, `stop`, `name`, `score`, `strand`.
To read a BED file into GenOO objects:
```perl
use GenOO::Data::File::BED;

my $file_parser = GenOO::Data::File::BED->new({
	FILE => 'input_file.bed',
});
while (my $read = $file_parser>next_record) {
	# $read is an instance of GenOO::Data::File::BED::Record
	print $read->name."\n"; # name
	print $read->strand."\n"; # strand
	
	# Since the BED::Record object consumes the Region role, we can run any method from the Region role as well.
	print $read->length."\n"; # length
	print $read->head_position."\n"; # genomic location of the 5'end of the read
	
	# code goes here
}
```
The sample code above parses a BED file and execute some code on each `$read` object

#### SAM
In a similar way one can access the SAM format that is commonly used for sequencing data.

```perl
my $inputfile = shift;
my $file_parser = GenOO::Data::File::SAM->new({
	FILE => $inputfile,
});
while (my $read = $file_parser>next_record) {
	#code goes here
}
```

the SAM record object consumes the Region role as well, but also contains SAM specific information such as:

```perl
print $read->query_seq."\n"; # prints the read sequence
print $read->number_of_suboptimal_hits."\n"; # prints the number of alignments with less than the best score
print $read->is_mapped."\n"; # prints 0 or 1 depending on if the read was mapped on the genome
```

#### FASTA/FASTQ
These formats are used to store raw sequences often together with information about the sequencing quality score. They can be read in a similar way as the other files, however their records do not consume the Region role as they do not have positional information.

```perl
my $inputfile = shift;
my $file_parser = GenOO::Data::File::FASTA->new({
	FILE => $inputfile,
});
while (my $read = $file_parser>next_record) {
	print $read->sequence."\n";
	print $read->quality."\n"; #only available for FASTQ
}
```

#### Output
Each of the Record classes for different types of input files contain the method ->to_string that outputs the record in the specific format. For example in the BED example above:

```perl
use GenOO::Data::File::BED;
my $inputfile = shift;
my $file_parser = GenOO::Data::File::BED->new({
	FILE => $inputfile,
});
while (my $read = $file_parser>next_record) {
	print $read->to_string."\n";
}
```

should output the whole file back in standard out.


#### Reading in Transcripts / Collections

Genes and gene transcripts are very important for sequencing analyses and so extra care has been taken to make their use easier. The main file type for reading in transcripts is ncbi's GTF format (gene transfer format).

Usually when dealing with transcripts/gene we want to store them in a convenient format so that we can get information from them collectively. Let's say we have a GTF formatted file containing transcripts for a species:

```perl
use GenOO::TranscriptCollection::Factory;
my $transcript_gtf_file = shift;
my $transcript_collection = GenOO::TranscriptCollection::Factory->create(
	'GTF', {
		file => $transcript_gtf_file
	}
)->read_collection;
```

We are using the TranscriptCollection::Factory object to create a collection of transcripts that can be accessed independently or together. A TranscriptCollection is a special type of RegionCollection in which each member is in fact a Transcript object. RegionCollections have useful functions such as:

```perl
$transcript_collection->longest_record_length; #returns the length of the longest record in the collection
$transcript_collection->records_count; # number of records
```

One of the most useful methods for Collections is to loop through the whole Collection and perform an action on each entry:

```perl
$transcript_collection->foreach_record_do(sub{...});
```

this method allows the user to access all entries one after the other and perform arbitrary operations on them.

## Recipes

### Recipe #1 - Get reads overlapping Coding Transcripts

Our input is two files - a BED file with aligned sequencing reads and a GTF file with transcript locations. We want to return a BED file containing only these reads overlapping at least one transcript.

```perl
use GenOO::Data::File::BED;
use GenOO::TranscriptCollection::Factory;

my $transcript_collection = GenOO::TranscriptCollection::Factory->create(
	'GTF', {
		file => 'transcripts_file.gtf'
	}
)->read_collection;

my $bed_parser = GenOO::Data::File::BED->new({
	file => 'reads.bed'
});

while (my $read = $bed_parser->next_record){
	my @overlapping_transcripts = $transcript_collection->records_overlapping_region($record->strand, $record->chr, $record->start, $record->stop);
	if (@overlapping_transcripts > 0){
		print $record->to_string."\n";
	}
}
```

Let's say that our transcript file contained coding and non-coding genes as well. Maybe we only want to get reads that overlap coding genes. We just need to check each overlapping transcript and see if it is coding or not.

```perl
while (my $read = $bed_parser->next_record){
	my @overlapping_transcripts = $transcript_collection->records_overlapping_region($record->strand, $record->chr, $record->start, $record->stop);
	foreach my $transcript (@overlapping_transcripts){
		if ($transcript->is_coding == 1){
			print $record->to_string."\n";
			last; #we don't want to print multiple times for all potentially overlapping transcripts
		}
	}
}
```

### Recipe #2 - RPKM
Our input is a database table that contains aligned reads and a GTF file with transcript locations. We want to count the number of reads that overlap each transcript and return the RPKM value of said transcript (reads per million per kb of coding region).

```perl
use GenOO::RegionCollection::Factory;
use GenOO::TranscriptCollection::Factory;

my $reads_collection = GenOO::RegionCollection::Factory->create('DBIC', {
	driver      => 'mysql',
	host        => 'localhost',
	database    => 'test_db',
	table       => 'test_table',
	user        => 'user',
	password    => 'pass'
})->read_collection;
my $total_reads = $reads_collection->total_copy_number;

my $transcript_collection = GenOO::TranscriptCollection::Factory->create(
	'GTF', {
		file => 'transcripts_file.gtf'
	}
)->read_collection;

$transcript_collection->foreach_record_do( sub {
	my ($transcript) = @_;
	my $transcript_expression = 0;
	foreach my $exon (@{$transcript->exons}) {
		$transcript_expression += $reads_collection->total_copy_number_for_records_overlapping_region($exon->strand, $exon->chromosome, $exon->start, $exon->stop); #we only want reads overlapping exons
	}
	my $rpkm = 10**9 * ($transcript_expression/$transcript->exonic_length) / $total_reads;
	print $transcript->id."\t".$rpkm."\n";
});
```

### Recipe #3 - Distances 5' - 5' between reads
We have a single reads track and we want to count pairwise 5'-5' distances for all overlapping reads. Note that the 5' end of a read can be the “start" or the “stop" of the read depending on strand. We'll use a BED file for input.

```perl
use GenOO::RegionCollection::Factory;

my $reads_collection = GenOO::RegionCollection::Factory->create('BED', {
	file => 'reads.bed'
});

my %counts;
$reads_collection->foreach_record_do( sub {
	my ($read) = @_;
	my @overlapping_reads = $reads_collection->records_overlapping_region($read->strand, $read->chr, $read->start, $read->stop);
	foreach my $overlapping_read (@overlapping_reads){
		if ($read == $overlapping_read){next;} #we don't want to count vs. itself
		my $distance $read->head_head_distance_from($overlapping_read);
		$counts{$distance}++;
	}
});

foreach my $distance (keys %counts){
	print $distance."\t".$counts{$distance}."\n";
}
```

Similar methods: `tail_tail_distance_from`, `head_tail_distance_from` etc.



### Recipe #4 - Calculate the transcript expression based only on the exonic regions.

```perl
use GenOO::RegionCollection::Factory;
use GenOO::TranscriptCollection::Factory;

my $reads = GenOO::RegionCollection::Factory->create('DBIC', {
	driver      => 'mysql',
	host        => 'localhost',
	database    => 'test_db',
	table       => 'test_table',
	user        => 'user',
	password    => 'pass',
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
	print $transcript->id."\t".$expr_per_nt."\n";
});
```
