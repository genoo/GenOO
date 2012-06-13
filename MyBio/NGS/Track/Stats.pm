# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::Track::Stats - Object for managing statistics for a MyBio::NGS::Track

=head1 SYNOPSIS

    # Object that offers methods calculating statistics for a MyBio::NGS::Track. 

    # To initialize (NOTE: Should not be instantiated ONLY through a track object)
    my $track_stats = MyBio::NGS::Track::Stats->new({
        COLLECTION            => undef,
    });


=head1 DESCRIPTION

    This class offers methods for calculating several statistical measures for a Track. It does not
    make any assumpions for the internal data structure of the Track. Note that it should not be
    instantiated by itself but rather through a track object. The reason is that it weakens the reference
    to the track and therefore when the track falls out of scope even though the stats object is still
    within scope the internal structure is corrupted.

=head1 EXAMPLES

    # Calculate the sum of the scores in the track
    $track_stats->get_or_calculate_score_sum();
    
    # Calculate the mean of the scores in the track
    $track_stats->get_or_calculate_score_mean();
    
    # Calculate the stdv of the scores in the track
    $track_stats->get_or_calculate_score_stdv();

=cut

# Let the code begin...

package MyBio::NGS::Track::Stats;
use strict;
use Scalar::Util qw/weaken/;

use base qw(MyBio::LocusCollection::Stats);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	$self->init_stats;
	
	return $self;
}

#######################################################################
#############################   Setters   #############################
#######################################################################

#######################################################################
#############################   Getters   #############################
#######################################################################

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub init_stats {
	my ($self) = @_;
	$self->SUPER::init_stats();
}

sub reset {
	my ($self) = @_;
	
	$self->SUPER::reset();
	$self->{SCORE_SUM} = undef;
	$self->{SCORE_MEAN} = undef;
	$self->{SCORE_VARIANCE} = undef;
}

sub get_or_calculate_score_sum {
	my ($self) = @_;
	
	if (!defined $self->{SCORE_SUM}) {
		$self->calculate_score_sum_and_mean;
	}
	return $self->{SCORE_SUM};
}

sub get_or_calculate_score_mean {
	my ($self) = @_;
	
	if (!defined $self->{SCORE_MEAN}) {
		$self->calculate_score_sum_and_mean;
	}
	return $self->{SCORE_MEAN};
}

sub get_or_calculate_score_variance {
	my ($self) = @_;
	
	if (!defined $self->{SCORE_VARIANCE}) {
		$self->calculate_score_variance;
	}
	return $self->{SCORE_VARIANCE};
}

sub get_or_calculate_score_stdv {
	my ($self) = @_;
	
	if (!defined $self->{SCORE_VARIANCE}) {
		$self->calculate_score_variance;
	}
	return sqrt($self->{SCORE_VARIANCE});
}

sub calculate_score_sum_and_mean {
	my ($self) = @_;
	
	if ($self->collection_is_not_empty) {
		my $score_sum = 0;
		my $iterator = $self->get_collection->entries_iterator;
		while (my $entry = $iterator->next) {
			if (defined $entry->get_score) {
				$score_sum += $entry->get_score;
			}
			else {
				$self->{SCORE_SUM} = undef;
				$self->{SCORE_MEAN} = undef;
				return;
			}
		}
		
		$self->{SCORE_SUM} = $score_sum;
		$self->{SCORE_MEAN} = $score_sum / $self->entries_count;
	}
}

sub calculate_score_variance {
	my ($self) = @_;
	
	if ($self->collection_is_not_empty) {
		my $score_sum_sq_diff = 0;
		my $mean = $self->get_or_recalculate_score_mean;
		my $iterator = $self->get_collection->entries_iterator;
		while (my $entry = $iterator->next) {
			if (defined $entry->get_score) {
				$score_sum_sq_diff += ($entry->get_score - $mean) ** 2;
			}
			else {
				$self->{SCORE_VARIANCE} = undef;
				return;
			}
		}
		
		$self->{SCORE_VARIANCE} = $score_sum_sq_diff / $self->entries_count;
	}
}

1;
