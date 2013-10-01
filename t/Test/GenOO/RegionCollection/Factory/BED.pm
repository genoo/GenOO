package Test::GenOO::RegionCollection::Factory::BED;

use base qw(Test::GenOO);
use Test::Moose;
use Test::Most;

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
	is $self->obj(0)->file, 't/sample_data/sample.bed.gz', "... and returns the correct value";
}

sub read_collection : Test(4) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'read_collection';
	
	my $collection = $self->obj(0)->read_collection;
	does_ok($collection, 'GenOO::RegionCollection', "... and the returned object does the GenOO::RegionCollection role");
	is $collection->records_count, 9, "... and it contains the correct number of records";
	
	my $collection_filtered = $self->obj(1)->read_collection;
	is $collection_filtered->records_count, 1, "... and it contains the correct number of records";
}

#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	
	my @test_objects;
	
	push @test_objects, $test_class->class->new(
		file => 't/sample_data/sample.bed.gz'
	);
	
	push @test_objects, $test_class->class->new(
		file        => 't/sample_data/sample.bed.gz',
		filter_code => sub {return $_[0]->rname eq 'chrX' ? 1 : 0}
	);
	
	return \@test_objects;
}

1;
