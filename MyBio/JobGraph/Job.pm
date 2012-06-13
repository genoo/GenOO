# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Job - Interface of a concrete factory for creating Job objects

=head1 SYNOPSIS

    # This class should not and cannot be instantiated. It defines the interface that the concrete factories should respect.

=head1 DESCRIPTION

    Concrete factories should respect the interface defined here.

=cut

# Let the code begin...

package MyBio::JobGraph::Job;
use strict;

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
sub set_input {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}
sub set_output {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}
sub set_description {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}
sub set_log {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}
#######################################################################
########################   Attribute Getters   ########################
#######################################################################
sub get_input {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}
sub get_output {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}
sub get_description {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}
sub get_log {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}
#######################################################################
#########################   General Methods   #########################
#######################################################################
sub clean {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}
sub develop {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}
sub run {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}


1;