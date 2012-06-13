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
		QNAME      => 'HWI-EAS235_25:1:1:4282:1093',
		FLAG       => '16',
		RNAME      => 'chr18',
		POS        => '85867636',
		MAPQ       => '0',
		CIGAR      => '32M',
		RNEXT      => '*',
		PNEXT      => '0',
		TLEN       => '0',
		SEQ        => 'ATTCGGCAGGTGAGTTGTTACACACTCCTTAG',
		QUAL       => 'GHHGHHHGHHGGGDGEGHHHFHGG<GG>?BGG',
		TAGS       => ['XT:A:R','NM:i:0','X0:i:2','X1:i:0','XM:i:0',
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

sub get_strand : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_strand';
	
	is $self->obj->get_strand, -1, "... and should return the correct value";
}

sub get_chr : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_chr';
	
	is $self->obj->get_chr, 'chr18', "... and should return the correct value";
}

sub get_start : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_start';
	
	is $self->obj->get_start, 85867635, "... and should return the correct value";
}

sub get_stop : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_stop';
	
	is $self->obj->get_stop, 85867666, "... and should return the correct value";
}

sub get_name : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_name';
	
	is $self->obj->get_name, 'HWI-EAS235_25:1:1:4282:1093', "... and should return the correct value";
}

sub get_score : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_score';
	
	is $self->obj->get_score, 0, "... and should return the correct value";
}

1;
