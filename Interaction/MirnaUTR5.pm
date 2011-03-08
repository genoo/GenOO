package Interaction::MirnaUTR5;

# Corresponds to a miRNA binding site on the 5'UTR of a gene transcript.

use warnings;
use strict;

use _Initializable;
use Interaction::MRE;
use MyMath;

our $VERSION = '1.0';

our @ISA = qw( _Initializable Interaction::MRE );

# HOW TO CREATE THIS OBJECT
# my $utr5Obj = Transcript::UTR5->new({
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
	
	$self->{WHERE} = 'UTR5';
	$self->Interaction::MRE::_init($data);
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################

#######################################################################
#############################   Setters   #############################
#######################################################################


#######################################################################
##########################   Class Methods   ##########################
#######################################################################


1;