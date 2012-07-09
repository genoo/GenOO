# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Job::IO - Abstract class for the input/output objects of a job

=head1 SYNOPSIS

    # This is the main IO object
       
    # To initialize 
    my $output = MyBio::JobGraph::Job::IO->new({
        NAME       => 'A name for the input/output object',
        SOURCE     => 'A file, a database or whatever can store information',
    });

=head1 DESCRIPTION

    The IO base class contains common information for the Input and Output objects.

=cut

# Let the code begin...

package MyBio::JobGraph::Job::IO;
use strict;

use base qw(MyBio::_Initializable);

sub _init {
	my ($self,$data) = @_;
	
	$self->set_name($$data{NAME});
	$self->set_source($$data{SOURCE});
	$self->set_original_source($$data{SOURCE});
	
	return $self;
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_name {
	my ($self,$value) = @_;
	$self->{NAME} = $value if defined $value;
}

sub set_source {
	my ($self,$value) = @_;
	$self->{SOURCE} = $value if defined $value;
}

sub set_original_source {
	my ($self,$value) = @_;
	$self->{ORIGINAL_SOURCE} = $value if defined $value;
}

#######################################################################
############################   Accessors  #############################
#######################################################################
sub name {
	my ($self) = @_;
	return $self->{NAME};
}

sub source {
	my ($self) = @_;
	return $self->{SOURCE};
}

sub original_source {
	my ($self) = @_;
	return $self->{ORIGINAL_SOURCE};
}

#######################################################################
########################   Abstract Methods   #########################
#######################################################################
sub type {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	die "Error:  Use of undefined Abstract Method \"".(caller(0))[3]."\" by $class\n";
}


1;
