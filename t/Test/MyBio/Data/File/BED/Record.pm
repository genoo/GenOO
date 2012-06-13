package Test::MyBio::Data::File::BED::Record;
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
	
	isa_ok $self->class->new($data), $self->class, "... and the object";
}

sub chr : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('chr', 'chr7', 'chr7');
}

sub start : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('start', 127471196, 127471196);
}

sub stop : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('stop', 127472363, 127472362);
}

sub strand : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('strand', '+', 1);
}

sub thick_start : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('thick_start', 127471196, 127471196);
}

sub thick_stop : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('thick_stop', 127472363, 127472362);
}

sub rgb : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('rgb', '255,0,0', '255,0,0');
}

sub block_count : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('block_count', 2, 2);
}

sub block_sizes : Test(4) {
	my ($self) = @_;
	$self->deep_attribute_test('block_sizes', [100,200], [100,200]);
}

sub block_starts : Test(4) {
	my ($self) = @_;
	$self->deep_attribute_test('block_starts', [0, 900], [0, 900]);
}


sub length : Test(2) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'length';
	
	$obj->set_start(127471196);
	$obj->set_stop(127472363);
	is $obj->length, 1167, "... and should return the correct value";
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
	is $obj->strand_symbol, undef, "... and again";
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################

sub simple_attribute_test {
	my ($self,$attribute,$value,$expected) = @_;
	
	my $get = $attribute;
	my $set = 'set_'.$attribute;
	
	my $obj = $self->class->new;
	
	can_ok $obj, $get;
	ok !defined $obj->$get, "... and $attribute should start as undefined";
	
	can_ok $obj, $set;
	$obj->$set($value);
	is $obj->$get, $expected, "... and setting its value should succeed";
}

sub deep_attribute_test {
	my ($self,$attribute,$value,$expected) = @_;
	
	my $get = $attribute;
	my $set = 'set_'.$attribute;
	
	my $obj = $self->class->new;
	
	can_ok $obj, $get;
	ok !defined $obj->$get, "... and $attribute should start as undefined";
	
	can_ok $obj, $set;
	$obj->$set($value);
	is_deeply $obj->$get, $expected, "... and setting its value should succeed";
}
1;
