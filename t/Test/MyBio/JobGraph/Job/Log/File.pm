package Test::MyBio::JobGraph::Job::Log::File;
use strict;

use Test::Most;
use base qw(Test::MyBio::JobGraph::Job::Log);

#######################################################################
################   Startup (Runs once in the begining  ################
#######################################################################
sub _check_loading : Test(startup => 1) {
	my ($self) = @_;
	use_ok $self->class;
}

#######################################################################
##################   Setup (Runs before every test)  ##################
#######################################################################
sub new_object : Test(setup) {
	my ($self) = @_;
	
	$self->{OBJ} = MyBio::JobGraph::Job::Log::File->new({
		NAME       => 'Just a name',
		SOURCE     => 't/sample_data/MyBio_JobGraph_Job_Log_File.txt',
	});
};

#######################################################################
#################   Teardown (Runs after every test)  #################
#######################################################################
sub remove_file : Test(teardown) {
	my ($self) = @_;
	
	$self->obj->clean;
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub filehandle : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'filehandle';
	isa_ok $self->obj->filehandle, 'FileHandle', "... and should return the correct type";
}

sub type : Test(2) { # override
	my ($self) = @_;
	
	can_ok $self->obj, 'type';
	is $self->obj->type, 'File', "... and should return the correct value";
}

sub open : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'open';
	ok $self->obj->open, "... and should succeed";
}

sub close : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'close';
	ok $self->obj->close, "... and should succeed";
}

sub append : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'append';
	ok $self->obj->append('Log message'), "... and should succeed";
	$self->obj->close;
	
	open my $fh, '<', $self->obj->source or die $!;
	my @filecontents = <$fh>;
	close $fh;
	
	is $filecontents[-1], "Log message\n", "... and should append correctly";
}

sub clean : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'clean';
	ok $self->obj->clean, "... and should succeed";
	
	ok !-e 't/sample_data/MyBio_JobGraph_Job_Log_File.txt', "... and file should be removed";
}

sub start_devel_mode : Test(2) { # override
	my ($self) = @_;
	
	can_ok $self->obj, 'start_devel_mode';
	
	$self->obj->start_devel_mode;
	is $self->obj->is_devel_mode_on, 1, "... and should result in starting development mode";
}

sub stop_devel_mode : Test(2) { # override
	my ($self) = @_;
	
	can_ok $self->obj, 'stop_devel_mode';
	
	$self->obj->stop_devel_mode;
	is $self->obj->is_devel_mode_on, 0, "... and should result in starting development mode";
}

sub set_source_to_devel : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'set_source_to_devel';
	
	$self->obj->set_source_to_devel;
	is $self->obj->source, 't/sample_data/dev_MyBio_JobGraph_Job_Log_File.txt', "... and should result in the correct value";
}

sub set_source_to_original : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'set_source_to_original';
	
	$self->obj->set_source_to_original;
	is $self->obj->source, 't/sample_data/MyBio_JobGraph_Job_Log_File.txt', "... and should result in the correct value";
}

sub is_devel_mode_on : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'is_devel_mode_on';
	
	is $self->obj->is_devel_mode_on, 0, "... and should return the correct value";
	
	$self->obj->start_devel_mode;
	is $self->obj->is_devel_mode_on, 1, "... and should return the correct value again";
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
