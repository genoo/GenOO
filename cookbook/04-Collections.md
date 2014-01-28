- [Description](#description)
- [Details](#details)
	- [DoubleHashArray engine](#doublehasharray-engine)
	- [DBIC engine](#dbic-engine)
- [Examples](#examples)
	- [Creating collections](#creating-collections)
	- [Using collections](#using-collections)

# Description
As mentioned earlier, the backbone of GenOO is the `Region` role which corresponds to an area on a reference sequence. It requires other classes that consume it, to implement specific attributes such as the `strand`, `rname` (reference name), `start`, `stop` and `copy_number`. Provided these attributes are implemented, `Region` gives advanced methods such as the distance from another region for free. This role is consumed by several other classes within the framework and provides common grounds for code integration.

Importantly, in High Throughput Sequencing analysis, it is common that users need to perform operations on **sets** of regions. For example, one might want to count the number of genome aligned sequencing reads that overlap with a specific gene transcript. 

```
Reads:                             - - -- -      - - -- ---- -- --             --- - --
Transcript:                                   <---------------------->
Required reads:                                  - - -- ---- -- --

Genome:          1000 nts  ...--------------------------------------------------------------...  10000 nts
```

In GenOO these **sets** of regions are supported via the `RegionCollection` role which as its name suggests, is simply a **set**/**collection** of objects that consume the `Region` role. 

# Details
## DoubleHashArray engine
Range queries typically required in a High Throughput analysis can be computationally demanding, if implemented with a brute force approach. In GenOO, we have implemented a collection engine that supports such queries and is explicitly named `DoubleHashArray` after the data structure that it uses. This structure tackles the computational problem by storing data in a two dimensional hash using `strand` as a primary key and `rname` as the secondary key. Each such key pair points to a sorted array of `Region` objects that lie in that particular strand and rname. The array is sorted by ascending `start` values of the included regions. When the query is performed the two keys are used to rapidly locate the array with all the regions on that specific strand and rname. In principle, this step corresponds to partition pruning performed by database engines (e.g. MySQL). Following this step, a binary search algorithm is used to locate the regions of the array that satisfy the given positional criteria. This technique reduces computational complexity and allows for the rapid extraction of the result. 

## DBIC engine
Although `DoubleHashArray` can be quite fast, it suffers from scalability issues as all the `Region` objects are stored in memory, and can only be used for relatively small data sets, and mostly for prototyping and draft solutions. Luckily, we have also implemented a pure database oriented `RegionCollection` engine which is named DBIC (after DBIx::Class). Currently, the implemented classes support database tables with the following columns: `strand`, `rname`, `start`, `stop`, `copy_number`, `sequence`, `cigar`, `mdz`, `number_of_best_hits` but the user can extend them to support any table schema provided that it supports all columns/attributes defined in `Region`. The GenOO DBIC class is based on [DBIx::Class](http://search.cpan.org/~ribasushi/DBIx-Class-0.08250/lib/DBIx/Class/Manual/DocMap.pod) and supports most major databases such as SQLite, MySQL, PostgreSQL and Oracle.


# Examples
## Creating collections
```perl
# From a BED file
my $collection = GenOO::RegionCollection::Factory->create('BED', {
    file => 'sample.bed'
})->read_collection;
```

```perl
# From an SQLite database file
my $collection = GenOO::RegionCollection::Factory->create('DBIC', {
    dsn         => 'dbi:SQLite:database=t/sample_data/sample.alignments.sqlite.db',
    table       => 'test_table',
})->read_collection;
```

```perl
# From a MySQL database
my $collection = GenOO::RegionCollection::Factory->create('DBIC', {
    dsn         => 'dbi:mysql:database=test_db',
    table       => 'test_table',
    user        => 'user',
    password    => 'pass'
})->read_collection;

```

## Using collections
```perl
# Get the records (these are regions themselves) that overlap with another region
my @overlapping_records = $collection->records_overlapping_region(
    1, 'chrX', 10000339, 20000000
); # arguments are strand, rname, start, stop
```

```perl
# Get the total number of records (these are regions themselves) that overlap with another region
my $total_overlapping_records = $collection->total_copy_number_for_records_contained_in_region(
    1, 'chrX', 10000339, 20000000
);
```

```perl
# Loop on the records (these are regions themselves) that overlap with another region
$collection->foreach_overlapping_record_do(1, 'chrX', 10000339, 20000000, sub {
    my ($overlapping_record) = @_;
    
    print $overlapping_record->location."\n"; # eg. 1:chrX:10000349-10000549
    # more code
});
```
