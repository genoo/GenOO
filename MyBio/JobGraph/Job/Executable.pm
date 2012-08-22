# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Job::Executable - Abstract class for jobs which run an executable

=head1 SYNOPSIS

    # Should not be instantiated but if it was, the fields it supports are 
    my $executable = MyBio::JobGraph::Job::Executable->new({
        INPUT        => [$input_obj],
        OUTPUT       => [$output_obj],
        OPTIONS      => {option1 => value, ...},
        LOG          => $logobj,
        DEVEL        => 'Boolean. If set the Input/Output are transformed to a temporary development state',
    });

=head1 DESCRIPTION

    This class is an abstract class for job which run an executable. It offers methods to run the
    executable and catch its STDOUT and STDERR. It respects the interface of MyBio::JobGraph::Job
    and defines more methods that need to be respected by derived classes.

=head1 EXAMPLES

    # Run the job and catch STDOUT and STDERR
    $executable->run;
    
    # The command to run
    $executable->command

=cut

# Let the code begin...

package MyBio::JobGraph::Job::Executable;
use strict;

use base qw(MyBio::JobGraph::Job);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	
	return $self;
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################

#######################################################################
############################   Accessors  #############################
#######################################################################

#######################################################################
#############################   Methods   #############################
#######################################################################
sub run {
	my ($self) = @_;
	
	my $cmd = $self->command;
	my $return_string = `$cmd 2>&1`; # Run the command and catch both STDERR and STDOUT
	$self->set_return_string($return_string);
}

sub executable_can_run {
	my ($self) = @_;
	
	if ($self->executable ne '') {
		my $exec = $self->executable;
		my $status = system "command -v $exec >/dev/null 2>&1 || { echo >&2 \"Command $exec not found\"; exit 1; }";
		return $status == 0 ? 1 : 0;
	}
	else {
		return 0;
	}
}

#######################################################################
########################   Abstract Methods   #########################
#######################################################################
sub executable {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	if ($class eq __PACKAGE__) {
		return undef;
	}
	else {
		die "Error: Undefined Abstract Method \"".(caller(0))[3]."\" used by $class\n";
	}
}

sub command {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	if ($class eq __PACKAGE__) {
		return undef;
	}
	else {
		die "Error: Undefined Abstract Method \"".(caller(0))[3]."\" used by $class\n";
	}
}

sub description { # Override
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
