package Test::MyBio::JobGraph::Data;
use strict;

use Test::Most;
use base qw(Test::MyBio);

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
	
	$self->{OBJ} = $self->class->new;
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj, $self->class, "... and the object";
}

sub check_init : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, '_init';
	ok $self->obj->_init;
}

sub devel_mode : Test(4) {
	my ($self) = @_;
	
	$self->simple_attribute_test('devel_mode', 1, 1);
}

sub is_devel_mode_on : Test(4) {
	my ($self) = @_;
	
	can_ok $self->obj, 'is_devel_mode_on';
	
	is $self->obj->is_devel_mode_on, 0, '... and should return the correct value';
	
	$self->obj->set_devel_mode(1);
	is $self->obj->is_devel_mode_on, 1, '... and should return the correct value';
	
	$self->obj->set_devel_mode(0);
	is $self->obj->is_devel_mode_on, 0, '... and should return the correct value';
}

sub type : Test(2) {
	my ($self) = @_;
	
	can_ok $self->class, 'type';
	is $self->obj->type, undef, , '... and should be abstract';
}

sub clean : Test(2) {
	my ($self) = @_;
	
	can_ok $self->class, 'clean';
	is $self->obj->clean, undef, , '... and should be abstract';
}

sub start_devel_mode : Test(2) {
	my ($self) = @_;
	
	can_ok $self->class, 'start_devel_mode';
	is $self->obj->start_devel_mode, undef, , '... and should be abstract';
}

sub stop_devel_mode : Test(2) {
	my ($self) = @_;
	
	can_ok $self->class, 'stop_devel_mode';
	is $self->obj->stop_devel_mode, undef, , '... and should be abstract';
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
