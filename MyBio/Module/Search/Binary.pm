# POD documentation - main docs before the code

=head1 NAME

MyBio::Module::Search::Binary - Module that offers methods for searching in an array using binary search

=head1 SYNOPSIS

    use MyBio::Module::Search::Binary
    my $pos = MyBio::Module::Search::Binary->binary_search_for_value_greater_or_equal(3.2, [0,1,2,3,4,4,4,5,6], sub {return $_[0]});


=head1 DESCRIPTION

    Implements binary search algorithms for scanning an array.
    
=cut

# Let the code begin...

package MyBio::Module::Search::Binary;
use strict;


=head2 binary_search_for_value_greater_or_equal
  Arg [1]    : number. The target value
  Arg [2]    : array reference. Array in which the target value is searched.
               No assumption is made about the entries in the array and how to extract the actual values from them.
               The array must be sorted by value though.
  Arg [3]    : code reference. Code that extracts the actual value given an entry of the array
  Example    : binary_search_for_value_greater_or_equal(3.2, [0,1,2,3,4,4,4,5,6], sub {return $_[0]}) 
  Description: Implements a binary search algorithm returning the I<position> of the first I<entry>
               whose I<value> is greater than or equal to C<target value>. The search routine does
               not make any assumption about the entries in the array, but leaves the implementation
               to the user supplied code function. 
               During the search the user supplied code function will be called with a single arguments:
               an entry of the array and should return the value that corresponds to this entry.
  Return     : Integer index of the first entry whose value is greater or equal to the target value
=cut
sub binary_search_for_value_greater_or_equal {
	my ($class, $target_value, $sorted_array, $code) = @_;           
	
	my $index;
	my $low_index = 0;
	my $up_index = $#{$sorted_array};
	
	while ($low_index <= $up_index) {
		
		$index = int(($low_index + $up_index) / 2);
		
		if ($code->($sorted_array->[$index]) < $target_value) {
			$low_index = $index+1; # move to the up half
		}
		elsif ($code->($sorted_array->[$index]) > $target_value) {
			$up_index = $index-1; # move to the low half
		} 
		else {
			# exact match found -> search upstream for the first of the exact matches
			while (($index-1 >= 0) and ($code->($sorted_array->[$index-1]) == $target_value)) {
				$index--;
			}
			last;
		}
		
	}
	
	# check if got outside the array without finding a bigger value than the one requested
	if ($low_index > $#{$sorted_array}) {
		return undef;
	}
	
	# under certain conditions index might point to the value immediatelly preceding the greater value
	if ($code->($sorted_array->[$index]) < $target_value) {
		if (($index+1 <= $#{$sorted_array}) and ($code->($sorted_array->[$index+1]) > $target_value)) {
			$index++;
		}
		return $index;
	}
	
	return $index;
}

1;
