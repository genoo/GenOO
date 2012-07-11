package Test::MyBio::JobGraph::Job::Output;
use strict;

use base qw(Test::MyBio::JobGraph::Job::IO);
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
sub new_object : Test(setup) {
	my ($self) = @_;
	
	$self->{OBJ} = $self->class->new();
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub check_init : Test(4) {
	my ($self) = @_;
	
	can_ok $self->obj, '_init';
	
	$self->obj->_init({
		NAME    => 'Any_name',
		SOURCE  => 'Any_source',
	});
	
	is $self->obj->name, 'Any_name', '... and should set correct value';
	is $self->obj->source, 'Any_source', '... and should set correct value again';
	is $self->obj->original_source, 'Any_source', '... and again';
}

sub start_devel_mode : Test(1) {
	my ($self) = @_;
	
	can_ok $self->class, 'start_devel_mode';
}

sub stop_devel_mode : Test(1) {
	my ($self) = @_;
	
	can_ok $self->class, 'stop_devel_mode';
}

sub is_devel_mode_on : Test(1) {
	my ($self) = @_;
	
	can_ok $self->class, 'is_devel_mode_on';
}

sub clean : Test(1) {
	my ($self) = @_;
	
	can_ok $self->class, 'clean';
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
