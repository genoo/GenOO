# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Job::Generic - Generic Job object, with features

=head1 SYNOPSIS

    # This is the main job object
    # It represents a job that can be run. An executable.
    
    # To initialize 
    my $job = MyBio::JobGraph::Job::Generic->new({
		INPUT        => [$inputobject,...],
		OUTPUT       => [$outputobject,...],
		DESCRIPTION  => $descriptionobj,
		LOG          => $logobj,
		CODE         => reference to a sub of code,
    });

=head1 DESCRIPTION

    The job object contains all information on a job/analysis to be run. It contains references to input and output, parameters, executables, comments, description etc.

=head1 EXAMPLES

    ###TODO

=cut

# Let the code begin...

package MyBio::JobGraph::Job::Generic;
use strict;

use base qw(MyBio::_Initializable MyBio::JobGraph::Job);

sub _init {
	my ($self,$data) = @_;
	
	$self->set_input($$data{INPUT});
	$self->set_output($$data{OUTPUT});
	$self->set_description($$data{DESCRIPTION});
	$self->set_log($$data{LOG});
	$self->set_code($$data{CODE});
	
	
	return $self;
}
 
#######################################################################
########################   Attribute Getters   ########################
#######################################################################
sub get_input {
	my ($self) = @_;
	return $self->{INPUT};
}

sub get_output {
	my ($self) = @_;
	return $self->{OUTPUT};
}

sub get_description {
	my ($self) = @_;
	return $self->{DESCRIPTION};
}

sub get_log {
	my ($self) = @_;
	return $self->{LOG};
}

sub get_code {
	my ($self) = @_;
	return $self->{CODE};
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_input {
	my ($self,$value) = @_;
	
	if (defined $value) {
		$self->{INPUT} = $value;
		return 0;
	}
	else {
		return 1;
	}
}

sub set_output {
	my ($self,$value) = @_;
	
	if (defined $value) {
		$self->{OUTPUT} = $value;
		return 0;
	}
	else {
		return 1;
	}
}

sub set_description {
	my ($self,$value) = @_;
	
	if (defined $value) {
		$self->{DESCRIPTION} = $value;
		return 0;
	}
	else {
		return 1;
	}
}

sub set_log {
	my ($self,$value) = @_;
	
	if (defined $value) {
		$self->{LOG} = $value;
		return 0;
	}
	else {
		return 1;
	}
}

sub set_code {
	my ($self,$value) = @_;
	
	if (defined $value) {
		$self->{CODE} = $value;
		return 0;
	}
	else {
		return 1;
	}
}

#######################################################################
#############################   Methods   #############################
#######################################################################
sub clean { #this method will clean-up all the outputs

}

=head2 use_develop

  Arg []     : 0 or 1. 1 sets development mode ON. 0 sets it off
  Example    : ?
  Description: Sets all I/O to development
  Returntype : NaN
  Caller     : ?
  Status     : Stable

=cut
sub use_develop {
	my ($self) = @_;
	foreach my $io_obj ($self->get_input, $self->get_output)
	{
		$io_obj->set_to_development;
	}
}

=head2 run

  Arg []     : NaN
  Example    : ?
  Description: Runs arbirtrary code
  Returntype : Output of code
  Caller     : ?
  Status     : Stable

=cut
sub run {
	my ($self) = @_;
	return $self->get_code->($self->get_input,$self->get_output);
}

=head2 add_default_variables_to_description

  Arg []     : NaN
  Example    : ?
  Description:  Will add default variables to description VARIABLES hash.
	INPUT          : join(",", @inputnames)
	INPUT[0,1 ...] : each input name
	OUTPUT         : same as inputs
  Returntype : ?
  Caller     : ?
  Status     : Stable

=cut
sub add_default_variables_to_description {
	my ($self) = @_;
	
	my %description_attr_obj = $self->get_description->get_variables;
	
	my @inputnames;
	my $i=0;
	foreach my $inputobj (@{$self->get_input})
	{
		$description_attr_obj{"INPUT$i"} = $inputobj->get_name;
		$i++;
		push (@inputnames, $inputobj->get_name);
	}
	$description_attr_obj{"INPUT"} = join(",", @inputnames);
	
	my @outputnames;
	my $i=0;
	foreach my $outputobj (@{$self->get_output})
	{
		$description_attr_obj{"OUTPUT$i"} = $outputobj->get_name;
		$i++;
		push (@outputnames, $outputobj->get_name);
	}
	$description_attr_obj{"OUTPUT"} = join(",", @outputnames);
	
	$self->get_description->set_variables(\%description_attr_obj);
	return 1;
}

1;
