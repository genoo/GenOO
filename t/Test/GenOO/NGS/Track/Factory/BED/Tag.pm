package Test::GenOO::NGS::Track::Factory::BED::Tag;
use strict;

use base qw(Test::GenOO);
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
		rname             => 'chr7',
		start             => 127471196,
		stop_1based       => 127472363,
		name              => 'Pos1',
		score             => 0,
		strand_symbol     => '+',
		thick_start       => 127471196,
		thick_stop_1based => 127472363,
		rgb               => '255,0,0',
		block_count       => 2,
		block_sizes       => [100,200],
		block_starts      => [0, 900],
	};
	
	my $record = GenOO::Data::File::BED::Record->new($record_data);
	$self->{OBJ} = GenOO::NGS::Track::Factory::BED::Tag->new({
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
	isa_ok $self->obj->record, 'GenOO::Data::File::BED::Record', "... and returned object";
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
