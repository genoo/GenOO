# POD documentation - main docs before the code

=head1 NAME

MyBio::Transcript::TranscriptRegion - A functional region within a transcript consisting of spicing elements, with features

=head1 SYNOPSIS

    # This is the main region object.
    # Represents a functional region within
    # a transcript eg 3'UTR, CDS or 5'UTR
    # It supports splicing.
    
    # To initialize 
    my $region = MyBio::Transcript::TranscriptRegion->new({
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
    });

=head1 DESCRIPTION

    Not provided yet

=head1 EXAMPLES

    Not provided yet

=head1 AUTHOR - Manolis Maragkakis, Panagiotis Alexiou

Email em.maragkakis@gmail.com, pan.alexiou@fleming.gr

=cut

# Let the code begin...

package MyBio::Transcript::TranscriptRegion;

use strict;
use Scalar::Util qw/weaken/;

use MyBio::Transcript::Exon;
use MyBio::Transcript::Intron;

our $VERSION = '1.0';

use base qw(MyBio::SplicedLocus);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	$self->set_transcript($$data{TRANSCRIPT});  #Transcript
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_species { #overide
	if (defined $_[0]->get_transcript) {
		return $_[0]->get_transcript->get_species;
	}
	else {
		return $_[0]->{SPECIES};
	}
}
sub get_strand { #overide
	if (defined $_[0]->get_transcript) {
		return $_[0]->get_transcript->get_strand;
	}
	else {
		return $_[0]->{STRAND};
	}
}
sub get_chr { #overide
	if (defined $_[0]->get_transcript) {
		return $_[0]->get_transcript->get_chr;
	}
	else {
		return $_[0]->{CHR};
	}
}
sub get_transcript {
	return $_[0]->{TRANSCRIPT};
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_transcript {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{TRANSCRIPT} = $value;
		weaken($self->{TRANSCRIPT}); # circular reference needs to be weakened to avoid memory leaks
	}
}
sub set_exons {
	my ($self,$value) = @_;
	
	$self->SUPER::set_exons($value);
	
	# If exon set from the parent class has failed try to get information from the transcript
	if (!defined $self->{EXONS} and (@{$self->get_transcript->get_exons} > 0) and defined $self->get_start and defined $self->get_stop) {
		$self->_set_exons_from_transcript_exons();
	}
}

sub set_introns {
	my ($self,$value) = @_;
	
	$self->SUPER::set_introns($value);
	
	# If intron set from the parent class has failed try to get information from the transcript
	if (!defined $self->{INTRONS} and (@{$self->get_transcript->get_introns} > 0) and defined $self->get_start and defined $self->get_stop) {
		$self->_set_introns_from_transcript_introns();
	}
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
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
sub _set_introns_from_transcript_introns {
	my ($self) = @_;
# 	warn "Method _set_introns_from_transcript_introns has not been tested for bugs. Please check and remove warning";
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

1;