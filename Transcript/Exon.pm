package Transcript::Exon;

use warnings;
use strict;

use Locus;

our @ISA = qw( Locus );

# HOW TO INITIALIZE THIS OBJECT
# my $Exon = Transcript::Exon->new({
# 		     SPECIES      => undef,
# 		     STRAND       => undef,
# 		     CHR          => undef,
# 		     START        => undef,
# 		     STOP         => undef,
# 		     SEQUENCE     => undef,
# 		     WHERE     => undef,
# 		     EXTRA_INFO   => undef,

# 		     });

sub _init {
	
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);

	$self->set_where($$data{WHERE});
	$self->set_extra($$data{EXTRA_INFO});
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_where {
	return $_[0]->{WHERE} ;
}
sub get_extra {
	return $_[0]->{EXTRA_INFO} ;
}
#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_where {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{WHERE} = $value;
		weaken($self->{WHERE}); # circular reference needs to be weakened to avoid memory leaks
	}
}
sub set_extra {
	$_[0]->{EXTRA_INFO} = $_[1] if defined $_[1];
}

#######################################################################
##########################   Class Methods   ##########################
#######################################################################

1;