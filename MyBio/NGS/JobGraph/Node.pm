# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::JobGraph::Node - Node for a JobGraph object, with features

=head1 SYNOPSIS

    # Represents a node in a JobGraph object
    # At a higher level it can be a job or a data object
    
    # To initialize 
    my $transcript = MyBio::NGS::JobGraph::Node->new({
        ENSTID         => undef,
        SPECIES        => undef,
        STRAND         => undef,
        CHR            => undef,
        START          => undef,
        STOP           => undef,
        GENE           => undef, # MyBio::Gene
        UTR5           => undef, # MyBio::NGS::JobGraph::Node::UTR5
        CDS            => undef, # MyBio::NGS::JobGraph::Node::CDS
        UTR3           => undef, # MyBio::NGS::JobGraph::Node::UTR3
        CDNA           => undef, # MyBio::NGS::JobGraph::Node::CDNA
        BIOTYPE        => undef,
        INTERNAL_ID    => undef,
        INTERNAL_GID   => undef,
        EXTRA_INFO     => undef,
    });

=head1 DESCRIPTION

    The Transcript class describes a transcript of a gene. It has a backreference back to the gene where it belongs
    and contains functional regions such as 5'UTR, CDS and 3'UTR for protein coding genes. If the gene is not protein
    
=head1 EXAMPLES

    my %transcripts = MyBio::NGS::JobGraph::Node->read_region_info_for_transcripts('FILE',"$database/Ensembl_release_54/CDS_and_3UTR_sequences_CLEAN.txt");

=head1 AUTHOR - Manolis Maragkakis, Panagiotis Alexiou

Email em.maragkakis@gmail.com, pan.alexiou@fleming.gr

=cut

# Let the code begin...

package MyBio::NGS::JobGraph::Node;
use strict;

use base qw(MyBio::_Initializable Clone);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	$self->set_graph($$data{GRAPH});
	$self->set_description($$data{DESCRIPTION});
	
	return $self;
}

#######################################################################
########################   Attribute Getters   ########################
#######################################################################
sub get_graph {
	my ($self) = @_;
	return $self->{GRAPH};
}
sub get_description {
	my ($self) = @_;
	return $self->{DESCRIPTION};
}


#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_graph {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{GRAPH} = $value;
		weaken($self->{GRAPH}); # circular reference that needs to be weakened to avoid memory leaks
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


#######################################################################
##########################   Other Methods   ##########################
#######################################################################


1;
