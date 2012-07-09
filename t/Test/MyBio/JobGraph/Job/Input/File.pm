package Test::MyBio::JobGraph::Job::Input::File;
use strict;

use Test::Most;
use base qw(Test::MyBio::JobGraph::Job::Input);

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
		NAME       => 'Just a name',
		SOURCE     => '/path/to/input/file',
		DEVEL      => 0
	});
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
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
