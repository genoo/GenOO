package MyBio::Transcript::Exon;
use strict;
use Scalar::Util qw/weaken/;

use base qw(MyBio::Locus);

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
	$self->is_constitutive($$data{CONSTITUTIVE});
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_where {
	return $_[0]->{WHERE} ;
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

#######################################################################
#############################   General   #############################
#######################################################################
sub whatami {
	return 'Exon';
}
sub is_constitutive {
	if (defined $_[1]) {
		$_[0]->{CONSTITUTIVE} = $_[1];
	}
	else {
		return $_[0]->{CONSTITUTIVE};
	}
}

#######################################################################
##########################   Class Methods   ##########################
#######################################################################

1;