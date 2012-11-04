package Test::MyBio::NGS::Track::Factory::BED;
use strict;

use base qw(Test::MyBio);
use Test::Most;
use Test::Moose;

#######################################################################
############################   Accessors   ############################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

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
sub new_object : Test(setup => 1) {
	my ($self) = @_;
	
	ok $self->{OBJ} = MyBio::NGS::Track::Factory::BED->new({
		FILE => 't/sample_data/sample.bed.gz'
	});
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj, $self->class, "... and the object";
}

sub get_file : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_file';
	is $self->obj->get_file, 't/sample_data/sample.bed.gz', "... and should return the correct value";
}

sub read_track : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'read_track';
	
	my $track = $self->obj->read_track;
	does_ok($track, 'MyBio::NGS::Track', "... and the returned object does the MyBio::NGS::Track role");
	is $track->entries_count, 9, "... and it contains the correct number of tags";
}

1;
