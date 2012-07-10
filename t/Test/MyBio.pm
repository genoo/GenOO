package Test::MyBio;
use strict;

INIT { Test::Class->runtests }

use base qw(Test::Class);
use Test::More;

sub class {
	my ($self) = @_;
	(my $class = ref($self) || $self) =~ s/^Test:://;
	return $class;
}

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

sub get_input_for {
	my ($self, $attribute) = @_;
	return ($self->data->{$attribute}->{INPUT});
}

sub get_output_for {
	my ($self, $attribute) = @_;
	return ($self->data->{$attribute}->{OUTPUT});
}

1;
