package Test::MyBio::JobGraph::Job::IO;
use strict;

use base qw(Test::MyBio);
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
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj, $self->class, "... and the object";
}

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

sub name : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('name', 'Any_name', 'Any_name');
}

sub source : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('source', 'Any_source', 'Any_source');
}

sub original_source : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('original_source', 'Any_source', 'Any_source');
}

sub type : Test(2) {
	my ($self) = @_;
	
	can_ok $self->class, 'type';
	dies_ok {$self->class->type} '... and method should be abstract';
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
