package Test::MyBio::NGS::Track::Factory::BED::Tag;
use strict;

use base qw(Test::MyBio);
use Test::Most;

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
	
	my $record_data = {
		CHR          => 'chr7',
		START        => 127471196,
		STOP_1       => 127472363,
		NAME         => 'Pos1',
		SCORE        => 0,
		STRAND       => '+',
		THICK_START  => 127471196,
		THICK_STOP   => 127472363,
		RGB          => '255,0,0',
		BLOCK_COUNT  => 2,
		BLOCK_SIZES  => [100,200],
		BLOCK_STARTS => [0, 900],
	};
	
	my $record = MyBio::Data::File::BED::Record->new($record_data);
	$self->{OBJ} = MyBio::NGS::Track::Factory::BED::Tag->new({
		RECORD => $record,
	});
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj, $self->class, "... and the object";
}

sub record : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'record';
	isa_ok $self->obj->record, 'MyBio::Data::File::BED::Record', "... and returned object";
}

sub get_strand : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_strand';
	
	is $self->obj->get_strand, 1, "... and should return the correct value";
}

sub get_chr : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_chr';
	
	is $self->obj->get_chr, 'chr7', "... and should return the correct value";
}

sub get_start : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_start';
	
	is $self->obj->get_start, 127471196, "... and should return the correct value";
}

sub get_stop : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_stop';
	
	is $self->obj->get_stop, 127472362, "... and should return the correct value";
}

sub get_name : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_name';
	
	is $self->obj->get_name, 'Pos1', "... and should return the correct value";
}

sub get_score : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_score';
	
	is $self->obj->get_score, 0, "... and should return the correct value";
}

sub get_length : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_length';
	
	is $self->obj->get_length, 1167, "... and should return the correct value";
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
