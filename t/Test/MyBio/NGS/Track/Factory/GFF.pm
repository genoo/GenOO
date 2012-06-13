package Test::MyBio::NGS::Track::Factory::GFF;
use strict;

use base qw(Test::MyBio);
use Test::More;

#######################################################################
############################   Accessors   ############################
#######################################################################
sub gff_track {
	my ($self) = @_;
	return $self->{GFF_TRACK};
}

#######################################################################
################   Startup (Runs once in the begining  ################
#######################################################################
sub startup : Test(startup => 3) {
	my ($self) = @_;
	
	use_ok $self->class;
	can_ok $self->class, 'new';
	
	ok $self->{GFF_TRACK} = MyBio::NGS::Track::Factory::GFF->new({
		FILE => 't/sample_data/sample.gff.gz'
	}), '... and the constructor succeeds';
};

#######################################################################
#################   Setup (Runs before every method)  #################
#######################################################################
sub new_object : Test(setup) {
	my ($self) = @_;
	
	$self->{GFF} = MyBio::NGS::Track::Factory::GFF->new({
		FILE => 't/sample_data/sample.gff.gz'
	});
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->gff_track, $self->class, "... and the object";
}

sub get_file : Test(2) {
	my ($self) = @_;
	
	can_ok $self->gff_track, 'get_file';
	is $self->gff_track->get_file, 't/sample_data/sample.gff.gz', "... and should return the correct value";
}

sub read_track : Test(3) {
	my ($self) = @_;
	
	can_ok $self->gff_track, 'read_track';
	
	my $track = $self->gff_track->read_track;
	isa_ok $track, 'MyBio::NGS::Track', "... and the returned object";
	is $track->entries_count, 93, "... and it contains the correct number of tags";
}

1;
