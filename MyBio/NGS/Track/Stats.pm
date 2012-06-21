# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::Track::Stats - Object for managing statistics for a MyBio::NGS::Track

=head1 SYNOPSIS

    # Object that offers methods calculating statistics for a MyBio::NGS::Track. 

    # To initialize (NOTE: Should ONLY be instantiated through the track class)
    my $track_stats = MyBio::NGS::Track::Stats->new({
        TRACK            => undef,
    });


=head1 DESCRIPTION

    This class offers methods for calculating several statistical measures for a Track. It does not
    make any assumpions for the internal data structure of the Track. Note that it should not be
    instantiated by itself but rather through a track object. The reason is that it weakens the
    reference to the track and therefore when the track falls out of scope even though the stats
    object is still within scope the internal structure is corrupted.

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

use base qw(MyBio::_Initializable);

sub _init {
	my ($self,$data) = @_;
	
	$self->set_track($$data{TRACK});
	
	return $self;
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_track {
	my ($self, $value) = @_;
	if (defined $value) {
		$self->{TRACK} = $value;
		weaken($self->{TRACK});
	}
}

#######################################################################
############################   Accessors  #############################
#######################################################################
sub track {
	my ($self) = @_;
	return $self->{TRACK};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub reset {
	my ($self) = @_;
	
	delete $self->{SCORE_SUM};
	delete $self->{SCORE_MEAN};
	delete $self->{SCORE_VARIANCE};
}

sub get_or_calculate_score_sum {
	my ($self) = @_;
	
	if (!defined $self->{SCORE_SUM}) {
		$self->calculate_and_set_score_sum_and_mean;
	}
	return $self->{SCORE_SUM};
}

sub get_or_calculate_score_mean {
	my ($self) = @_;
	
	if (!defined $self->{SCORE_MEAN}) {
		$self->calculate_and_set_score_sum_and_mean;
	}
	return $self->{SCORE_MEAN};
}

sub get_or_calculate_score_variance {
	my ($self) = @_;
	
	if (!defined $self->{SCORE_VARIANCE}) {
		$self->calculate_and_set_score_variance;
	}
	return $self->{SCORE_VARIANCE};
}

sub get_or_calculate_score_stdv {
	my ($self) = @_;
	
	if (!defined $self->{SCORE_VARIANCE}) {
		$self->calculate_and_set_score_variance;
	}
	return sqrt($self->{SCORE_VARIANCE});
}

sub calculate_and_set_score_sum_and_mean {
	my ($self) = @_;
	
	my $score_sum = 0;
	$self->track->foreach_entry_do(
		sub {
			my ($entry) = @_;
			
			if (defined $entry->get_score) {
				$score_sum += $entry->get_score;
			}
			else {
				warn "score is not defined and sum and mean cannot be calculated";
				delete $self->{SCORE_SUM};
				delete $self->{SCORE_MEAN};
				return;
			}
		}
	);
	$self->{SCORE_SUM} = $score_sum;
	$self->{SCORE_MEAN} = $score_sum / $self->track->entries_count;
}

sub calculate_and_set_score_variance {
	my ($self) = @_;
	
	my $score_sum_sq_diff = 0;
	my $score_mean = $self->get_or_calculate_score_mean;
	$self->track->foreach_entry_do(
		sub {
			my ($entry) = @_;
			
			if (defined $entry->get_score) {
				$score_sum_sq_diff += ($entry->get_score - $score_mean) ** 2;
			}
			else {
				warn "score is not defined and variance cannot be calculated";
				delete $self->{SCORE_VARIANCE};
				return;
			}
		}
	);
	$self->{SCORE_VARIANCE} = $score_sum_sq_diff / $self->track->entries_count;
}

1;
