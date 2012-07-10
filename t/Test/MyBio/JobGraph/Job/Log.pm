package Test::MyBio::JobGraph::Job::Log;
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

sub name : Test(3) {
	my ($self) = @_;
	$self->simple_attribute_test($self->obj, 'name', 'Any_name', 'Any_name');
}

sub source : Test(3) {
	my ($self) = @_;
	$self->simple_attribute_test($self->obj, 'source', 'Any_source', 'Any_source');
}

sub original_source : Test(3) {
	my ($self) = @_;
	$self->simple_attribute_test($self->obj, 'original_source', 'Any_source', 'Any_source');
}

sub devel : Test(1) {
	my ($self) = @_;
	
	can_ok $self->class, 'set_devel';
}

#######################################################################
########################   Abstract Methods   #########################
#######################################################################
sub append : Test(1) {
	my ($self) = @_;
	
	can_ok $self->class, 'append';
}

sub clean : Test(1) {
	my ($self) = @_;
	
	can_ok $self->class, 'clean';
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

sub type : Test(1) {
	my ($self) = @_;
	
	can_ok $self->class, 'type';
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

sub simple_attribute_test {
	my ($self, $obj, $attribute, $value, $expected) = @_;
	
	my $get = $attribute;
	my $set = 'set_'.$attribute;
	
	can_ok $obj, $get;
	can_ok $obj, $set;

	$obj->$set($value);
	is $obj->$get, $expected, "... and setting its value should succeed";
}

1;
