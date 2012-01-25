# POD documentation - main docs before the code

=head1 NAME

MyBio::Transcript::Region - A functional region within a transcript consisting of spicing elements, with features

=head1 SYNOPSIS

    # This is the main region object.
    # Represents a functional region within
    # a transcript eg 3'UTR, CDS or 5'UTR
    # It supports splicing.
    
    # To initialize 
    my $region = MyBio::Transcript::Region->new({
        SPECIES      => undef,
        STRAND       => undef,
        CHR          => undef,
        START        => undef,
        STOP         => undef,
        SEQUENCE     => undef,
        NAME         => undef,
        TRANSCRIPT       => undef,
        SPLICE_STARTS    => undef,
        SPLICE_STOPS     => undef,
        SEQUENCE         => undef,
        ACCESSIBILITY    => undef,
    });

=head1 DESCRIPTION

    Not provided yet

=head1 EXAMPLES

    Not provided yet

=head1 AUTHOR - Manolis Maragkakis, Panagiotis Alexiou

Email em.maragkakis@gmail.com, pan.alexiou@fleming.gr

=cut

# Let the code begin...

package MyBio::Transcript::Region;

use strict;
use Scalar::Util qw/weaken/;

use MyBio::Transcript::Exon;
use MyBio::Transcript::Intron;

our $VERSION = '2.0';

use base qw(MyBio::Locus);

sub _init {
	my ($self,$data) = @_;
	warn "HERE\n";
	$self->SUPER::_init($data);
	$self->set_transcript($$data{TRANSCRIPT});  #Transcript
	warn "HERE\n";
	$self->set_splice_starts($$data{SPLICE_STARTS});  # [] reference to array of splice starts
	$self->set_splice_stops($$data{SPLICE_STOPS});  # [] reference to array of splice stops
	warn "HERE\n";
	$self->set_exons($$data{EXONS}); # [] reference to an array of locus objects (exons)
	warn "HERE\n";
	$self->set_extra($$data{EXTRA_INFO});
	warn "HERE\n";
	$self->set_accessibility($$data{ACCESSIBILITY});
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_transcript {
	return $_[0]->{TRANSCRIPT};
}
sub get_extra {
	return $_[0]->{EXTRA_INFO};
}
sub get_accessibility {
	return $_[0]->{ACCESSIBILITY};
}
sub get_splice_starts {
	if (defined $_[1]) {
		return ${$_[0]->{SPLICE_STARTS}}[$_[1]];
	}
	elsif (defined $_[0]->{SPLICE_STARTS}) {
		return $_[0]->{SPLICE_STARTS}; # return the reference to the array with the splice starts
	}
	else {
		[];
	}
}
sub get_splice_stops {
	if (defined $_[1]) {
		return ${$_[0]->{SPLICE_STOPS}}[$_[1]];
	}
	elsif (defined $_[0]->{SPLICE_STOPS}) {
		return $_[0]->{SPLICE_STOPS}; # return the reference to the array with the splice stops
	}
	else {
		[];
	}
}
sub get_exons {
	my ($self,$value) = @_;
	if (!defined $self->{EXONS}) {
		$self->set_exons(); # try to set the exons first
	}
	
	if (defined $value) {
		if (defined $self->{EXONS}) {
			return ${$self->{EXONS}}[$value];
		}
		else {
			return undef;
		}
	}
	elsif (defined $self->{EXONS}) {
		return $self->{EXONS};
	}
	else {
		return [];
	}
}

sub get_introns {
	my ($self,$value) = @_;
	if (!defined $self->{INTRONS}) {
		$self->set_introns(); # try to set the introns
	}
	
	if (defined $value) {
		if (defined $self->{INTRONS}) {
			return ${$self->{INTRONS}}[$value];
		}
		else {
			return undef;
		}
	}
	elsif (defined $self->{INTRONS}) {
		return $self->{INTRONS};
	}
	else {
		return [];
	}
}

sub get_intron_exon_junctions {
	my $self = $_[0];
	my @junctions = ();
	unless (@{$self->get_exons} > 1) { return \@junctions; }
	
	if ((!defined $self->get_start) or (!defined $self->get_stop)) {warn "$self !defined start: $self->get_start or stop: $self->get_stop!\n"; return \@junctions; }
	
	foreach my $exon (@{$self->get_exons})
	{		
		my $jun = MyBio::Locus->new({
				STRAND       => $exon->get_strand,
				CHR          => $exon->get_chr,
				START        => $exon->get_start-1,
				STOP         => $exon->get_start-1,
			});
		if ($jun->get_start != $self->get_start-1){push @junctions, $jun;}
		
		my $jun2 = MyBio::Locus->new({
				STRAND       => $exon->get_strand,
				CHR          => $exon->get_chr,
				START        => $exon->get_stop,
				STOP         => $exon->get_stop,
			});
		if ($jun2->get_start != $self->get_stop){push @junctions, $jun2;}
	}
	return \@junctions;
}


sub get_length {
	my ($self) = @_;
	if (!defined $self->{LENGTH}) {
		if (defined $self->get_sequence) {
			$self->{LENGTH} = length($self->get_sequence);
		}
		else {
			$self->{LENGTH} = $self->_get_sequence_length_from_splicing();
		}
	}
	return $self->{LENGTH};
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_extra {
	$_[0]->{EXTRA_INFO} = $_[1] if defined $_[1];
}
sub set_transcript {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{TRANSCRIPT} = $value;
		weaken($self->{TRANSCRIPT}); # circular reference needs to be weakened to avoid memory leaks
	}
}
sub set_splice_starts {
	my ($self,$value) = @_;
	if (defined $value) {
		my @splice_starts = (sort {$a <=> $b} (split(/\D+/,$value)));
		$self->{SPLICE_STARTS} = \@splice_starts;
	}
}
sub set_splice_stops {
	my ($self,$value) = @_;
	if (defined $value) {
		my @splice_stops = (sort {$a <=> $b} (split(/\D+/,$value)));
		$self->{SPLICE_STOPS} = \@splice_stops;
	}
}
sub set_exons {
	my ($self,$value) = @_;
	warn "hey";
	if (defined $value) {
		@$value = sort {$a->get_start <=> $b->get_start} @$value;
		$self->{EXONS} = $value;
	}
	elsif (defined $self->{SPLICE_STARTS} and defined $self->{SPLICE_STOPS}) {
		warn "MPIKA\n";
		$self->_set_exons_from_splicing();
	}
	elsif ((@{$self->get_transcript->get_exons} > 0) and defined $self->get_start and defined $self->get_stop) {
		warn "MPIKA\n";
		$self->_set_exons_from_transcript_exons();
	}
	warn "hey";
}

sub set_introns {
	my ($self,$value) = @_;
	if (defined $value) {
		@$value = sort {$a->get_start <=> $b->get_start} @$value;
		$self->{INTRONS} = $value;
	}
	elsif (defined $self->{SPLICE_STARTS} and defined $self->{SPLICE_STOPS}) {
		warn "MPIKA\n";
		$self->_set_introns_from_splicing();
	}
	elsif ((@{$self->get_exons} > 0)) {
		warn "MPIKA\n";
		$self->_set_introns_from_exons();
	}
	elsif ((@{$self->get_transcript->get_introns} > 0) and defined $self->get_start and defined $self->get_stop) {
		$self->_set_introns_from_transcript_introns();
	}
}


=head2 set_accessibility

  Arg [1]    : string $accessibilityVar
               A string with accesibility values per nucleotide separated by pipes "|"
  Example    : set_accessibility("0.1|0.9|0.5|0.4|0.3") # for a Transcript::Region of length 5
  Description: Sets the accessibility attribute for the transcript region.
  Returntype : NULL
  Caller     : ?
  Status     : Under development

=cut
sub set_accessibility {
	my ($self,$accessibilityVar) = @_;
	
	if (defined $accessibilityVar) {
		my @accessibility = split(/\|/,$accessibilityVar);
		if (@accessibility != $self->get_length()) {
			warn $self->get_transcript->get_enstid().":\tAccessibility (".scalar @accessibility.") does not match sequence size (".$self->get_length().") in ".ref($self);
		}
		$self->{ACCESSIBILITY} = \@accessibility;
	}
	else {
		$self->{ACCESSIBILITY} = undef;
	}
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub _get_sequence_length_from_splicing {
#this routine calculates the sequence length based on the splicing
	my ($self) = @_;
	my $UTRlength=0;
	
	my @starts = @{$self->get_splice_starts()};
	my @stops  = @{$self->get_splice_stops()};
	
	for (my $i=0; $i<@starts; $i++)  {
		$UTRlength += $stops[$i] - $starts[$i]+1;
	}
	
	return $UTRlength;
}
sub _set_exons_from_splicing {
	my ($self) = @_;
	my $exon_starts = $self->get_splice_starts;
	my $exon_stops = $self->get_splice_stops;
	for (my $i=0;$i<@{$exon_starts};$i++) {
		$self->push_exon(MyBio::Transcript::Exon->new({
			SPECIES    => $self->get_transcript->get_species,
			STRAND     => $self->get_transcript->get_strand,
			CHR        => $self->get_transcript->get_chr,
			START      => ${$exon_starts}[$i],
			STOP       => ${$exon_stops}[$i],
			WHERE      => $self,
		}));
	}
}
sub _set_exons_from_transcript_exons {
	my ($self) = @_;
	my $exons = $self->get_contained_locuses($self->get_transcript->get_exons);
	foreach my $exon (@$exons) {
		$self->push_exon(MyBio::Transcript::Exon->new({
			SPECIES    => $self->get_transcript->get_species,
			STRAND     => $self->get_transcript->get_strand,
			CHR        => $self->get_transcript->get_chr,
			START      => $exon->get_start,
			STOP       => $exon->get_stop,
			WHERE      => $self,
		}));
	}
}
sub _set_introns_from_splicing {
	my ($self) = @_;
	warn "Method _set_introns_from_splicing has not been tested for bugs. Please check and remove warning";
	my $exon_starts = $self->get_splice_starts;
	my $exon_stops = $self->get_splice_stops;
	if ($self->get_start < $$exon_starts[0]) {
		$self->push_intron(MyBio::Transcript::Intron->new({
			SPECIES    => $self->get_transcript->get_species,
			STRAND     => $self->get_transcript->get_strand,
			CHR        => $self->get_transcript->get_chr,
			START      => $self->get_start,
			STOP       => $$exon_starts[0] - 1,
			WHERE      => $self,
		}));
	}
	for (my $i=1;$i<@{$exon_starts};$i++) {
		$self->push_intron(MyBio::Transcript::Intron->new({
			SPECIES    => $self->get_transcript->get_species,
			STRAND     => $self->get_transcript->get_strand,
			CHR        => $self->get_transcript->get_chr,
			START      => ${$exon_stops}[$i-1] + 1,
			STOP       => ${$exon_starts}[$i] - 1,
			WHERE      => $self,
		}));
	}
	if ($self->get_stop > $$exon_stops[-1]) {
		$self->push_intron(MyBio::Transcript::Intron->new({
			SPECIES    => $self->get_transcript->get_species,
			STRAND     => $self->get_transcript->get_strand,
			CHR        => $self->get_transcript->get_chr,
			START      => $$exon_stops[-1] + 1,
			STOP       => $self->get_stop,
			WHERE      => $self,
		}));
	}
}
sub _set_introns_from_transcript_introns {
	my ($self) = @_;
	warn "Method _set_introns_from_transcript_introns has not been tested for bugs. Please check and remove warning";
	my $introns = $self->get_contained_locuses($self->get_transcript->get_introns);
	foreach my $intron (@$introns) {
		$self->push_intron(MyBio::Transcript::Intron->new({
			SPECIES    => $self->get_transcript->get_species,
			STRAND     => $self->get_transcript->get_strand,
			CHR        => $self->get_transcript->get_chr,
			START      => $intron->get_start,
			STOP       => $intron->get_stop,
			WHERE      => $self,
		}));
	}
}
sub _set_introns_from_exons {
	my ($self) = @_;
	warn "Method _set_introns_from_exons has not been tested for bugs. Please check and remove warning";
	my $exons = $self->get_exons;
	if ($self->get_start < $$exons[0]->get_start) {
		$self->push_intron(MyBio::Transcript::Intron->new({
			SPECIES    => $self->get_transcript->get_species,
			STRAND     => $self->get_transcript->get_strand,
			CHR        => $self->get_transcript->get_chr,
			START      => $self->get_start,
			STOP       => $$exons[0]->get_start - 1,
			WHERE      => $self,
		}));
	}
	for (my $i=1;$i<@$exons;$i++) {
		$self->push_intron(MyBio::Transcript::Intron->new({
			SPECIES    => $self->get_transcript->get_species,
			STRAND     => $self->get_transcript->get_strand,
			CHR        => $self->get_transcript->get_chr,
			START      => $$exons[$i-1]->get_stop + 1,
			STOP       => $$exons[$i]->get_start - 1,
			WHERE      => $self,
		}));
	}
	if ($self->get_stop > $$exons[-1]->get_stop) {
		$self->push_intron(MyBio::Transcript::Intron->new({
			SPECIES    => $self->get_transcript->get_species,
			STRAND     => $self->get_transcript->get_strand,
			CHR        => $self->get_transcript->get_chr,
			START      => $$exons[-1]->get_stop + 1,
			STOP       => $self->get_stop,
			WHERE      => $self,
		}));
	}
}
sub push_exon {
	my ($self, $exon) = @_;
	unless (defined $self->{EXONS}) {
		$self->{EXONS} = [];
	}
	$exon->set_where($self);
	push @{$self->{EXONS}}, $exon;
}
sub push_intron {
	my ($self, $intron) = @_;
	unless (defined $self->{INTRONS}) {
		$self->{INTRONS} = [];
	}
	$intron->set_where($self);
	push @{$self->{INTRONS}}, $intron;
}

#######################################################################
##########################   Class Methods   ##########################
#######################################################################
{
	########################################## database ##########################################
	my $DBconnector;
	
	sub get_global_DBconnector {
	# Get the global DBconnector of the Transcript class (this object cannot exist without the Transcript object) 
		my ($class) = @_;
		$class = ref($class) || $class;
		
		if (!defined $DBconnector) {
			$DBconnector = MyBio::Transcript->get_global_DBconnector();
		}
		return $DBconnector;
	}
}

1;