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
# chr1    100    200    test_record    5    +

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


# Working with a database
In High Throughput Sequencing it is often the case that the data need to be stored in a database instead of flat files like BED, SAM etc. For this, in GenOO we implement a pure database oriented collection engine which is named `GenOO::Data::DB::DBIC`. Currently, the implemented classes support database tables that have at least the following columns: `strand`, `rname`, `start`, `stop`, `copy_number`, `sequence`, `cigar` (the CIGAR string of the [SAM](http://samtools.sourceforge.net/SAM1.pdf) format), `mdz` (the MD:Z tag of the [SAM](http://samtools.sourceforge.net/SAM1.pdf) format), `number_of_best_hits`. We believe that this covers most uses but if not the user can extend them to support any table schema provided that it supports all columns/attributes defined in `Region`. `GenOO::Data::DB::DBIC` is based on [DBIx::Class](http://search.cpan.org/~ribasushi/DBIx-Class-0.08250/lib/DBIx/Class/Manual/DocMap.pod) which is a modern Perl module that provides an extensible and flexible object-relational mapper. DBIx::Class supports most major databases such as SQLite, MySQL, PostgreSQL and Oracle.


## Create RegionCollection from a database
Creating a `RegionCollection` from a database and performing range queries on it is as easy as any other flat file.
To create a `RegionCollection` from a database we use again a factory as previously described.

```perl
# Create a DBIC factory
my $factory = GenOO::RegionCollection::Factory->create('DBIC', {
    dsn         => 'dbi:SQLite:database=t/sample_data/sample.alignments.sqlite.db',
    table       => 'test_table'
});

```
The first argument in the `create` method is the type of the factory to be created. In this case we ask for a 'DBIC' factory. The second argument is a hash reference that will be given as instantiation argument to the DBIC factory itself. This hash contains the information on how to connect to the database.

Now we have a DBIC factory and we want to instantiate a `RegionCollection` from it. For this, we use the `read_collection` method of the factory.
```perl
my $collection = $factory->read_collection;
```

Of course usually we do not need an instance of the factory itself but we are only interested in the `RegionCollection`. In this case we obviously combine the calls above and have a more concise one.
```perl
my $collection = GenOO::RegionCollection::Factory->create('DBIC', {
    dsn         => 'dbi:SQLite:database=t/sample_data/sample.alignments.sqlite.db',
    table       => 'test_table',
})->read_collection;

my $collection_from_mysql = GenOO::RegionCollection::Factory->create('DBIC', {
    dsn         => 'dbi:mysql:database=test_db',
    table       => 'test_table',
    user        => 'user',
    password    => 'pass'
})->read_collection;

```

By default when using the above code the records that are stored in the collection are of type `GenOO::Data::DB::DBIC::Species::Schema::SampleResultBase::v1`. Most of the times, this is sufficient as this schema supports most of the most commonly needed information. However there are cases when this schema might not be sufficient and the user has tables with different columns. In these cases the following trick can be used.

1. The user must create a class similar to `GenOO::Data::DB::DBIC::Species::Schema::SampleResultBase::v1` that contains the columns he/she is interested in.
2. Specify in the collection instantiation which class should be used for the records stored in the collection

```perl
my $collection_from_mysql = GenOO::RegionCollection::Factory->create('DBIC', {
    dsn           => 'dbi:mysql:database=test_db',
    table         => 'test_table',
    records_class => 'module created by user' # eg. 'My::New::Module'
})->read_collection;
```


