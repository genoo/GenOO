package GenOO::Transcript::Exon;
use strict;
use Scalar::Util qw/weaken/;

use base qw(GenOO::Locus);

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
sub get_slice {
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





##############################################
### FROM HERE - Strange code that calculates relative coordinates to transcript

sub get_spliced_start_relative_to_slice {
	my ($self) = @_;
	
	if ($self->get_strand == 1) {
		return $self->get_spliced_relative_5p;
	}
	else {
		return $self->get_slice->get_exonic_length - $self->get_spliced_relative_5p - 1;
	}
}

sub get_spliced_stop_relative_to_slice {
	my ($self) = @_;
	
	if ($self->get_strand == 1) {
		return $self->get_spliced_relative_3p;
	}
	else {
		return $self->get_slice->get_exonic_length - $self->get_spliced_relative_3p - 1;
	}
}

sub get_spliced_relative_5p {
	my ($self) = @_;
	if ($self->get_strand == 1) {
		return $self->get_spliced_relative_start;
	}
	else {
		return $self->get_spliced_relative_stop;
	}
}

sub get_spliced_relative_3p {
	my ($self) = @_;
	if ($self->get_strand == 1) {
		return $self->get_spliced_relative_stop;
	}
	else {
		return $self->get_spliced_relative_start;
	}
}

sub get_spliced_relative_start {
	my ($self) = @_;
	return $self->get_slice->to_spliced_relative($self->get_start);
}

sub get_spliced_relative_stop {
	my ($self) = @_;
	return $self->get_slice->to_spliced_relative($self->get_stop);
}

### TO HERE
##############################################




#######################################################################
##########################   Class Methods   ##########################
#######################################################################

1;