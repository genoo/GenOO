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
	
	$self->read_info("XML",$$data{XML});
	
	my $class = ref($self) || $self;
	$class->_add_to_all($self);
	
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
	my ($self,$method,@attributes) = @_;
	
	if ($method eq "XML") {
		my $filename = $attributes[0];
		$self->set_info(XMLin($filename));
	}
}

#######################################################################
##########################   Class Methods   ##########################
#######################################################################
{
	my %experiments;
	
	sub _add_to_all {
		my ($class,$obj) = @_;
		$experiments{$obj->get_name} = $obj;
	}
	sub _delete_from_all {
		my ($class,$obj) = @_;
		delete $experiments{$obj->get_name};
	}
	sub get_all {
		my ($class) = @_;
		return %experiments;
	}
	sub delete_all {
		my ($class) = @_;
		%experiments = ();
	}
	sub get_by_name {
		my ($class,$name) = @_;
		if (exists $experiments{$name}) {
			return $experiments{$name};
		}
		else {
			return undef;
		}
	}
}

1;