package Test::MyBio::NGS::Track::Factory::GFF::Tag;
use strict;

use base qw(Test::MyBio);
use Test::Most;

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
sub new_object : Test(setup) {
	my ($self) = @_;
	
	my $record_data = {
		SEQNAME     => 'chr1',
		SOURCE      => 'MirBase',
		FEATURE     => 'miRNA',
		START_1     => '151518272',
		STOP_1      => '151518367',
		SCORE       => 0.5,
		STRAND      => '+',
		FRAME       => '.',
		ATTRIBUTES  => ['ACC="MI0003559"','ID="hsa-mir-554"'],
		COMMENT     => 'This is just a test line',
	};
	my $record = MyBio::Data::File::GFF::Record->new($record_data);
	
	$self->{OBJ} = MyBio::NGS::Track::Factory::GFF::Tag->new({
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
	isa_ok $self->obj->record, 'MyBio::Data::File::GFF::Record', "... and returned object";
}

sub strand : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'strand';
	
	is $self->obj->strand, 1, "... and should return the correct value";
}

sub chr : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'chr';
	
	is $self->obj->chr, 'chr1', "... and should return the correct value";
}

sub start : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'start';
	
	is $self->obj->start, 151518271, "... and should return the correct value";
}

sub stop : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'stop';
	
	is $self->obj->stop, 151518366, "... and should return the correct value";
}

sub name : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'name';
	
	is $self->obj->name, 'miRNA', "... and should return the correct value";
}

sub score : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'score';
	
	is $self->obj->score, 0.5, "... and should return the correct value";
}

sub length : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'length';
	
	is $self->obj->length, 96, "... and should return the correct value";
}

1;
