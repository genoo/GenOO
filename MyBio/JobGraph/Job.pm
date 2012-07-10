# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Job - Abstract class for a job

=head1 SYNOPSIS

    # This class should not and cannot be instantiated. It defines the interface that the concrete factories should respect.

=head1 DESCRIPTION

    Concrete factories should respect the interface defined here.

=cut

# Let the code begin...

package MyBio::JobGraph::Job;
use strict;

use base qw(MyBio::_Initializable);

sub _init {
	my ($self, $data) = @_;
	
	$self->is_input_appropriate($$data{INPUT});
	$self->is_output_appropriate($$data{OUTPUT});
	
	$self->set_input($$data{INPUT});
	$self->set_output($$data{OUTPUT});
	$self->set_log($$data{LOG});
	
	return $self;
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_input {
	my ($self, $value) = @_;
	$self->{INPUT} = $value if defined $value;
}

sub set_output {
	my ($self, $value) = @_;
	$self->{OUTPUT} = $value if defined $value;
}

sub set_log {
	my ($self, $value) = @_;
	$self->{LOG} = $value if defined $value;
}

#######################################################################
############################   Accessors  #############################
#######################################################################
sub input {
	my ($self) = @_;
	return $self->{INPUT};
}

sub output {
	my ($self) = @_;
	return $self->{OUTPUT};
}

sub log {
	my ($self) = @_;
	return $self->{LOG};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub is_input_appropriate {
	my ($self, $value) = @_;
	
	return $self->is_io_appropriate($value, 'MyBio::JobGraph::Job::Input')
}

sub is_output_appropriate {
	my ($self, $value) = @_;
	
	return $self->is_io_appropriate($value, 'MyBio::JobGraph::Job::Output')
}

sub is_io_appropriate {
	my ($self, $value, $type) = @_;
	
	if (defined $value) {
		if (ref($value) eq 'ARRAY') {
			foreach my $element (@$value) {
				unless ($element->isa($type)) {
					die "IO object $element should be of the correct type $type\n";
				}
			}
		}
		else {
			die "An array reference should be provided";
		}
		return 1;
	}
}

#######################################################################
########################   Abstract Methods   #########################
#######################################################################
sub clean {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}

sub start_devel_mode {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}

sub stop_devel_mode {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}

sub is_devel_mode_on {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}

sub run {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}

sub description {
	my ($self) = @_;
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}


1;