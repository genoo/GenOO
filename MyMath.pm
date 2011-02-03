package MyMath;

# Contains useful mathematical functions

use warnings;
use strict;

our $VERSION = '1.0';

sub mean {
# Calculates the mean of the values in an array
	my ($array_ref) = @_;
	my $n=0;
	my $result=0;
	my $sum=0;

	unless (defined $array_ref) {
		print "undefined array reference in sub mean\n";
		return 0;
	}

	foreach my $item (@$array_ref) {
		unless (defined $item) {next;}
		$sum += $item;
		$n++;
	}
	if ($n==0) {return 0;}

	$result = $sum/$n;
	return $result;
}

sub round_digits {
	my ($num,$digits) = @_;
	
	my $decimal = 10**$digits;
	my $rounded = (int($num*$decimal))/$decimal;
	return $rounded;
}

sub sigmoid {
	return 1/(1+exp(-$_[1]));
}

1;