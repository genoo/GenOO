package Test::GenOO::RegionCollection::Factory::RegionArray;
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
sub array_attribute : Test(1) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'array', "... test object has the 'array' attribute");
}

sub read_collection : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'read_collection';
	
	my $collection = $self->obj(0)->read_collection;
	does_ok($collection, 'GenOO::RegionCollection', "... and the returned object does the GenOO::RegionCollection role");
	is $collection->records_count, 12, "... and it contains the correct number of records";
}

#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	eval "require Test::GenOO::GenomicRegion";
	
	my @test_regions = @{Test::GenOO::GenomicRegion->test_objects()}[0..11];
	
	my @test_objects;
	push @test_objects, $test_class->class->new(
		array => \@test_regions
	);
	
	return \@test_objects;
}

1;
