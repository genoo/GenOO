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

sub strand : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'strand';
	
	is $self->obj->strand, 1, "... and should return the correct value";
}

sub chr : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'chr';
	
	is $self->obj->chr, 'chr7', "... and should return the correct value";
}

sub start : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'start';
	
	is $self->obj->start, 127471196, "... and should return the correct value";
}

sub stop : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'stop';
	
	is $self->obj->stop, 127472362, "... and should return the correct value";
}

sub name : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'name';
	
	is $self->obj->name, 'Pos1', "... and should return the correct value";
}

sub score : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'score';
	
	is $self->obj->score, 0, "... and should return the correct value";
}

sub length : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'length';
	
	is $self->obj->length, 1167, "... and should return the correct value";
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
