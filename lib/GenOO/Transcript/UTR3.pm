package GenOO::Transcript::UTR3;

# Corresponds to the 3'UTR of a gene transcript. It inherits all the attributes and methods of the class GenOO::Transcript::TranscriptRegion.

use strict;

our $VERSION = '2.0';

use base qw(GenOO::Transcript::TranscriptRegion);

# HOW TO CREATE THIS OBJECT
# my $utr3Obj = Transcript::UTR3->new({
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
sub get_conservation {
	return $_[0]->{CONSERVATION};
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_conservation {
	$_[0]->{CONSERVATION} = $_[1] if defined $_[1];
}

#######################################################################
#############################   General   #############################
#######################################################################
sub whatami {
	return 'UTR3';
}

1;