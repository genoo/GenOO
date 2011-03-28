=begin nd

Class: MyBio::NGS::Experiment
A class that describes a next generation sequencing experiment

=cut

package MyBio::NGS::Experiment;

use strict;
use XML::Simple;

use MyBio::_Initializable;

our @ISA = qw( MyBio::_Initializable );

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