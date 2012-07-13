# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Data - Abstract class for jobgraph data management

=head1 SYNOPSIS

    # Should not be instantiated

=head1 DESCRIPTION

    This abstact class defines the methods and attibutes that derived classes which handle data
    management should implement. Example of derived classses is a File or a Database.

=cut

# Let the code begin...

package MyBio::JobGraph::Data;
use strict;

use base qw(MyBio::_Initializable);

sub _init {
	my ($self,$data) = @_;
	
	$self->set_devel_mode($$data{DEVEL_MODE});
	
	return $self;
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_devel_mode {
	my ($self,$value) = @_;
	$self->{DEVEL_MODE} = $value if defined $value;
}

#######################################################################
############################   Accessors  #############################
#######################################################################
sub devel_mode {
	my ($self) = @_;
	return $self->{DEVEL_MODE};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub is_devel_mode_on {
	my ($self) = @_;
	return $self->devel_mode == 1 ? 1 : 0;
}

#######################################################################
########################   Abstract Methods   #########################
#######################################################################
sub type {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	if ($class eq __PACKAGE__) {
		return undef;
	}
	else {
		die "Error: Undefined Abstract Method \"".(caller(0))[3]."\" used by $class\n";
	}
}

sub clean {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	if ($class eq __PACKAGE__) {
		return undef;
	}
	else {
		die "Error: Undefined Abstract Method \"".(caller(0))[3]."\" used by $class\n";
	}
}

sub start_devel_mode {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	if ($class eq __PACKAGE__) {
		return undef;
	}
	else {
		die "Error: Undefined Abstract Method \"".(caller(0))[3]."\" used by $class\n";
	}
}

sub stop_devel_mode {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	if ($class eq __PACKAGE__) {
		return undef;
	}
	else {
		die "Error: Undefined Abstract Method \"".(caller(0))[3]."\" used by $class\n";
	}
}





1;
