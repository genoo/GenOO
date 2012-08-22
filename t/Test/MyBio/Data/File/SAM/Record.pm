package Test::MyBio::Data::File::SAM::Record;
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
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	
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
		TAGS       => ['XT:A:R','NM:i:0','X0:i:2','X1:i:0','XM:i:0',
		               'XO:i:0','XG:i:0','MD:Z:32','XA:Z:chr9,+110183777,32M,0;'],
		EXTRA_INFO => undef
	};
	
	isa_ok $self->class->new($data), $self->class, "... and the object";
}

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

sub tags : Test(4) {
	my ($self) = @_;
	my $value = [
		'XT:A:R',
		'XA:Z:chr9,+110183777,32M,0;'
	];
	my $expected = {
		'XT:A'  => 'R',
		'XA:Z'  => 'chr9,+110183777,32M,0;'
	};
	$self->deep_attribute_test('tags', $value, $expected);
}

sub length : Test(3) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'length';
	
	$obj->set_pos(85867636);
	$obj->set_seq('ATTCGGCAGGTGAGTTGTTACACACTCCTTAG');
	is $obj->length, 32, "... and should return the correct value";
	
	$obj->set_cigar('14M1I5M'); # implements an insertion
	is $obj->length, 31, "... and should return the correct value again";
}

sub start : Test(2) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'start';
	
	$obj->set_pos(85867636);
	is $obj->start, 85867635, "... and should return the correct value";
}

sub stop : Test(4) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'stop';
	
	$obj->set_pos(85867636);
	$obj->set_seq('ATTCGGCAGGTGAGTTGTTACACACTCCTTAG');
	is $obj->stop, 85867666, "... and should return the correct value";
	
	$obj->set_cigar('14M1I5M'); # implements an insertion
	is $obj->stop, 85867665, "... and should return the correct value again";
	
	$obj->set_cigar('7M1D7M1I5M'); # implements a deletion
	is $obj->stop, 85867666, "... and should return the correct value again";
}

sub strand : Test(4) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'strand';
	
	$obj->set_flag(16); # mapped on reverse complemenent
	is $obj->strand, -1, "... and should return the correct value";
	
	$obj->set_flag(0); # mapped on forward
	is $obj->strand, 1, "... and should return the correct value again";
	
	$obj->set_flag(4); # unmapped
	is $obj->strand, undef, "... and again";
}

sub strand_symbol : Test(4) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'strand_symbol';
	
	$obj->set_flag(16); # mapped on reverse complemenent
	is $obj->strand_symbol, '-', "... and should return the correct value";
	
	$obj->set_flag(0); # mapped on forward
	is $obj->strand_symbol, '+', "... and should return the correct value again";
	
	$obj->set_flag(4); # unmapped
	is $obj->strand_symbol, undef, "... and again";
}

sub tag : Test(4) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'tag';
	
	$obj->set_tags(['XT:A:R','XA:Z:chr9,+110183777,32M,0;']);
	is $obj->tag(), undef, "... and should return the correct value";
	is $obj->tag('XT:A'), 'R', "... and should return the correct value again";
	is $obj->tag('XA:Z'), 'chr9,+110183777,32M,0;', "... and again";
}

sub alternative_mappings : Test(3) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'alternative_mappings';
	
	$obj->set_tags(['XA:Z:chr9,+110183777,32M,0;chr8,+110183756,30M1I,0;']);
	my @values = $obj->alternative_mappings;
	is $values[0], 'chr9,+110183777,32M,0', "... and should return the correct value";
	is $values[1], 'chr8,+110183756,30M1I,0', "... and again";
}

sub to_string : Test(1) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'to_string';
}

sub insertion_count : Test(3) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'insertion_count';
	
	$obj->set_cigar('14M1I5M');
	is $obj->insertion_count, 1, "... and should return the correct value";
	
	$obj->set_cigar('14M1I5M2I5M');
	is $obj->insertion_count, 3, "... and should return the correct value again";
}

sub deletion_count : Test(3) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'deletion_count';
	
	$obj->set_cigar('14M1D5M');
	is $obj->deletion_count, 1, "... and should return the correct value";
	
	$obj->set_cigar('14M1D5M2D5M');
	is $obj->deletion_count, 3, "... and should return the correct value again";
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

#######################################################################
##########################   Helper Methods   #########################
#######################################################################

1;
