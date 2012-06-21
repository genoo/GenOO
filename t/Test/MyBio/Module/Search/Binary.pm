package Test::MyBio::Module::Search::Binary;
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
sub binary_search_for_value_greater_or_equal : Test(28) {
	my ($self) = @_;
	
	can_ok $self->class, 'binary_search_for_value_greater_or_equal';
	
	my $code = sub {
		return $_[0]
	};
	
	my $data = [1];
	is $self->class->binary_search_for_value_greater_or_equal(0, $data, $code), 0, "... and should return the correct value";
	is $self->class->binary_search_for_value_greater_or_equal(1, $data, $code), 0, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(1.1, $data, $code), undef, "... and again";
	
	$data = [1,2];
	is $self->class->binary_search_for_value_greater_or_equal(0, $data, $code), 0, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(1, $data, $code), 0, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(1.1, $data, $code), 1, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(2, $data, $code), 1, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(2.1, $data, $code), undef, "... and again";
	
	$data = [1,2,2];
	is $self->class->binary_search_for_value_greater_or_equal(0, $data, $code), 0, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(1, $data, $code), 0, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(1.1, $data, $code), 1, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(2, $data, $code), 1, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(2.1, $data, $code), undef, "... and again";
	
	$data = [1,2,2,pad(4,6)];
	is $self->class->binary_search_for_value_greater_or_equal(0, $data, $code), 0, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(1, $data, $code), 0, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(1.1, $data, $code), 1, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(2, $data, $code), 1, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(2.1, $data, $code), 3, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(4, $data, $code), 3, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(5, $data, $code), undef, "... and again";
	
	$data = [1, 2, 3, pad(4,6), 5, 6, 7];
	is $self->class->binary_search_for_value_greater_or_equal(0, $data, $code), 0, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(1, $data, $code), 0, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(3.5, $data, $code), 3, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(4, $data, $code), 3, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(5.5, $data, $code), 10, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(7, $data, $code), 11, "... and again";
	is $self->class->binary_search_for_value_greater_or_equal(10, $data, $code), undef, "... and again";
	
	
}


#######################################################################
##########################   Helper Methods   #########################
#######################################################################
=head2 pad
  Arg [1]    : $num: number. The number to be repeated
  Arg [2]    : $count: int. The number of repetitions
  Example    : pad(4,6) # gives (4,4,4,4,4,4) 
  Description: Creates an array of $count copies of the number $num
  Return     : Array
=cut
sub pad {
	my ($num, $count) = @_;
	return split(//,$num x $count);
}

1;
