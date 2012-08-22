package Test::MyBio::JobGraph::Job::Input::File;
use strict;

use Test::Most;
use base qw(Test::MyBio::JobGraph::Job::Input);

use MyBio::JobGraph::Data::File;

#######################################################################
################   Startup (Runs once in the begining  ################
#######################################################################
sub _check_loading : Test(startup => 1) {
	my ($self) = @_;
	use_ok $self->class;
}

#######################################################################
#################   Setup (Runs before every method)  #################
#######################################################################
sub new_object : Test(setup) {
	my ($self) = @_;
	
	$self->{OBJ} = MyBio::JobGraph::Job::Input::File->new({
		NAME       => 'Any_name',
		SOURCE     => MyBio::JobGraph::Data::File->new({
			FILENAME   => '/path/to/input/file',
		}),
	});
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub check_init : Test(3) { # Override
	my ($self) = @_;
	
	can_ok $self->obj, '_init';
	
	$self->obj->_init({
		NAME    => 'Any_name',
		SOURCE  => MyBio::JobGraph::Data::File->new(),
	});
	
	is $self->obj->name, 'Any_name', '... and should set correct value';
	isa_ok $self->obj->source, 'MyBio::JobGraph::Data::File', '... and source';
}

sub source : Test(7) { # Override
	my ($self) = @_;
	
	can_ok $self->obj, 'source';
	isa_ok $self->obj->source, 'MyBio::JobGraph::Data::File', '... and returned object';
	
	can_ok $self->obj, 'check_and_set_source';
	dies_ok {$self->obj->check_and_set_source('Wrong source')} '... and should fail to set a wrong value';
	dies_ok {$self->obj->check_and_set_source(MyBio::JobGraph::Data->new)} '... and should fail to set a wrong value again';
	ok $self->obj->check_and_set_source(MyBio::JobGraph::Data::File->new), '... and should succeed setting a legitimate value';
	isa_ok $self->obj->source, 'MyBio::JobGraph::Data::File', '... and returned object';
}

sub source_is_appropriate : Test(4) { # Override
	my ($self) = @_;
	
	can_ok $self->obj, 'source_is_appropriate';
	dies_ok {$self->obj->source_is_appropriate('Wrong source')} '... and should fail for a wrong value';
	dies_ok {$self->obj->source_is_appropriate(MyBio::JobGraph::Data->new)} '... and should fail for a wrong value again';
	ok $self->obj->source_is_appropriate(MyBio::JobGraph::Data::File->new), '... and should succeed for a legitimate value';
}

sub create_source_from_filename : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'create_source_from_filename';
	ok $self->obj->create_source_from_filename('/path/to/output/file'), '... and should create source';
	isa_ok $self->obj->source, 'MyBio::JobGraph::Data::File', '... and source';
}

sub to_output : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'to_output';
	isa_ok $self->obj->to_output, 'MyBio::JobGraph::Job::Output::File', '... and returned object';
}

sub filename : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'filename';
	is $self->obj->filename, '/path/to/input/file', "... and should return the correct value";
}

sub type : Test(2) { # override
	my ($self) = @_;
	
	can_ok $self->obj, 'type';
	is $self->obj->type, 'File', "... and should return the correct value";
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
