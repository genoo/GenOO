package GenOO::Transcript::CDS;

# Corresponds to the CDS of a gene transcript. It inherits all the attributes and methods of the class GenOO::Transcript::TranscriptRegion.

use strict;

our $VERSION = '2.0';

use base qw(GenOO::Transcript::TranscriptRegion);

# HOW TO CREATE THIS OBJECT
# my $cdsObj = Transcript::CDS->new({
# 		     TRANSCRIPT       => undef,
# 		     SPLICE_STARTS    => undef,
# 		     SPLICE_STOPS     => undef,
# 		     LENGTH           => undef,
# 		     SEQUENCE         => undef,
# 		     ACCESSIBILITY    => undef,
# 		     CONSERVATION     => undef,
# 		     EXTRA_INFO       => undef,
# 		     });

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	$self->set_conservation($$data{CONSERVATION});
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_cds_start_locus {
#this will return the coding start nucleotide not the "start"/ ie it will be strand specific!
	my $self = $_[0];
	my $start;
	if ($self->get_strand == 1){$start = $self->get_start;}
	elsif ($self->get_strand == -1){$start = $self->get_stop;}
	else {return undef;}
	my $cdsstart = GenOO::Locus->new({
				STRAND       => $self->get_strand,
				CHR          => $self->get_chr,
				START        => $start,
				STOP         => $start,
	});
	
}
#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_conservation { $_[0]->{CONSERVATION} = $_[1] if defined $_[1];}

#######################################################################
#############################   General   #############################
#######################################################################
sub whatami {
	return 'CDS';
}

1;