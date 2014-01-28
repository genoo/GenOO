- [Basic I/O and structures](#basic-io-and-structures)
	- [BED](#bed)
	- [SAM](#sam)
	- [FASTA](#fasta)
	- [FASTQ](#fastq)
	- [Output](#output)
	- [Reading Transcripts and managing Collections](#reading-transcripts-and-managing-collections)
- [Recipes](#recipes)
	- [Recipe 1 - Get reads overlapping with coding transcripts](#recipe-1---get-reads-overlapping-with-coding-transcripts)
	- [Recipe 2 - Transcript expression calculation with RPKM normalization](#recipe-2---transcript-expression-calculation-with-rpkm-normalization)
	- [Recipe 3 - Pairwise 5' - 5' distances between reads](#recipe-3---pairwise-5'---5'-distances-between-reads)
	- [Recipe 4 - Calculate transcript expression based only on the exonic regions.](#recipe-4---calculate-transcript-expression-based-only-on-the-exonic-regions)

# Basic I/O and structures

GenOO supports I/O from several common formats used in High Throughput Sequencing analysis. The most important ones are shown below.


## BED
The BED file format is essentially a tab delimited file with the following main columns `chromosome`, `start`, `stop`, `name`, `score`, `strand`.
The following code parses a BED file and execute some code on each record in the BED file.

```perl
my $file_parser = GenOO::Data::File::BED->new(
	file => 'input_file.bed',
);
while (my $record = $file_parser->next_record) {
	# $record is an instance of GenOO::Data::File::BED::Record
	print $record->name."\n"; # name
	print $record->strand."\n"; # strand
	
	# GenOO::Data::File::BED::Record consumes Region role.
	print $record->length."\n"; # length
	print $record->head_position."\n"; # genomic location of the 5'end of the read
	
	# more code
}
```

## SAM
In a similar way one can access the [SAM](http://samtools.sourceforge.net/SAM1.pdf) format that is commonly used for sequencing data.

```perl
my $file_parser = GenOO::Data::File::SAM->new({
	FILE => 'input_file.sam', # watch out capitalization of FILE (SAM parser is not yet a Moose class)
});
while (my $record = $file_parser>next_record) {
	# $record is an instance of GenOO::Data::File::SAM::Record
	print $record->query_seq."\n"; # read sequence
	print $record->number_of_suboptimal_hits."\n"; # number of alignments with less than the best score
	print $record->is_mapped."\n"; # 1 or 0 depending on whether the read was mapped on the genome or not
	
	# GenOO::Data::File::SAM::Record consumes Region role.
	print $record->length."\n"; # length
	print $record->head_position."\n"; # genomic location of the 5'end of the read
	
	# more code
}
```

## FASTA
This format is usually used for raw sequences. A file in this format can be read in a similar way as all the other files. However its records do not consume the Region role as they do not have positional information.

```perl
my $file_parser = GenOO::Data::File::FASTA->new(
	file => 'input_file.fa',
);
while (my $record = $file_parser>next_record) {
	print $record->header."\n"; # record's header (the part after the ">")
	print $record->sequence."\n"; # record's sequence
}
```

## FASTQ
This format is usually used for raw sequences together with information about the sequencing quality score. Similar to the FASTA format its records do not consume the Region role as they do not have positional information.
```perl
my $file_parser = GenOO::Data::File::FASTQ->new(
	file => 'input_file.faq',
);
while (my $record = $file_parser>next_record) {
	print $record->header."\n"; # record's header (the part after the "@")
	print $record->sequence."\n"; # record's sequence
	print $record->quality."\n"; #only available for FASTQ
}
```

## Output
Each of the Record classes for different types of input files contain the method `to_string` that outputs the record in the specific format. For example in the BED example above the following code should output the whole file back to the original format.

```perl
my $file_parser = GenOO::Data::File::BED->new(
	file => 'input_file.bed',
);
while (my $record = $file_parser>next_record) {
	print $record->to_string."\n"; # prints the record in the BED format
}
```

## Reading Transcripts and managing Collections

Genes and gene transcripts are very important for sequencing analyses and so extra care has been taken to make their use easier. The main file type for reading in transcripts is NCBI's GTF format (Gene Transfer Format). Usually when dealing with transcripts/gene we want to store them in a convenient format so that we can get information from them collectively. Let's say we have a GTF formatted file containing transcripts for a species:

```perl
my $transcript_collection = GenOO::TranscriptCollection::Factory->create('GTF', {
	file => 'transcripts_file.gtf'
})->read_collection;
```
We are using the TranscriptCollection::Factory object to create a collection of transcripts that can be accessed independently or together. A `TranscriptCollection` is a special type of `RegionCollection` in which each member is in fact a `Transcript`. RegionCollection has useful functions such as:

```perl
$transcript_collection->longest_record_length; # the length of the longest record in the collection
$transcript_collection->records_count; # number of records
```
One of the most useful methods for collection objects is to loop through the whole collection and perform an action on each entry:

```perl
$transcript_collection->foreach_record_do(sub{
	my ($transcript) = @_;
	
	print $transcript->id."\n";
	# more code
});
```

# Recipes

## Recipe 1 - Get reads overlapping with coding transcripts

Our input is two files - a BED file with aligned sequencing reads and a GTF file with transcript locations. We want to return a BED file containing only these reads overlapping at least one transcript.

```perl
use GenOO::Data::File::BED;
use GenOO::TranscriptCollection::Factory;

my $transcript_collection = GenOO::TranscriptCollection::Factory->create('GTF', {
	file => 'transcripts_file.gtf'
})->read_collection;

my $bed_parser = GenOO::Data::File::BED->new(
	file => 'reads.bed'
);

while (my $record = $bed_parser->next_record){
	my @overlapping_transcripts = $transcript_collection->records_overlapping_region(
		$record->strand,
		$record->rname,
		$record->start,
		$record->stop
	);
	if (@overlapping_transcripts > 0){
		print $record->to_string."\n";
	}
}
```

Let's say that our transcript file contained coding and non-coding genes as well. Maybe we only want to get reads that overlap coding genes. We just need to check each overlapping transcript and see if it is coding or not.

```perl
while (my $record = $bed_parser->next_record){
	my @overlapping_transcripts = $transcript_collection->records_overlapping_region(
		$record->strand,
		$record->rname,
		$record->start,
		$record->stop
	);
	
	my @coding_overlapping_transcripts = grep {$_->is_coding == 1} @overlapping_transcripts; # coding only
	
	if (@coding_overlapping_transcripts > 0) {
		print $record->to_string."\n";
	}
}
```

## Recipe 2 - Transcript expression calculation with RPKM normalization
Our input is a database table that contains aligned RNA-Seq reads and a GTF file with transcript locations. We want to count the number of reads that overlap each transcript and return the RPKM value of said transcript (reads per million per kb of coding region).

```perl
use GenOO::RegionCollection::Factory;
use GenOO::TranscriptCollection::Factory;

my $records_collection = GenOO::RegionCollection::Factory->create('DBIC', {
	driver      => 'mysql',
	host        => 'localhost',
	database    => 'test_db',
	table       => 'test_table',
	user        => 'user',
	password    => 'pass'
})->read_collection;
my $total_reads = $records_collection->total_copy_number;

my $transcript_collection = GenOO::TranscriptCollection::Factory->create('GTF', {
	file => 'transcripts_file.gtf'
})->read_collection;

$transcript_collection->foreach_record_do( sub {
	my ($transcript) = @_;
	
	my $transcript_expression = 0;
	
	#we only want reads overlapping exons
	foreach my $exon (@{$transcript->exons}) {
		$transcript_expression += $records_collection->total_copy_number_for_records_overlapping_region(
			$exon->strand,
			$exon->chromosome,
			$exon->start,
			$exon->stop
		);
	}
	
	my $rpkm = 10**9 * ($transcript_expression/$transcript->exonic_length) / $total_reads;
	print $transcript->id."\t".$rpkm."\n";
});
```

## Recipe 3 - Pairwise 5' - 5' distances between reads
We have a single reads track and we want to count pairwise 5'-5' distances for all overlapping reads. Note that the 5' end of a read can be the “start" or the “stop" of the read depending on strand. We'll use a BED file for input.

```perl
use GenOO::RegionCollection::Factory;

my $records_collection = GenOO::RegionCollection::Factory->create('BED', {
	file => 'reads.bed'
});

my %counts;
$records_collection->foreach_record_do( sub {
	my ($record) = @_;
	
	my @overlapping_reads = $records_collection->records_overlapping_region(
		$record->strand,
		$record->rname,
		$record->start,
		$record->stop
	);
	foreach my $overlapping_read (@overlapping_reads){
		next if ($record == $overlapping_read); # skip itself
		my $distance $record->head_head_distance_from($overlapping_read); # similarly `tail_tail_distance_from`, `head_tail_distance_from`, etc
		$counts{$distance}++;
	}
});

foreach my $distance (keys %counts) {
	print $distance."\t".$counts{$distance}."\n";
}
```

## Recipe 4 - Calculate transcript expression based only on the exonic regions.

```perl
use GenOO::RegionCollection::Factory;
use GenOO::TranscriptCollection::Factory;

my $records_collection = GenOO::RegionCollection::Factory->create('DBIC', {
	driver      => 'mysql',
	host        => 'localhost',
	database    => 'test_db',
	table       => 'test_table',
	user        => 'user',
	password    => 'pass',
})->read_collection;
my $total_reads = $records_collection->total_copy_number;

my $transcripts = GenOO::TranscriptCollection::Factory->create('GTF', {
	file => $transcript_gtf_file
})->read_collection;

$transcripts->foreach_record_do( sub {
	my ($transcript) = @_;
	
	my $expression = 0;
	foreach my $exon (@{$transcript->exons}) {
		$expression += $records_collection->total_copy_number_for_records_overlapping_region(
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
