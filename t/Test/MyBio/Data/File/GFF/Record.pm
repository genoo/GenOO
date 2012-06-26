package Test::MyBio::Data::File::GFF::Record;
use strict;

use base qw(Test::MyBio);
use Test::More;


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
		SEQNAME     => 'chr1',
		SOURCE      => 'MirBase',
		FEATURE     => 'miRNA',
		START_1     => '151518272',
		STOP_1      => '151518367',
		SCORE       => '0.5',
		STRAND      => '+',
		FRAME       => '.',
		ATTRIBUTES  => ['ACC="MI0003559"','ID="hsa-mir-554"'],
		COMMENT     => 'This is just a test line',
	};
	
	isa_ok $self->class->new($data), $self->class, "... and the object";
}

sub seqname : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('seqname', 'chr1', 'chr1');
}

sub source : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('source', 'MirBase', 'MirBase');
}

sub feature : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('feature', 'miRNA', 'miRNA');
}

sub start : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('start', 151518272, 151518271);
}

sub stop : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('stop', 151518367, 151518366);
}

sub strand : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('strand', '+', 1);
}

sub frame : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('frame', '.', '.');
}

sub attributes : Test(4) {
	my ($self) = @_;
	my $value = ['ACC="MI0003559"','ID="hsa-mir-554"'];
	my $expected = {
		'ACC'  => 'MI0003559',
		'ID'   => 'hsa-mir-554'
	};
	$self->deep_attribute_test('attributes', $value, $expected);
}

sub comment : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('comment', 'This is a comment', 'This is a comment');
}

sub length : Test(2) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'length';
	
	$obj->set_start(151518272);
	$obj->set_stop(151518367);
	is $obj->length, 96, "... and should return the correct value";
}

sub strand_symbol : Test(5) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'strand_symbol';
	
	is $obj->strand_symbol, undef, "... and should return the correct value";
	
	$obj->set_strand('+');
	is $obj->strand_symbol, '+', "... and should return the correct value again";
	
	$obj->set_strand('-');
	is $obj->strand_symbol, '-', "... and again";
	
	$obj->set_strand('.');
	is $obj->strand_symbol, '.', "... and again";
}

sub attribute : Test(4) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'attribute';
	
	$obj->set_attributes(['ACC="MI0003559"','ID="hsa-mir-554"']);
	is $obj->attribute(), undef, "... and should return the correct value";
	is $obj->attribute('ACC'), 'MI0003559', "... and should return the correct value again";
	is $obj->attribute('ID'), 'hsa-mir-554', "... and again";
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################


1;
