package Test::MyBio::JobGraph::Job::Output;
use strict;

use Test::Most;
use base qw(Test::MyBio);

use MyBio::JobGraph::Data;

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
	
	$self->{OBJ} = $self->class->new({
		NAME    => 'Any_name',
		SOURCE  => MyBio::JobGraph::Data->new(),
	});
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj, $self->class, "... and the object";
}

sub check_init : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, '_init';
	
	$self->obj->_init({
		NAME    => 'Any_name',
		SOURCE  => MyBio::JobGraph::Data->new(),
	});
	
	is $self->obj->name, 'Any_name', '... and should set correct value';
	isa_ok $self->obj->source, 'MyBio::JobGraph::Data', '... and source';
}

sub name : Test(4) {
	my ($self) = @_;
	
	can_ok $self->obj, 'name';
	is $self->obj->name, 'Any_name', '... and should return correct value';
	
	can_ok $self->obj, 'set_name';
	$self->obj->set_name('A different name');
	is $self->obj->name, 'A different name', '... and should set correct value';
}

sub source : Test(6) {
	my ($self) = @_;
	
	can_ok $self->obj, 'source';
	isa_ok $self->obj->source, 'MyBio::JobGraph::Data', '... and returned object';
	
	can_ok $self->obj, 'check_and_set_source';
	dies_ok {$self->obj->check_and_set_source('Wrong source')} '... and fails to set a wrong value';
	ok $self->obj->check_and_set_source(MyBio::JobGraph::Data->new), '... and succeeds setting a legitimate value';
	isa_ok $self->obj->source, 'MyBio::JobGraph::Data', '... and returned object';
}

sub source_is_appropriate : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'source_is_appropriate';
	dies_ok {$self->obj->source_is_appropriate('Wrong source')} '... and fails for a wrong value';
	ok $self->obj->source_is_appropriate(MyBio::JobGraph::Data->new), '... and succeeds for a legitimate value';
}

sub type : Test(2) {
	my ($self) = @_;
	
	can_ok $self->class, 'type';
	is $self->obj->type, undef, , '... and should be abstract';
}

sub clean : Test(2) {
	my ($self) = @_;
	
	can_ok $self->class, 'clean';
	is $self->obj->type, undef, , '... and should be abstract';
}

sub start_devel_mode : Test(2) {
	my ($self) = @_;
	
	can_ok $self->class, 'start_devel_mode';
	is $self->obj->type, undef, , '... and should be abstract';
}

sub stop_devel_mode : Test(2) {
	my ($self) = @_;
	
	can_ok $self->class, 'stop_devel_mode';
	is $self->obj->type, undef, , '... and should be abstract';
}

sub is_devel_mode_on : Test(2) {
	my ($self) = @_;
	
	can_ok $self->class, 'is_devel_mode_on';
	is $self->obj->type, undef, , '... and should be abstract';
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
