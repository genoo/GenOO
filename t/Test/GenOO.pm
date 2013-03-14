package Test::GenOO;

use Modern::Perl;

use base 'Test::Class';
use Test::More;

INIT { Test::Class->runtests }

#######################################################################
###########################   Class Methods   #########################
#######################################################################
sub class {
	my ($self) = @_;
	
	(my $class = ref($self) || $self) =~ s/^Test:://;
	return $class;
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self, $index) = @_;
	
	return $self->{TEST_OBJECTS}->[$index];
}

sub objs {
	my ($self) = @_;
	
	return @{$self->{TEST_OBJECTS}};
}

#######################################################################
######################   Deprecated Test Methods   ####################
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
