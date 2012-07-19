package Test::MyBio::JobGraph::Job::Executable;
use strict;

use Test::Most;
use base qw(Test::MyBio::JobGraph::Job);

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
		INPUT => [MyBio::JobGraph::Job::Input->new],
		OUTPUT => [MyBio::JobGraph::Job::Output->new],
		LOG => MyBio::JobGraph::Job::Log::File->new({
			FILENAME => 't/sample_data/MyBio_JobGraph_Job_Log_File.txt'
		}),
	});
};

#######################################################################
#################   Teardown (Runs after every test)  #################
#######################################################################
sub remove_file : Test(teardown) {
	my ($self) = @_;
	
	$self->obj->log->clean;
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub run : Test(1) {
	my ($self) = @_;
	
	can_ok $self->class, 'run';
}

sub executable_can_run : Test(2) {
	my ($self) = @_;
	
	can_ok $self->class, 'executable_can_run';
	is $self->obj->executable_can_run, 0, '... and should answer correctly';
}

sub executable : Test(2) {
	my ($self) = @_;
	
	can_ok $self->class, 'executable';
	is $self->obj->executable, undef, , '... and should be abstract';
}

sub command : Test(2) {
	my ($self) = @_;
	
	can_ok $self->class, 'command';
	is $self->obj->command, undef, , '... and should be abstract';
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
