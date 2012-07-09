package Test::MyBio::JobGraph::Job::Output::File;
use strict;

use Test::Most;
use base qw(Test::MyBio::JobGraph::Job::Output);

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
	
	$self->{OBJ} = MyBio::JobGraph::Job::Output::File->new({
		NAME       => 'Just a name',
		SOURCE     => '/path/to/output/file',
		DEVEL      => 0
	});
};

#######################################################################
##########################   Override Tests   #########################
#######################################################################
sub type : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'type';
	is $self->obj->type, 'File', "... and should return the correct value";
}

sub clean : Test(1) {
	my ($self) = @_;
	
	can_ok $self->obj, 'clean';
}

sub start_devel_mode : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'start_devel_mode';
	
	$self->obj->start_devel_mode;
	is $self->obj->is_devel_mode_on, 1, "... and should result in starting development mode";
}

sub stop_devel_mode : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'stop_devel_mode';
	
	$self->obj->stop_devel_mode;
	is $self->obj->is_devel_mode_on, 0, "... and should result in starting development mode";
}

sub is_devel_mode_on : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'is_devel_mode_on';
	
	is $self->obj->is_devel_mode_on, 0, "... and should return the correct value";
	
	$self->obj->start_devel_mode;
	is $self->obj->is_devel_mode_on, 1, "... and should return the correct value again";
}

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub set_source_to_devel : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'set_source_to_devel';
	
	$self->obj->set_source_to_devel;
	is $self->obj->source, '/path/to/output/dev_file', "... and should result in the correct value";
}

sub set_source_to_original : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'set_source_to_original';
	
	$self->obj->set_source_to_original;
	is $self->obj->source, '/path/to/output/file', "... and should result in the correct value";
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
