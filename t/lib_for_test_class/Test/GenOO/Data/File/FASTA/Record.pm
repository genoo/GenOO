package Test::GenOO::Data::File::FASTA::Record;
use strict;

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

#######################################################################
#######################   Class Interface Tests   #####################
#######################################################################
sub header : Test(3) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'header', "... test object has the 'header' attribute");
	is $self->obj(0)->header, 'test1', "... and returns the correct value";
	is $self->obj(1)->header, 'test2', "... and returns the correct value";
}

sub sequence : Test(3) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'sequence', "... test object has the 'sequence' attribute");
	is $self->obj(0)->sequence, 'CGATGCTAGCTAGCTGATCG', "... and returns the correct value";
	is $self->obj(1)->sequence, 'ctagCTGATCTAGCTAATggccgat', "... and returns the correct value";
}

sub length : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'length';
	is $self->obj(0)->length, 20, "... and returns the correct value";
	is $self->obj(1)->length, 25, "... and returns the correct value";
}

sub to_string : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'to_string';
	is $self->obj(0)->to_string, ">test1\nCGATGCTAGCTAGCTGATCG", "... and returns the correct value";
	is $self->obj(1)->to_string, ">test2\nctagCTGATCTAGCTAATggccgat", "... and returns the correct value";
}

#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	
	my @test_objects;
	push @test_objects, $test_class->class->new(
		header      => '>test1',
		sequence    => 'CGATGCTAGCTAGCTGATCG',
	);
	push @test_objects, $test_class->class->new(
		header      => 'test2',
		sequence    => 'ctagCTGATCTAGCTAATggccgat',
	);
	
	return \@test_objects;
}

1;
