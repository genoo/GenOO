package Test::MyBio::NGS::Track::Factory::SAM::Tag;
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
		qname      => 'HWI-EAS235_25:1:1:4282:1093',
		flag       => '16',
		rname      => 'chr18',
		'pos'        => '85867636',
		mapq       => '0',
		cigar      => '32M',
		rnext      => '*',
		pnext      => '0',
		tlen       => '0',
		seq        => 'ATTCGGCAGGTGAGTTGTTACACACTCCTTAG',
		qual       => 'GHHGHHHGHHGGGDGEGHHHFHGG<GG>?BGG',
		tags       => ['XT:A:R','NM:i:0','X0:i:2','X1:i:0','XM:i:0',
		               'XO:i:0','XG:i:0','MD:Z:32','XA:Z:chr9,+110183777,32M,0;'],
	};
	
	my $record = MyBio::Data::File::SAM::Record->new($record_data);
	$self->{OBJ} = MyBio::NGS::Track::Factory::SAM::Tag->new({
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
	isa_ok $self->obj->record, 'MyBio::Data::File::SAM::Record', "... and returned object";
}

sub strand : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'strand';
	
	is $self->obj->strand, -1, "... and should return the correct value";
}

sub chr : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'chr';
	
	is $self->obj->chr, 'chr18', "... and should return the correct value";
}

sub start : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'start';
	
	is $self->obj->start, 85867635, "... and should return the correct value";
}

sub stop : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'stop';
	
	is $self->obj->stop, 85867666, "... and should return the correct value";
}

sub name : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'name';
	
	is $self->obj->name, 'HWI-EAS235_25:1:1:4282:1093', "... and should return the correct value";
}

sub score : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'score';
	
	is $self->obj->score, 0, "... and should return the correct value";
}

sub length : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'length';
	
	is $self->obj->length, 32, "... and should return the correct value";
}

1;
