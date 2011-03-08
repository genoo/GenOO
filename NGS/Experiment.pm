=begin nd

Class: NGS::Experiment
A class that describes a next generation sequencing experiment

=cut

package NGS::Experiment;

use warnings;
use strict;
use Switch;
use XML::Simple;

use _Initializable;

our $VERSION = '1.0';

our @ISA = qw( _Initializable );

sub _init {
	my ($self,$data) = @_;
	
	$self->read_info($$data[0]);
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_info {
	return $_[0]->{INFO};
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_info {
	$_[0]->{INFO} = defined $_[1] ? $_[1] : {};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub read_info {
	my ($self,$filename) = @_;
	
	$self->set_info(XMLin($filename));
}
sub write_info {
	my ($self,$filename) = @_;
	
	open(my $OUT,">",$filename) or die "Cannot write to file $filename $!";
	print $OUT XMLout($self->get_info);
	close $OUT;
}

1;