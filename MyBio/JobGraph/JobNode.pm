# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::Pipeline::Job - Job object, with features

=head1 SYNOPSIS

    # This is the main transcript object
    # It represents a transcript of a gene
    
    # To initialize 
    my $transcript = MyBio::NGS::Pipeline::Job->new({
        ENSTID         => undef,
        SPECIES        => undef,
        STRAND         => undef,
        CHR            => undef,
        START          => undef,
        STOP           => undef,
        GENE           => undef, # MyBio::Gene
        UTR5           => undef, # MyBio::NGS::Pipeline::Job::UTR5
        CDS            => undef, # MyBio::NGS::Pipeline::Job::CDS
        UTR3           => undef, # MyBio::NGS::Pipeline::Job::UTR3
        CDNA           => undef, # MyBio::NGS::Pipeline::Job::CDNA
        BIOTYPE        => undef,
        INTERNAL_ID    => undef,
        INTERNAL_GID   => undef,
        EXTRA_INFO     => undef,
    });

=head1 DESCRIPTION

    The Transcript class describes a transcript of a gene. It has a backreference back to the gene where it belongs
    and contains functional regions such as 5'UTR, CDS and 3'UTR for protein coding genes. If the gene is not protein
    coding then the CDNA region is set and the above remain undefined. It's up to the user to check if the attributes
    are defined or not. The transcript class inherits the SplicedLocus class so it also describes a genomic region
    where Introns and Exons are defined.

=head1 EXAMPLES

    my %transcripts = MyBio::NGS::Pipeline::Job->read_region_info_for_transcripts('FILE',"$database/Ensembl_release_54/CDS_and_3UTR_sequences_CLEAN.txt");

=head1 AUTHOR - Manolis Maragkakis, Panagiotis Alexiou

Email em.maragkakis@gmail.com, pan.alexiou@fleming.gr

=cut

# Let the code begin...

package MyBio::NGS::Pipeline::Job;
use strict;

use base qw(MyBio::_Initializable Clone);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	$self->set_input($$data{INPUT});
	$self->set_output($$data{OUTPUT});
	$self->set_description($$data{DESCRIPTION});
	$self->set_log($$data{LOG});
	
	return $self;
}

#######################################################################
########################   Attribute Getters   ########################
#######################################################################
sub get_input {
	my ($self) = @_;
	return $self->{INPUT};
}
sub get_output {
	my ($self) = @_;
	return $self->{OUTPUT};
}
sub get_description {
	my ($self) = @_;
	return $self->{DESCRIPTION};
}
sub get_log {
	my ($self) = @_;
	return $self->{LOG};
}


#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_input {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{ENSTID} = $value;
		return 0;
	}
	else {
		return 1;
	}
}
sub set_output {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{OUTPUT} = $value;
		return 0;
	}
	else {
		return 1;
	}
}
sub set_description {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{DESCRIPTION} = $value;
		return 0;
	}
	else {
		return 1;
	}
}
sub set_log {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{LOG} = $value;
		return 0;
	}
	else {
		return 1;
	}
}


#######################################################################
#############################   Methods   #############################
#######################################################################



1;