package Test::MyBio::Data::File::SAM::Record;
use strict;

use base qw(Test::MyBio);
use Test::More;


#######################################################################
###########################   Basic Tests   ###########################
#######################################################################
sub _loading_test : Test(4) {
	my ($self) = @_;
	
	use_ok $self->class;
	can_ok $self->class, 'new';
	
	my $data = {
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
		TAGS       => "XT:A:R\tNM:i:0\tX0:i:2\tX1:i:0\tXM:i:0\tXO:i:0\tXG:i:0\tMD:Z:32\tXA:Z:chr9,+110183777,32M,0;",
		EXTRA_INFO => undef
	};
	
	ok my $obj = MyBio::Data::File::SAM::Record->new($data), '... and the constructor succeeds';
	isa_ok $obj, $self->class, "... and the object";
}

#######################################################################
#########################   Attributes Tests   ########################
#######################################################################
sub qname : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('qname', 'HWI-EAS235_25:1:1:4282:1093', 'HWI-EAS235_25:1:1:4282:1093');
}

sub flag : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('flag', 16, 16);
}

sub rname : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('rname', 'chr18', 'chr18');
}

sub pos : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('pos', 85867636, 85867636);
}

sub mapq : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('mapq', 0, 0);
}

sub cigar : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('cigar', '32M', '32M');
}

sub rnext : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('rnext', '*', '*');
}

sub pnext : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('pnext', 0, 0);
}

sub tlen : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('tlen', 0, 0);
}

sub seq : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('seq', 'ATTCGGCAGGTGAGTTGTTACACACTCCTTAG', 'ATTCGGCAGGTGAGTTGTTACACACTCCTTAG');
}

sub qual : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('qual', 'GHHGHHHGHHGGGDGEGHHHFHGG', 'GHHGHHHGHHGGGDGEGHHHFHGG');
}

#######################################################################
###########################   Other Tests   ###########################
#######################################################################
sub tags : Test(1) {
	local $TODO = "get_tags -> currently unimplemented";
}

sub get_start : Test(2) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'get_start';
	
	$obj->set_pos(85867636);
	is $obj->get_start, 85867635, "... and should return the correct value";
}

sub get_stop : Test(2) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'get_stop';
	
	$obj->set_pos(85867636);
	$obj->set_seq('ATTCGGCAGGTGAGTTGTTACACACTCCTTAG');
	is $obj->get_stop, 85867666, "... and should return the correct value";
}

sub get_strand : Test(4) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'get_strand';
	
	$obj->set_flag(16); # mapped on reverse complemenent
	is $obj->get_strand, -1, "... and should return the correct value";
	
	$obj->set_flag(0); # mapped on forward
	is $obj->get_strand, 1, "... and should return the correct value again";
	
	$obj->set_flag(4); # unmapped
	is $obj->get_strand, undef, "... and again";
}

sub get_strand_symbol : Test(4) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'get_strand_symbol';
	
	$obj->set_flag(16); # mapped on reverse complemenent
	is $obj->get_strand_symbol, '-', "... and should return the correct value";
	
	$obj->set_flag(0); # mapped on forward
	is $obj->get_strand_symbol, '+', "... and should return the correct value again";
	
	$obj->set_flag(4); # unmapped
	is $obj->get_strand_symbol, undef, "... and again";
}

sub is_mapped : Test(4) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'is_mapped';
	
	$obj->set_flag(16); # mapped on reverse complemenent
	is $obj->is_mapped, 1, "... and should return the correct value";
	
	$obj->set_flag(0); # mapped on forward
	is $obj->is_mapped, 1, "... and should return the correct value again";
	
	$obj->set_flag(4); # unmapped
	is $obj->is_mapped, 0, "... and again";
}

sub is_unmapped : Test(4) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'is_unmapped';
	
	$obj->set_flag(16); # mapped on reverse complemenent
	is $obj->is_unmapped, 0, "... and should return the correct value";
	
	$obj->set_flag(0); # mapped on forward
	is $obj->is_unmapped, 0, "... and should return the correct value again";
	
	$obj->set_flag(4); # unmapped
	is $obj->is_unmapped, 1, "... and again";
}

1;
