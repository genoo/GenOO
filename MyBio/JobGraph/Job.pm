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

use MyBio::JobGraph::Job::Input;
use MyBio::JobGraph::Job::Output;
use MyBio::JobGraph::Job::Log::File;
use MyBio::JobGraph::Job::Description;

use base qw(MyBio::_Initializable);

sub _init {
	my ($self, $data) = @_;
	
	$self->set_input($$data{INPUT});
	$self->set_output($$data{OUTPUT});
	$self->set_log($$data{LOG});
	$self->set_options($$data{OPTIONS});
	$self->set_devel($$data{DEVEL});
	
	$self->check_initialization;
	
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

sub set_options {
	my ($self,$value) = @_;
	$self->{OPTIONS} = $value if defined $value;
}

sub set_devel {
	my ($self,$value) = @_;
	
	if (defined $value and ($value == 1)) {
		$self->start_devel_mode;
	}
	else {
		$self->stop_devel_mode;
	}
}

sub set_return_string {
	my ($self,$value) = @_;
	$self->{RETURN_STRING} = $value if defined $value;
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

sub options {
	my ($self) = @_;
	return $self->{OPTIONS};
}

sub return_string {
	my ($self) = @_;
	return $self->{RETURN_STRING};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub check_initialization {
	my ($self) = @_;
	
	my $test1 = $self->is_input_appropriate;
	my $test2 = $self->is_output_appropriate;
	return $test1 and $test2;
}

sub is_input_appropriate {
	my ($self) = @_;
	
	return $self->is_io_appropriate($self->input, 'MyBio::JobGraph::Job::Input')
}

sub is_output_appropriate {
	my ($self) = @_;
	
	return $self->is_io_appropriate($self->output, 'MyBio::JobGraph::Job::Output')
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

sub clean {
	my ($self) = @_;
	$_->clean for @{$self->output};
}

sub start_devel_mode {
	my ($self) = @_;
	
	$_->start_devel_mode for @{$self->output};
	$self->{DEVEL} = 1;
}

sub stop_devel_mode {
	my ($self) = @_;
	
	$_->stop_devel_mode for @{$self->output};
	$self->{DEVEL} = 0;
}

sub is_devel_mode_on {
	my ($self) = @_;
	return $self->{DEVEL} == 1 ? 1 : 0;
}

#######################################################################
########################   Abstract Methods   #########################
#######################################################################
sub run {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	if ($class eq __PACKAGE__) {
		return undef;
	}
	else {
		die "Error: Undefined Abstract Method \"".(caller(0))[3]."\" used by $class\n";
	}
}

sub description {
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