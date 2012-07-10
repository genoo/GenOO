# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Job::Output - Abstract class for an output object of a job

=head1 SYNOPSIS

    # Should not be instantiated but if it was the fields it supports are 
    my $output = MyBio::JobGraph::Job::Output->new({
        NAME      => 'A name',
        SOURCE    => 'An output source eg. file, database table, etc',
        DEVEL     => BOOLEAN, # if set, source is transformed to a temporary development state
    });

=head1 DESCRIPTION

    Implements and defines methods that need to be present in all derived classes

=cut

# Let the code begin...

package MyBio::JobGraph::Job::Output;
use strict;

use base qw(MyBio::JobGraph::Job::IO);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	$self->set_devel($$data{DEVEL});
	
	return $self;
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_devel {
	my ($self,$value) = @_;
	
	if (defined $value and ($value == 1)) {
		$self->start_devel_mode;
	}
	else {
		$self->stop_devel_mode;
	}
}

#######################################################################
########################   Abstract Methods   #########################
#######################################################################
sub start_devel_mode {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	($class eq __PACKAGE__) or die "Error: Undefined Abstract Method \"".(caller(0))[3]."\" used by $class\n";
}

sub stop_devel_mode {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	($class eq __PACKAGE__) or die "Error: Undefined Abstract Method \"".(caller(0))[3]."\" used by $class\n";
}

sub is_devel_mode_on {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	($class eq __PACKAGE__) or die "Error: Undefined Abstract Method \"".(caller(0))[3]."\" used by $class\n";
}

sub clean {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	($class eq __PACKAGE__) or die "Error: Undefined Abstract Method \"".(caller(0))[3]."\" used by $class\n";
}

1;
