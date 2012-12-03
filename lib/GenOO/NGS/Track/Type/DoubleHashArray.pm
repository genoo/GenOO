# POD documentation - main docs before the code

=head1 NAME

GenOO::NGS::Track::Type::DoubleHashArray - Object for a collection of GenOO::NGS::Tag objects, with features

=head1 SYNOPSIS

    # Object that manages a collection of L<GenOO::NGS::Tag> objects. 

    # To initialize 
    my $track = GenOO::NGS::Track->new({
        name         => undef,
        species      => undef,
        description  => undef,
        extra        => undef,
    });


=head1 DESCRIPTION

    The primary data structure of this object is a 2D hash whose primary key is the strand 
    and its secondary key is the chromosome name. Each such pair of keys correspond to an
    array reference which stores objects of the class L<GenOO::NGS::Tag> sorted by start position.

=head1 EXAMPLES

    
=cut

# Let the code begin...

package GenOO::NGS::Track::Type::DoubleHashArray;

use Moose;
use namespace::autoclean;

use GenOO::NGS::Tag;
use GenOO::NGS::Track::Stats;

extends 'GenOO::RegionCollection::Type::DoubleHashArray';

has '_stats' => (
	is => 'ro',
	builder => '_build_stats',
	init_arg => undef,
	lazy => 1
);

with 'GenOO::NGS::Track';

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub add_record {
	my ($self, $record) = @_;
	$self->_container->add_entry($record->strand, $record->chromosome, $record);
	$self->_reset;
}

after 'add_record' => sub {
	my ($self) = @_;
	$self->_reset_stats;
};

sub get_scores_for_all_records {
	my ($self) = @_;
	
	my @out = ();
	$self->foreach_record_do( sub {
		my ($record) = @_;
		push @out, $record->score;
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

sub quantile {
	my ($self, $params) = @_;
	
	my $quantile = 25;
	my $score_threshold = 0;
	if (exists $params->{'QUANTILE'}){$quantile = $params->{'QUANTILE'};}
	if (exists $params->{'THRESHOLD'}){$score_threshold = $params->{'THRESHOLD'};}
	my @scores = sort {$b <=> $a} $self->get_scores_for_all_records;
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
	
	$self->{STATS} = GenOO::NGS::Track::Stats->new({
		TRACK => $self
	}); 
}

sub _reset_stats {
	my ($self) = @_;
	$self->_stats->reset; 
}

#######################################################################
#######################   Deprecated Methods   ########################
#######################################################################
sub get_scores_for_all_entries {
	my ($self) = @_;
	warn 'Deprecated method "get_scores_for_all_entries". Use "get_scores_for_all_records" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->get_scores_for_all_records;
}


__PACKAGE__->meta->make_immutable;
1;
