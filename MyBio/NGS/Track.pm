# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::Track - Role for a collection of MyBio::NGS::Tag objects

=head1 SYNOPSIS

    # This role defines the interface for collections of L<MyBio::NGS::Tag> objects
    # and cannot be initialized


=head1 DESCRIPTION

    This role defines the interface for collections of L<MyBio::NGS::Tag> objects.
    All required attributes and subs must be present in classes that consume
    this role.

=cut

# Let the code begin...

package MyBio::NGS::Track;

use Moose::Role;
use namespace::autoclean;

with 'MyBio::RegionCollection';

requires qw ( 
	get_scores_for_all_entries
	score_sum
	score_mean
	score_variance
	score_stdv
	quantile
);

1;
