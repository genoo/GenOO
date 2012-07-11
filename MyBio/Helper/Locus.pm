# POD documentation - main docs before the code

=head1 NAME

MyBio::Helper::Locus - Helper functions which could not fit in MyBio::Locus class

=head1 SYNOPSIS

    # Implements methods that could not fit in any of the other classes.
    # Usually, implemented functions act on a set of objects and
    # return another loci set with specific characteristics.

=head1 DESCRIPTION

    Implements methods that could not fit in any of the other classes.
    Usually, implemented functions act on a set of objects and
    return another loci set with specific characteristics.

=head1 EXAMPLES

    my @merged_loci = MyBio::Helper::Locus::merge(\@overlapping_loci);

=head1 AUTHOR - Manolis Maragkakis

Email em.maragkakis@gmail.com

=cut

# Let the code begin...

package MyBio::Helper::Locus;
use strict;

use MyBio::Locus;

=head2 merge
  Arg [1]    : array reference of MyBio::Locus objects or objects that inherit from this class.
               The loci to be merged.
  Arg [2]    : hash reference with parameters
               Supported params:
                                a. OFFSET
                                b. USE_STRAND
  Example    : my ($merged_loci,$included_loci) = MyBio::Helper::Locus::merge(\@overlapping_loci, $params);
  Description: Function that gets as input a set of possibly overlapping loci and returns a new array of merged loci.
               When called in list context it also returns an array whose each element is a list of the initial loci which have been
               merged into the corresponding output merged locus. It merges overlapping loci into a new locus by calculating as start
               the smallest start and as stop the highest stop position of the loci that overalap.
               If any of the entries in the input list is not a MyBio::Locus it invokes a warning and skips the corresponding entry.
               
  Returntype : In scalar context:
                    [MyBio::Locus] / []
               In list context:
                    [MyBio::Locus] / []
                    [[MyBio::Locus]] / []
  Caller     : ?
  Status     : Development
=cut
sub merge {
	my ($loci_ref, $params) = @_;
	
	my $offset = exists $params->{'OFFSET'} ? $params->{'OFFSET'} : 0;
	my $use_strand = exists $params->{'USE_STRAND'} ? $params->{'USE_STRAND'} : 1;
	
	my @sorted_loci = (@$loci_ref > 1) ? sort{$a->start <=> $b->start} @$loci_ref : @$loci_ref;
	
	my @merged_loci;
	my @included_loci;
	foreach my $locus (@sorted_loci) {
		if ($locus->isa('MyBio::Locus')) {
			my $merged_locus = $merged_loci[-1];
			if (defined $merged_locus and $merged_locus->overlaps($locus,{OFFSET=>$offset, USE_STRAND=>$use_strand})) {
				if (wantarray) {
					push @{$included_loci[-1]}, $locus;
				}
				if ($locus->stop() > $merged_locus->stop) {
					$merged_locus->set_stop($locus->stop);
				}
			}
			else {
				push @merged_loci,MyBio::Locus->new($locus);
				if (wantarray) {
					push @included_loci,[$locus];
				}
			}
		}
		else {
			warn 'Object "'.ref($locus).'" is not MyBio::Locus and is skipped ';
		}
	}
	
	if (wantarray) {
		return (\@merged_loci, \@included_loci);
	}
	else {
		return \@merged_loci;
	}
	
}


1;
