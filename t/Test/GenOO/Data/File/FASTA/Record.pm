package Test::GenOO::Data::File::FASTA::Record;
use strict;

use base qw(Test::GenOO);
use Test::More;


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
sub new_object : Test(setup) {
	my ($self) = @_;

	$self->{OBJ} = $self->class->new();
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->class->new(), $self->class, "... and the object";
}

sub header : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('header', '> header', ' header');
}

sub sequence : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('sequence', 'TCATCATCACTCATCTCATCATCATCATCAAT', 'TCATCATCACTCATCTCATCATCATCATCAAT');
}

sub length : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'length';
	
	$self->obj->set_sequence('TCATC');
	is $self->obj->length, 5, '... and should return the correct value';
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
