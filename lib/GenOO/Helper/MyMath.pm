# POD documentation - main docs before the code

=head1 NAME

GenOO::Helper::MyMath - A collection of useful mathematical methods

=head1 SYNOPSIS

    A collection of useful mathematical methods
    
=head1 DESCRIPTION

    This class contains useful mathematical methods such as mean, round_digits, sigmoid, min, max, glog

=head1 EXAMPLES

    #mean
    my @array = [0,20,100];
    my $mean = GenOO::Helper::MyMath->mean(\@array); #returns mean (40)

    #round_digits
    my $number = 1.012345;
    my $rounded = GenOO::Helper::MyMath->round_digits($number,2); #returns (1.01)
        
=cut

# Let the code begin...

package GenOO::Helper::MyMath;

use strict;

our $VERSION = '1.0';

sub mean {
# Calculates the mean of the values in an array
	my ($array_ref) = @_;
	my $n=0;
	my $result=0;
	my $sum=0;

	unless (defined $array_ref) {
		warn "undefined array reference in sub mean\n";
		return undef;
	}

	foreach my $item (@$array_ref) {
		unless (defined $item) {next;}
		$sum += $item;
		$n++;
	}
	if ($n==0) {return undef;}

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

sub max {
# Calculates the max of the values in an array
	my ($array_ref) = @_;
	my $max_value;
	my $max_index;
	
	unless (defined $array_ref) {
		warn "undefined array reference in sub max\n";
		return (undef,undef);
	}

	for (my $i=0;$i<@{$array_ref};$i++) {
		if (defined $$array_ref[$i]) {
			if ((!defined $max_value) or ($$array_ref[$i] > $max_value)) {
				$max_value = $$array_ref[$i];
				$max_index = $i;
			}
		}
	}
	
	return ($max_index,$max_value);
}

sub min {
# Calculates the min of the values in an array
	my ($array_ref) = @_;
	my $min_value;
	my $min_index;
	
	unless (defined $array_ref) {
		warn "undefined array reference in sub min\n";
		return (undef,undef);
	}

	for (my $i=0;$i<@{$array_ref};$i++) {
		if (defined $$array_ref[$i]) {
			if ((!defined $min_value) or ($$array_ref[$i] < $min_value)) {
				$min_value = $$array_ref[$i];
				$min_index = $i;
			}
		}
	}
	
	return ($min_index,$min_value);
}

sub glog {
	my ($value) = @_;
	my $glog = log($value + sqrt(1 + $value**2))/log(2);
}

1;
