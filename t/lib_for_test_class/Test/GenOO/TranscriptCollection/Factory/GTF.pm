package Test::GenOO::TranscriptCollection::Factory::GTF;
use strict;

use base qw(Test::GenOO);
use Test::Most;
use Test::Moose;

#######################################################################
################   Startup (Runs once in the begining  ################
#######################################################################
sub _check_loading : Test(startup => 1) {
	my ($self) = @_;
	use_ok $self->class;
};

#######################################################################
#################   Setup (Runs before every method)  #################
#######################################################################
sub create_new_test_objects : Test(setup) {
	my ($self) = @_;
	
	my $test_class = ref($self) || $self;
	$self->{TEST_OBJECTS} = $test_class->test_objects();
};

#######################################################################
##########################   Initial Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	isa_ok $self->obj(0), $self->class, "... and the object";
}

sub _role_check : Test(1) {
	my ($self) = @_;
	does_ok($self->obj(0), 'GenOO::RegionCollection::Factory::Requires', '... does the appropriate role');
}

#######################################################################
#######################   Class Interface Tests   #####################
#######################################################################
sub file : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'file', "... test object has the 'file' attribute");
	is $self->obj(0)->file, 't/sample_data/sample.transcripts.gtf.gz', "... and returns the correct value";
}

sub read_collection : Test(5) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'read_collection';
	
	my $collection = $self->obj(0)->read_collection;
	does_ok($collection, 'GenOO::RegionCollection', "... and the returned object does the GenOO::RegionCollection role");
	is $collection->records_count, 70, "... and it contains the correct number of records";
	
	$collection = $self->obj(1)->read_collection;
	does_ok($collection, 'GenOO::RegionCollection', "... and the returned object does the GenOO::RegionCollection role");
	is $collection->records_count, 58, "... and it contains the correct number of records";
}

sub check_individual_transcripts : Test(16) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'read_collection';
	
	my $collection = $self->obj(0)->read_collection;
	my @transcripts = sort {$a->id cmp $b->id} $collection->all_records;
	is $transcripts[0]->is_coding, 0, "... should be non coding";
	is $transcripts[0]->start, 11873, "... returns correct";
	is $transcripts[0]->stop, 14408, "... returns correct";
	is $transcripts[0]->id, 'uc001aaa.3', "... returns correct";
	is $transcripts[0]->strand, 1, "... returns correct";
	is $transcripts[0]->chromosome, 'chr1', "... returns correct";
	is $transcripts[0]->splice_starts->[0], '11873', "... returns correct";
	is $transcripts[0]->splice_starts->[1], '12612', "... returns correct";
	is $transcripts[0]->splice_starts->[2], '13220', "... returns correct";
	is $transcripts[0]->splice_stops->[0], '12226', "... returns correct";
	is $transcripts[0]->splice_stops->[1], '12720', "... returns correct";
	is $transcripts[0]->splice_stops->[2], '14408', "... returns correct";

	is $transcripts[68]->is_coding, 1, "... should be non coding";
	is $transcripts[68]->coding_start, 897013, "... returns correct";
	is $transcripts[68]->coding_stop, 897651, "... returns correct";
}

#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	
	my @test_objects;
	
	push @test_objects, $test_class->class->new(
		file => 't/sample_data/sample.transcripts.gtf.gz'
	);
	
	push @test_objects, $test_class->class->new(
		file => 't/sample_data/sample.transcripts.genenames.gtf.gz'
	);
	
	return \@test_objects;
}

1;
