# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::Track::Type::DoubleHashArray - Object for a collection of MyBio::NGS::Tag objects, with features

=head1 SYNOPSIS

    # Object that manages a collection of L<MyBio::NGS::Tag> objects. 

    # To initialize 
    my $track = MyBio::NGS::Track->new({
        name         => undef,
        species      => undef,
        description  => undef,
        extra        => undef,
    });


=head1 DESCRIPTION

    The primary data structure of this object is a 2D hash whose primary key is the strand 
    and its secondary key is the chromosome name. Each such pair of keys correspond to an
    array reference which stores objects of the class L<MyBio::NGS::Tag> sorted by start position.

=head1 EXAMPLES

    
=cut

# Let the code begin...

package MyBio::NGS::Track::Type::DoubleHashArray;

use Moose;
use namespace::autoclean;

use MyBio::NGS::Tag;
use MyBio::NGS::Track::Stats;

extends 'MyBio::RegionCollection::Type::DoubleHashArray';

has '_stats' => (
	is => 'ro',
	builder => '_build_stats',
	init_arg => undef,
	lazy => 1
);

with 'MyBio::NGS::Track';

#######################################################################
########################   Interface Methods   ########################
#######################################################################
after 'add_entry' => sub {
	my ($self) = @_;
	$self->_reset_stats;
};

sub get_scores_for_all_entries {
	my ($self) = @_;
	
	my @out = ();
	$self->foreach_entry_do( sub {
		my ($entry) = @_;
		push @out, $entry->score;
	});
	return @out;
}

sub score_sum {
	my ($self) = @_;
	return $self->_stats->get_or_calculate_score_sum;
}

sub score_mean {
	my ($self) = @_;
	return $self->_stats->get_or_calculate_score_mean;
}

sub score_variance {
	my ($self) = @_;
	return $self->_stats->get_or_calculate_score_variance;
}

sub score_stdv {
	my ($self) = @_;
	return $self->_stats->get_or_calculate_score_stdv;
}


#### Normalization Methods ####
sub normalize {
	my ($self, $params) = @_;
	
	my $scaling_factor = 1;
	my $normalization_factor = $self->get_entry_score_sum;
	if (exists $params->{'SCALE'}){$scaling_factor = $params->{'SCALE'};}
	if (exists $params->{'NORMALIZATION_FACTOR'}){$normalization_factor = $params->{'NORMALIZATION_FACTOR'};}
	my $entries_ref = $self->get_entries;
	foreach my $strand (keys %{$entries_ref}) {
		foreach my $chr (keys %{$$entries_ref{$strand}}) {
			if (exists $$entries_ref{$strand}{$chr}) {
				foreach my $entry (@{$$entries_ref{$strand}{$chr}})
				{
					my $normal_score = ($entry->get_score / $normalization_factor) * $scaling_factor;
					$entry->score($normal_score);
				}
			}
		}
	}
}

sub quantile {
	my ($self, $params) = @_;
	
	my $quantile = 25;
	my $score_threshold = 0;
	if (exists $params->{'QUANTILE'}){$quantile = $params->{'QUANTILE'};}
	if (exists $params->{'THRESHOLD'}){$score_threshold = $params->{'THRESHOLD'};}
	my @scores = sort {$b <=> $a} $self->get_scores_for_all_entries;
	my $size;
	for ($size = 0; $size < @scores; $size++)
	{
		if ($scores[$size] < $score_threshold){last;}
	}
	my $index = int($size * ($quantile/100));
	warn "idx: $index\n";
	return $scores[$index];
}

#######################################################################
#########################   Private methods  ##########################
#######################################################################
sub _build_stats {
	my ($self) = @_;
	
	$self->{STATS} = MyBio::NGS::Track::Stats->new({
		TRACK => $self
	}); 
}

sub _reset_stats {
	my ($self) = @_;
	$self->_stats->reset; 
}


__PACKAGE__->meta->make_immutable;
1;
