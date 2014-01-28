- [Recipe 1 - Get reads overlapping with coding transcripts](#recipe-1---get-reads-overlapping-with-coding-transcripts)
- [Recipe 2 - Transcript expression calculation with RPKM normalization](#recipe-2---transcript-expression-calculation-with-rpkm-normalization)
- [Recipe 3 - Pairwise 5' - 5' distances between reads](#recipe-3---pairwise-5'---5'-distances-between-reads)
- [Recipe 4 - Calculate transcript expression based only on the exonic regions.](#recipe-4---calculate-transcript-expression-based-only-on-the-exonic-regions)

# Recipe 1 - Get reads overlapping with coding transcripts

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

# Recipe 2 - Transcript expression calculation with RPKM normalization
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

# Recipe 3 - Pairwise 5' - 5' distances between reads
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

# Recipe 4 - Calculate transcript expression based only on the exonic regions.

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
