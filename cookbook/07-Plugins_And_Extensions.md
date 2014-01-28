# Introduction
In GenOO we have tried to avoid code that is unique to specific cases. For example for the SAM file parser we make no assumptions about the optional fields in the file. The reason is that these fields are free to be used in whatever way by the programs that produce the files and it would be impossible for a framework to predict and integrate every different situation of how these fields are used. Similarly, in GenOO DBIC we try to make minimal assumptions on the table schema that the user has created to store her/his sequencing reads. Of course we assume that the schema respects the fields in the `Region` role but apart from that we try to keep requirements to a minimum. Hopefully, this approach helps to have a much more flexible framewok. The disadvantage though is that the user will need to have a pretty good knowledge of the frameworks internals so she/he can create her/his own extension modules that will do the job for her/him. The purpose of this chapter in to give an overview of how this is possible.

# An extension for the SAM format
The SAM format has several optional fields/tags that each program is free to use in whatever way they like (sort of). Anyway, the important thing is that one can nor expect a program to export all the SAM fields in a specific way. For this, ideally we would need one different SAM parser for each different program (eg. STAR aligner, BWA aligner, etc). Instead GenOO gives the option to write a small class that would provide the additional functionality on top of the main GenOO SAM parser.

Here is how such a class could look like for the output SAM file of the STAR aligner.

```perl
package GenOOx::Data::File::SAMstar::Record;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Moose;
use namespace::autoclean;


#######################################################################
############################   Inheritance   ##########################
#######################################################################
extends 'GenOO::Data::File::SAM::Record';


#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub number_of_mappings {
	my ($self) = @_;
	
	return $self->tag('NH:i');
}

sub is_uniquelly_mapped {
	my ($self) = @_;
	
	return 0 if $self->is_unmapped;
	return 1 if $self->mapq == 255;
	return 0;
}

sub is_primary_alignment {
	my ($self) = @_;
	
	return 0 if $self->is_unmapped;
	return 0 if $self->flag & 256;
	return 1;
}

sub is_secondary_alignment {
	my ($self) = @_;
	
	return 0 if $self->is_unmapped;
	return 1 if $self->flag & 256;
	return 0;
}
```

Now you can use this class to override the default class for the records of the SAM aligner.
```perl
my $file_parser = GenOO::Data::File::SAM->new(
    file          => 'file.sam',
    records_class => 'GenOOx::Data::File::SAMstar::Record'
);

while (my $record = $file_parser->next_record) {
    # $record is now an instance of GenOOx::Data::File::SAMstar::Record.
    print $record->cigar."\n"; # name
    print $record->flag."\n"; # flag
    print $record->number_of_mappings."\n"; # new stuff not present by default
}
```

# An extension for GenOO DBIC
Similarly an extension module for GenOO DBIC that would support your custom table schema
```
strand,
rname,
start,
stop,
copy_number,
sequence,
query_length,
alignment_length
```

could look like this


```perl
package GenOOx::Data::DB::DBIC::Species::Schema::SampleResultBase::MyCustom;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Modern::Perl;
use Moose;
use namespace::autoclean;
use MooseX::MarkAsMethods autoclean => 1;


#######################################################################
############################   Inheritance   ##########################
#######################################################################
extends 'DBIx::Class::Core';


#######################################################################
#######################   Interface attributes   ######################
#######################################################################
# The interface attributes section provides Moose like accessors for
# the table columns. These methods basically overide those created by
# DBIx::Class. The column types are defined at the end of the class in
# the "Package Methods" section

######################
# The above ones satisfy the Region Role
has 'strand' => (
	is => 'rw',
);

has 'rname' => (
	is => 'rw',
);

has 'start' => (
	is => 'rw',
);

has 'stop' => (
	is => 'rw',
);

has 'copy_number' => (
	is => 'rw', 
);
######################

has 'sequence' => (
	is => 'rw',
);

has 'query_length' => (
	is => 'rw',
);

has 'alignment_length' => (
	is => 'rw',
);


#######################################################################
##########################   Consumed roles   #########################
#######################################################################
with 'GenOO::Region';


#######################################################################
#########################   Package Methods   #########################
#######################################################################
__PACKAGE__->table('Unknown');

__PACKAGE__->add_columns(
	'strand', {
		data_type => 'integer',
		is_nullable => 0,
		size => 1
	},
	'rname', {
		data_type => 'varchar',
		is_nullable => 0,
		size => 250
	},
	'start', {
		data_type => 'integer',
		extra => { unsigned => 1 },
		is_nullable => 0
	},
	'stop', {
		data_type => 'integer',
		extra => { unsigned => 1 },
		is_nullable => 0
	},
	'copy_number', {
		data_type => 'integer',
		default_value => 1,
		extra => { unsigned => 1 },
		is_nullable => 0,
	},
	'sequence', {
		data_type => 'varchar',
		is_nullable => 0,
		size => 250
	},
	'query_length', {
		data_type => 'integer',
		extra => { unsigned => 1 },
		is_nullable => 0
	},
	'alignment_length', {
		data_type => 'integer',
		extra => { unsigned => 1 },
		is_nullable => 0
	},
);


#######################################################################
############################   Finalize   #############################
#######################################################################
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;

```

Now you can use this class to override the default class for the records of GenOO DBIC.
```perl
my $collection = GenOO::RegionCollection::Factory->create('DBIC', {
    dsn           => 'dbi:SQLite:database=sqlite_file.db',
    table         => 'test_table',
    records_class => 'GenOOx::Data::DB::DBIC::Species::Schema::SampleResultBase::MyCustom',
})->read_collection;
```

