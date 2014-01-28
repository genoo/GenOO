- [BED format](#bed-format)
	- [Parse BED file](#parse-bed-file)
	- [Create RegionCollection from BED file](#create-regioncollection-from-bed-file)
- [SAM format](#sam-format)
	- [Parse SAM file](#parse-sam-file)
	- [Create RegionCollection from SAM file](#create-regioncollection-from-sam-file)
- [FASTQ format](#fastq-format)
	- [Parse FASTQ file](#parse-fastq-file)
- [FASTA format](#fasta-format)
	- [Parse FASTA file](#parse-fasta-file)
- [Working with a database](#working-with-a-database)
	- [Create RegionCollection from a database](#create-regioncollection-from-a-database)

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
# Having a BED entry like
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


# SAM format
The SAM file format is a commonly used format in High Throughput Sequencing. It is essentially a tab delimited file with required and optional columns. In GenOO we asume that all required columns are present and we make no assumptions about the optional ones. If one wants to create a parser that performs operations on the optional columns she/he should create an extension module (eg. genoox_sam_bwa, genoox_sam_star). More details on extension modules can be found in the chapter 07-Plugins_And_Extensions.
For more information on the SAM format please see http://samtools.sourceforge.net/SAM1.pdf.

## Parse SAM file
To open a SAM file all you have to do is instantiate a SAM parser.
```perl
my $file_parser = GenOO::Data::File::SAM->new(
    file => 'file.sam',
);
```
A parser can be transparently instantiated from a plain or from a Gzipped file provided it has the `.gz` file extension.
```perl
my $file_parser = GenOO::Data::File::SAM->new(
    file => 'file.sam.gz',
);
```

When a SAM parser is instantiated the header section (if present) is parsed first and the SAM records are immediatelly available.
To loop on the records of a SAM file a `while` loop is sufficient.
```perl
while (my $record = $file_parser->next_record) {
    # $record is by default an instance of GenOO::Data::File::SAM::Record. See GenOO extensions on how to change this.
    print $record->cigar."\n"; # name
    print $record->flag."\n"; # flag
}
```

Importantly, each SAM record consumes the `Region` role. This gives specific attributes to each record and enables the integration with the rest of the GenOO framework.
```perl
while (my $record = $file_parser->next_record) {
    # GenOO::Data::File::SAM::Record consumes Region role.
    print $record->length."\n"; # length
    print $record->head_position."\n"; # genomic location of the 5'end of the read
}
```

## Create RegionCollection from SAM file
When you want to perform range queries on the records of a SAM file the best way to do it is to create a `RegionCollection`.
To create a `RegionCollection` from a SAM file we use a factory.

```perl
# Create a SAM factory
my $factory = GenOO::RegionCollection::Factory->create('SAM', {
    file => 'sample.sam'
});
```
The first argument in the `create` method is the type of the factory to be created. In this case we ask for a 'SAM' factory. The second argument is a hash reference that will be given as instantiation argument to the SAM factory itself.

Now we have a SAM factory and we want to instantiate a `RegionCollection` from the SAM file. For this, we use the `read_collection` method of the factory.
```perl
my $collection = $factory->read_collection;
```

Of course usually we do not need an instance of the factory itself but we are only interested in the `RegionCollection`. In this case we obviously combine the calls above and have a more concise one.
```perl
my $collection = GenOO::RegionCollection::Factory->create('SAM', {
    file => 'sample.sam'
})->read_collection;
```

By default only mapped records are inserted into the collection. If we want additional specific criteria for the records to end up in the collection we can provide a function to the factory that when applied to a record will return 1 or 0 depending on whether the record should be included or excluded from the collection respectivelly.
```perl
my $collection = GenOO::RegionCollection::Factory->create('SAM', {
    file => 'sample.sam',
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


# FASTQ format
The FASTQ file format uses four lines per sequence in order `@name`, `sequence`, `+name(optional)` and `quality`.
For more information on the FASTQ format please see http://maq.sourceforge.net/fastq.shtml.

## Parse FASTQ file
To open a FASTQ file all you have to do is instantiate a FASTQ parser.
```perl
my $file_parser = GenOO::Data::File::FASTQ->new(
    file => 'file.fastq',
);
```
A parser can be transparently instantiated from a plain or from a Gzipped file provided it has the `.gz` file extension.
```perl
my $file_parser = GenOO::Data::File::FASTQ->new(
    file => 'file.fastq.gz',
);
```

When a FASTQ parser is instantiated the FASTQ records are immediatelly available.
To loop on the records of a FASTQ file a `while` loop is sufficient.
```perl
while (my $record = $file_parser->next_record) {
    # $record is an instance of GenOO::Data::File::FASTQ::Record
    print $record->name."\n"; # name (without the @)
    print $record->sequence."\n"; # sequence
    print $record->quality."\n"; # quality
    print $file_parser->records_read_count."\n"; # number of records read up to that point
}
```


# FASTA format
The FASTA file format uses two field per sequence in order `>name` and `sequence`. The `sequence` field can span several file lines.
For more information on the FASTA format please see http://genetics.bwh.harvard.edu/pph/FASTA.html.

## Parse FASTA file
To open a FASTA file all you have to do is instantiate a FASTA parser.
```perl
my $file_parser = GenOO::Data::File::FASTA->new(
    file => 'file.fasta',
);
```
A parser can be transparently instantiated from a plain or from a Gzipped file provided it has the `.gz` file extension.
```perl
my $file_parser = GenOO::Data::File::FASTA->new(
    file => 'file.fasta.gz',
);
```

When a FASTA parser is instantiated the FASTA records are immediatelly available.
To loop on the records of a FASTA file a `while` loop is sufficient.
```perl
while (my $record = $file_parser->next_record) {
    # $record is an instance of GenOO::Data::File::FASTA::Record
    print $record->name."\n"; # name (without the >)
    print $record->sequence."\n"; # sequence
    print $file_parser->records_read_count."\n"; # number of records read up to that point
}
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

For more information read chapter 07-Plugins_And_Extensions.


