package Transcript::Region;

# Corresponds to a genomic location of a gene transcript. Such locations might be the 5'UTR, CDS and 3'UTR.

use warnings;
use strict;
use Scalar::Util qw/weaken/;

use _Initializable;
use Transcript::Exon;
use Transcript::Intron;
use Locus;

our $VERSION = '2.0';

our @ISA = qw( _Initializable Locus);

# HOW TO CREATE THIS OBJECT
# my $transcriptRegion = Transcript::Region->new({
# 		     TRANSCRIPT       => undef,
# 		     SPLICE_STARTS    => undef,
# 		     SPLICE_STOPS     => undef,
# 		     SEQUENCE         => undef,
# 		     ACCESSIBILITY    => undef,
# 		     EXTRA_INFO       => undef,
# 		     });

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	
	$self->set_transcript($$data{TRANSCRIPT});  #Transcript
	$self->set_splice_starts($$data{SPLICE_STARTS});  # [] reference to array of splice starts
	$self->set_splice_stops($$data{SPLICE_STOPS});  # [] reference to array of splice stops
	$self->set_exons($$data{EXONS}); # [] reference to an array of locus objects (exons)
	$self->set_sequence($$data{SEQUENCE});
	$self->set_extra($$data{EXTRA_INFO});
	$self->set_accessibility($$data{ACCESSIBILITY});
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_transcript {
	return $_[0]->{TRANSCRIPT};
}
sub get_sequence {
	return $_[0]->{SEQUENCE};
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
	if (defined $_[1]) {
		return ${$_[0]->{EXONS}}[$_[1]];
	}
	elsif (defined $_[0]->{EXONS}) {
		return $_[0]->{EXONS}; # return the reference to the array with the exon objects
	}
	elsif ((defined $_[0]->get_transcript->get_cdna->get_exons()) and (defined $_[0]->get_start) and (defined $_[0]->get_stop)){
		return $_[0]->get_contained_locuses($_[0]->get_transcript->get_cdna->get_exons());
	}
	else {
		[];
	}
}
sub get_introns {
	my $self = $_[0];
	my @introns = ();
	unless (@{$self->get_exons} > 1) { return \@introns; }
	my @exons = @{$self->get_exons};
	for (my $i=0; $i<@exons-1; $i++)
	{
		my $prev_exon = $exons[$i];
		my $next_exon = $exons[$i+1];
		
		my $intron = Transcript::Intron->new({
				STRAND       => $prev_exon->get_strand,
				CHR          => $prev_exon->get_chr,
				START        => ($prev_exon->get_stop)+1,
				STOP         => ($next_exon->get_start)-1,
			});
		push @introns, $intron;
	}
	return \@introns;
}

sub get_intron_exon_junctions {
	my $self = $_[0];
	my @junctions = ();
	unless (@{$self->get_exons} > 1) { return \@junctions; }
	
	if ((!defined $self->get_start) or (!defined $self->get_stop)) {warn "$self !defined start: $self->get_start or stop: $self->get_stop!\n"; return \@junctions; }
	
	foreach my $exon (@{$self->get_exons})
	{		
		my $jun = Locus->new({
				STRAND       => $exon->get_strand,
				CHR          => $exon->get_chr,
				START        => $exon->get_start-1,
				STOP         => $exon->get_start-1,
			});
		if ($jun->get_start != $self->get_start-1){push @junctions, $jun;}
		
		my $jun2 = Locus->new({
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
	if    (defined $_[0]->{LENGTH})   {
	}
	elsif (defined $_[0]->{SEQUENCE}) {
		$_[0]->{LENGTH} = length($_[0]->{SEQUENCE});
	}
	else {
		$_[0]->{LENGTH} = $_[0]->_sequence_length_from_splicing();
	}
	return $_[0]->{LENGTH};
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_extra {
	$_[0]->{EXTRA_INFO} = $_[1] if defined $_[1];
}
sub set_sequence {
	my ($self,$value) = @_;
	if (defined $value) {
		unless ($value =~ /^[ATGCU]*$/i) {
			$value =~ /([^ATGCU])/i;
			warn "The nucleotide sequence provided for ".$self->get_transcript->get_enstid()." contains the following invalid characters $1 in $self\n";
		}
		$self->{SEQUENCE} = $value;
	}
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
	if (defined $value) {
		@$value = sort {$a->get_start <=> $b->get_start} @$value;
		$self->{EXONS} = $value;
	}
	elsif ((exists $self->{SPLICE_STARTS}) and (exists $self->{SPLICE_STOPS})) {
		for (my $i = 0; $i < @{$self->{SPLICE_STARTS}}; $i++) {
			my $exon = Transcript::Exon->new({
				STRAND       => $self->get_transcript->get_strand,
				CHR          => $self->get_transcript->get_chr,
				START        => ${$self->{SPLICE_STARTS}}[$i],
				STOP         => ${$self->{SPLICE_STOPS}}[$i],
			});
			$self->push_exon($exon);
		}
	}
}
sub set_accessibility {
	my ($self,$accessibilityVar) = @_;
	
	if (defined $accessibilityVar) {
		my @accessibility = split(/\|/,$accessibilityVar);
		@accessibility = @accessibility[300..(@accessibility-1)];
		if (@accessibility != $self->get_length()) {
			warn $self->get_transcript->get_enstid().":\tAccessibility array size (".scalar @accessibility.") does not match with sequence size (".$self->get_length().") in ".ref($self);
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
sub _sequence_length_from_splicing {
#this routine calculates the sequence length based on the splicing
	my $UTRlength=0;
	
	my @starts = @{$_[0]->get_splice_starts()};
	my @stops  = @{$_[0]->get_splice_stops()};
	
	for (my $i=0; $i<@starts; $i++)  {
		$UTRlength += $stops[$i] - $starts[$i]+1;
	}
		
	return $UTRlength;
}
sub push_exon {
	my ($self, $exon) = @_;
	push @{$self->{EXONS}}, $exon;
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
			$DBconnector = Transcript->get_global_DBconnector();
		}
		return $DBconnector;
	}
}

1;