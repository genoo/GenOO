# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::IO - Input Output base object

=head1 SYNOPSIS

    # This is the main IO object
       
    # To initialize 
    my $output = MyBio::JobGraph::IO->new({
		NAME       => 'anything',
		SOURCE     => 'anything',
		TYPE       => 'anything',
    });

=head1 DESCRIPTION

    The IO object contains common information for the Input and Output objects.

=head1 EXAMPLES

    ###TODO

=cut

# Let the code begin...

package MyBio::JobGraph::IO;
use strict;

use base qw(MyBio::_Initializable);

sub _init {
	my ($self,$data) = @_;
	
	$self->set_name($$data{NAME});
	$self->set_source($$data{SOURCE});
	$self->set_type($$data{TYPE});	
	return $self;
}
 
#######################################################################
########################   Attribute Getters   ########################
#######################################################################
sub get_name {
	my ($self) = @_;
	return $self->{NAME};
}

sub get_source {
	my ($self) = @_;
	return $self->{SOURCE};
}

sub get_type {
	my ($self) = @_;
	return $self->{TYPE};
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_name {
	my ($self,$value) = @_;
	
	if (defined $value) {
		$self->{NAME} = $value;
		return 0;
	}
	else {
		return 1;
	}
}

sub set_source {
	my ($self,$value) = @_;
	
	if (defined $value) {
		$self->{SOURCE} = $value;
		return 0;
	}
	else {
		return 1;
	}
}

sub set_type {
	my ($self,$value) = @_;
	
	if (defined $value) {
		$self->{TYPE} = $value;
		return 0;
	}
	else {
		return 1;
	}
}


#######################################################################
#############################   Methods   #############################
#######################################################################


1;
