# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::Track::Factory::Interface - Interface of a concrete factory for creating MyBio::NGS::Track objects

=head1 SYNOPSIS

    # This class should not and cannot be instantiated. It defines the interface that the concrete factories should respect.

=head1 DESCRIPTION

    Concrete factories should respect the interface defined here.

=cut

# Let the code begin...

package MyBio::NGS::Track::Factory::Interface;
use strict;

use MyBio::NGS::Track;

our $VERSION = '1.0';


sub new {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}

sub _init {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_file {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}

#######################################################################
########################   Attribute Getters   ########################
#######################################################################
sub get_file {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub read_track {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}

1;
