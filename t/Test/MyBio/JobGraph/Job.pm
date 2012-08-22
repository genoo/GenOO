package Test::MyBio::JobGraph::Job;
use strict;

use Test::Most;
use base qw(Test::MyBio);

use MyBio::JobGraph::Job::Input;
use MyBio::JobGraph::Job::Output;
use MyBio::JobGraph::Job::Log::File;

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
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj, $self->class, "... and the object";
}

sub input : Test(5) {
	my ($self) = @_;
	
	can_ok $self->obj, 'input';
	isa_ok $self->obj->input, 'ARRAY', '... and returned object';
	is_deeply $self->obj->input, [MyBio::JobGraph::Job::Input->new], '... and should contain the correct types';
	
	can_ok $self->obj, 'set_input';
	$self->obj->set_input([MyBio::JobGraph::Job::Input->new]);
	is_deeply $self->obj->input, [MyBio::JobGraph::Job::Input->new], '... and should set the correct types'
}

sub output : Test(5) {
	my ($self) = @_;
	
	can_ok $self->obj, 'output';
	isa_ok $self->obj->output, 'ARRAY', '... and returned object';
	is_deeply $self->obj->output, [MyBio::JobGraph::Job::Output->new], '... and should contain the correct types';
	
	can_ok $self->obj, 'set_output';
	$self->obj->set_output([MyBio::JobGraph::Job::Output->new]);
	is_deeply $self->obj->output, [MyBio::JobGraph::Job::Output->new], '... and should set the correct types'
}

sub log : Test(4) {
	my ($self) = @_;
	
	can_ok $self->obj, 'log';
	isa_ok $self->obj->log, 'MyBio::JobGraph::Job::Log::File', '... and returned object';
	
	can_ok $self->obj, 'set_log';
	$self->obj->set_log(MyBio::JobGraph::Job::Log::File->new({
		FILENAME => 't/sample_data/MyBio_JobGraph_Job_Log_File.txt'
	}));
	isa_ok $self->obj->log, 'MyBio::JobGraph::Job::Log::File', '... and should set the correct types'
}

sub options : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'options';
	can_ok $self->obj, 'set_options';
	
	$self->obj->set_options({});
	isa_ok $self->obj->options, 'HASH', '... and returned object';
}

sub set_devel : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'set_devel';
	
	$self->obj->set_devel(1);
	is $self->obj->is_devel_mode_on, 1, "... and should result in starting development mode";
	
	$self->obj->set_devel(0);
	is $self->obj->is_devel_mode_on, 0, "... and should result in stoping development mode";
}

sub return_string : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'return_string';
	can_ok $self->obj, 'set_return_string';
	
	$self->obj->set_return_string('STDERR ans STDOUT');
	is $self->obj->return_string, 'STDERR ans STDOUT', '... and should set the correct value';
}

sub check_initialization : Test(5) {
	my ($self) = @_;
	
	can_ok $self->class, 'check_initialization';
	
	ok $self->obj->check_initialization, '... and the check should succeed';
	
	$self->obj->set_input({});
	dies_ok {$self->obj->check_initialization} '... and the check should fail';
	$self->obj->set_input([MyBio::JobGraph::Job::Input->new]);
	
	$self->obj->set_output({});
	dies_ok {$self->obj->check_initialization} '... and the check should fail again';
	$self->obj->set_output([MyBio::JobGraph::Job::Output->new]);
	
	ok $self->obj->check_initialization, '... and the check should now succeed';
}

sub is_input_appropriate : Test(4) {
	my ($self) = @_;
	
	can_ok $self->class, 'is_input_appropriate';
	
	ok $self->obj->is_input_appropriate, '... and the check should succeed';
	
	$self->obj->set_input({});
	dies_ok {$self->obj->is_input_appropriate} '... and the check should fail';
	
	$self->obj->set_input([MyBio::JobGraph::Job::Output->new]);
	dies_ok {$self->obj->is_input_appropriate} '... and the check should fail again';
}

sub is_output_appropriate : Test(4) {
	my ($self) = @_;
	
	can_ok $self->class, 'is_output_appropriate';
	
	ok $self->obj->is_output_appropriate, '... and the check should succeed';
	
	$self->obj->set_output({});
	dies_ok {$self->obj->is_output_appropriate} '... and the check should fail';
	
	$self->obj->set_output([MyBio::JobGraph::Job::Input->new]);
	dies_ok {$self->obj->is_output_appropriate} '... and the check should fail again';
}

sub is_io_appropriate : Test(4) {
	my ($self) = @_;
	
	can_ok $self->class, 'is_io_appropriate';
	
	ok $self->obj->is_io_appropriate([MyBio::JobGraph::Job::Input->new], 'MyBio::JobGraph::Job::Input'), '... and the check should succeed';
	ok $self->obj->is_io_appropriate([MyBio::JobGraph::Job::Output->new], 'MyBio::JobGraph::Job::Output'), '... and the check should fail again';
	dies_ok {$self->obj->is_io_appropriate({})} '... and the check should fail';
}

sub clean : Test(1) {
	my ($self) = @_;
	
	can_ok $self->class, 'clean';
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

sub run : Test(2) {
	my ($self) = @_;
	
	can_ok $self->class, 'run';
	is $self->obj->run, undef, , '... and should be abstract';
}

sub description : Test(2) {
	my ($self) = @_;
	
	can_ok $self->class, 'description';
	is $self->obj->description, undef, , '... and should be abstract';
}



#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
