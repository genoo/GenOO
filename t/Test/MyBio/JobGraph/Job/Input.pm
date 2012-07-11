package Test::MyBio::JobGraph::Job::Input;
use strict;

use base qw(Test::MyBio);
use Test::More;
use Test::TestObjects;

#######################################################################
###########################   To Do Dev     ###########################
#######################################################################

#######################################################################
###########################   Test Data     ###########################
#######################################################################
sub sample_object {
	return Test::TestObjects->get_testobject_MyBio_JobGraph_Input;
}
sub data {
	return {
		
	};
}

#######################################################################
###########################   Basic Tests   ###########################
#######################################################################
sub _loading_test : Test(4) {
	my ($self) = @_;
	
	use_ok $self->class;
	can_ok $self->class, 'new';
 	ok my $obj = $self->class->new($self->sample_object->[0]), '... and the constructor succeeds';
 	isa_ok $obj, $self->class, '... and the object';
}

1;
