package GenOO::Intron;
use strict;
use Scalar::Util qw/weaken/;

use base qw(GenOO::Locus);

# HOW TO INITIALIZE THIS OBJECT
# my $Intron = Transcript::Intron->new({
# 		     SPECIES      => undef,
# 		     STRAND       => undef,
# 		     CHR          => undef,
# 		     START        => undef,
# 		     STOP         => undef,
# 		     SEQUENCE     => undef,
# 		     WHERE        => undef,
# 		     EXTRA_INFO   => undef,

# 		     });

sub _init {
	
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	$self->set_where($$data{WHERE});
	
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
	return 'Intron';
}

#######################################################################
##########################   Class Methods   ##########################
#######################################################################

1;