- [BED format](#bed-format)
	- [Parse BED file](#parse-bed-file)
	- [Create RegionCollection from BED file](#create-regioncollection-from-bed-file)

# BED format
The BED file format is essentially a tab delimited file with the following main columns `chromosome`, `start`, `stop`, `name`, `score`, `strand`.
Additional columns may also be present and are supported by GenOO but are not tested as well as the above ones.
For more information on the BED format please see http://genome.ucsc.edu/FAQ/FAQformat#format1.

## Parse BED file
To open a BED file all you have to do is instantiate a BED parser.
```perl
my $file_parser = GenOO::Data::File::BED->new(
	file => 'file.bed',
);
```
A parser can be transparently instantiated from a plain or from a Gzipped file provided it has the `.gz` file extension.
```perl
my $file_parser = GenOO::Data::File::BED->new(
	file => 'file.bed.gz',
);
```

When a BED parser is instantiated the header section (if present) is parsed first and the BED records are immediatelly available.
To loop on the records of a BED file a `while` loop is sufficient.
```perl
while (my $record = $file_parser->next_record) {
	# $record is an instance of GenOO::Data::File::BED::Record
	print $record->name."\n"; # name
	print $record->strand."\n"; # strand
}
```

Importantly, each BED record consumes the `Region` role. This gives specific attributes to each record and enables the integration with the rest of the GenOO framework.
```perl
while (my $record = $file_parser->next_record) {
	# GenOO::Data::File::BED::Record consumes Region role.
	print $record->length."\n"; # length
	print $record->head_position."\n"; # genomic location of the 5'end of the read
}
```

When using a BED file there are many cases when the `score` column actually corresponds to the number of reads/tags that map in a specific location. In these cases the `score` columns actually needs to be redirected to the `copy_number` attribute of the `Region` role. Note that by default this redirection is avoided and the `copy_number` has a default value of 1.
To enable this option in the BED parser use `redirect_score_to_copy_number` during instantiation.
```perl
my $file_parser = GenOO::Data::File::BED->new(
	file => 'file.bed',
	redirect_score_to_copy_number => 1
);
```

For example:
```perl
# Having an BED entry like
# chr1	100	200	test_record	5	+

# With the option disabled
print $record->copy_number; # prints 1

# With the option enabled
print $record->copy_number; # prints 5
```

## Create RegionCollection from BED file
When you want to perform range queries on the records of a BED file the best way to do it is to create a `RegionCollection`.
To create a `RegionCollection` from a BED file we use a factory.

```perl
# Create a BED factory
my $factory = GenOO::RegionCollection::Factory->create('BED', {
		file => 'sample.bed'
});
```
The first argument in the `create` method is the type of the factory to be created. In this case we ask for a 'BED' factory. The second argument is a hash reference that will be given as instantiation argument to the BED factory itself.

Now we have a BED factory and we want to instantiate a `RegionCollection` from the BED file. For this, we use the `read_collection` method of the factory.
```perl
my $collection = $factory->read_collection;
```

Of course usually we do not need an instance of the factory itself but we are only interested in the `RegionCollection`. In this case we obviously combine the calls above and have a more concise one.
```perl
my $collection = GenOO::RegionCollection::Factory->create('BED', {
		file => 'sample.bed'
})->read_collection;
```

If we need to redirect the `score` column to the `copy_number` attribute as mentioned earlier we can use the following code.
```perl
my $collection = GenOO::RegionCollection::Factory->create('BED', {
		file => 'sample.bed',
		redirect_score_to_copy_number => 1
})->read_collection;

```
If we want only records with specific criteria to end up in the collection we can provide a function to the factory that when applied to a record will return 1 or 0 depending on whether the record should be included or excluded from the collection respectivelly.
```perl
my $collection = GenOO::RegionCollection::Factory->create('BED', {
		file => 'sample.bed',
		filter_code => sub {
			return 1 if $_[0]->strand == 1;
			return 0;
		} # Keep only records on the "+" strand. Discard all others.
})->read_collection;
```

As mentioned earlier the `RegionCollection` can now be used for range queries and other more advanced purposes.
```perl
my @overlapping_reads = $collection->records_overlapping_region(
	$strand, # eg. 1
	$rname,  # eg. chrX
	$start,  # eg. 10000339
	$stop    # eg. 20000000
);
```