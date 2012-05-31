# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::JobGraph - Job object, with features

=head1 SYNOPSIS

    # This is the main transcript object
    # It represents a transcript of a gene
    
    # To initialize 
    my $transcript = MyBio::NGS::JobGraph->new({
        ENSTID         => undef,
        SPECIES        => undef,
        STRAND         => undef,
        CHR            => undef,
        START          => undef,
        STOP           => undef,
        GENE           => undef, # MyBio::Gene
        UTR5           => undef, # MyBio::NGS::JobGraph::UTR5
        CDS            => undef, # MyBio::NGS::JobGraph::CDS
        UTR3           => undef, # MyBio::NGS::JobGraph::UTR3
        CDNA           => undef, # MyBio::NGS::JobGraph::CDNA
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

    my %transcripts = MyBio::NGS::JobGraph->read_region_info_for_transcripts('FILE',"$database/Ensembl_release_54/CDS_and_3UTR_sequences_CLEAN.txt");

=head1 AUTHOR - Manolis Maragkakis, Panagiotis Alexiou

Email em.maragkakis@gmail.com, pan.alexiou@fleming.gr

=cut

# Let the code begin...

package MyBio::NGS::JobGraph;
use strict;

use Graph

use base qw(Graph);




#######################################################################
#############################   Methods   #############################
#######################################################################



1;