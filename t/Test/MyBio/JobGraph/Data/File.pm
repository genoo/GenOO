package Test::MyBio::JobGraph::Data::File;
use strict;

use Test::Most;
use base qw(Test::MyBio::JobGraph::Data);

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
	
	$self->{OBJ} = MyBio::JobGraph::Data::File->new({
		FILENAME   => '/path/to/output/file',
	});
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub filename : Test(4) {
	my ($self) = @_;
	
	$self->simple_attribute_test('filename', 'path', 'path');
}

sub original_filename : Test(4) {
	my ($self) = @_;
	
	can_ok $self->obj, 'original_filename';
	is $self->obj->original_filename, '/path/to/output/file', '... and should return the correct value';
	
	can_ok $self->obj, 'set_original_filename';
	$self->obj->set_original_filename('path');
	is $self->obj->original_filename, 'path', '... and should set the correct value';
}

sub type : Test(2) { # override
	my ($self) = @_;
	
	can_ok $self->obj, 'type';
	is $self->obj->type, 'File', '... and should return the correct value';
}

sub clean : Test(1) { # override
	my ($self) = @_;
	
	can_ok $self->obj, 'clean';
}

sub start_devel_mode : Test(2) { # override
	my ($self) = @_;
	
	can_ok $self->obj, 'start_devel_mode';
	
	$self->obj->start_devel_mode;
	is $self->obj->is_devel_mode_on, 1, '... and should result in starting development mode';
}

sub stop_devel_mode : Test(2) { # override
	my ($self) = @_;
	
	can_ok $self->obj, 'stop_devel_mode';
	
	$self->obj->stop_devel_mode;
	is $self->obj->is_devel_mode_on, 0, '... and should result in starting development mode';
}

sub set_filename_to_devel : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'set_filename_to_devel';
	
	$self->obj->set_filename_to_devel;
	is $self->obj->filename, '/path/to/output/dev_file', '... and should result in the correct value';
}

sub set_filename_to_original : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'set_filename_to_original';
	
	$self->obj->set_filename_to_original;
	is $self->obj->filename, '/path/to/output/file', '... and should result in the correct value';
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
