# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Description - Description object

=head1 SYNOPSIS

    # This is the main Description object
    # It represents a Description for a Job
    
    # To initialize 
    my $description = MyBio::JobGraph::Description->new({
		HEADER     => 'anything',
		ABSTRACT   => 'anything',
		TEXT 	   => 'anything',
		VARIABLES  => {
				'var1' => 'anything',
				'var2' => 'anything',
				},
    });

=head1 DESCRIPTION

    The Description object contains all information for a description of a job.

=head1 EXAMPLES

    ###TODO

=cut

# Let the code begin...

package MyBio::JobGraph::Description;
use strict;

use base qw(MyBio::_Initializable);

sub _init {
	my ($self,$data) = @_;
	
	$self->set_header($$data{HEADER});
	$self->set_abstract($$data{ABSTRACT});
	$self->set_text($$data{TEXT});
	$self->set_variables($$data{VARIABLES});
	
	return $self;
}
 
#######################################################################
########################   Attribute Getters   ########################
#######################################################################
sub get_header {
	my ($self) = @_;
	return $self->{HEADER};
}

sub get_abstract {
	my ($self) = @_;
	return $self->{ABSTRACT};
}

sub get_text {
	my ($self) = @_;
	return $self->{TEXT};
}

sub get_variables {
	my ($self) = @_;
	return $self->{VARIABLES};
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_header {
	my ($self,$value) = @_;
	
	if (defined $value) {
		$self->{HEADER} = $value;
		return 0;
	}
	else {
		return 1;
	}
}

sub set_abstract {
	my ($self,$value) = @_;
	
	if (defined $value) {
		$self->{ABSTRACT} = $value;
		return 0;
	}
	else {
		return 1;
	}
}

sub set_text {
	my ($self,$value) = @_;
	
	if (defined $value) {
		$self->{TEXT} = $value;
		return 0;
	}
	else {
		return 1;
	}
}

sub set_variables {
	my ($self,$value) = @_;
	
	if (defined $value) {
		$self->{VARIABLES} = $value;
		return 0;
	}
	else {
		return 1;
	}
}

#######################################################################
#############################   Methods   #############################
#######################################################################
=head2 to_string

  Arg []     : NaN
  Example    : ?
  Description:  Return the header abstract and text with the variables inserted at the right place - variables are denoted with {{var}}
  Returntype : string
  Caller     : ?
  Status     : Stable

=cut
sub to_string { 
	my ($self) = @_;
	my $output_string = $self->get_header."\n".$self->get_abstract."\n".$self->get_text."\n";
	my $variables_hash = $self->get_variables;
	foreach my $variable (keys %{$variables_hash})
	{
		my $varstring = "{{$variable}}";
		my $value = $$variables_hash{$variable};
		$output_string =~ s/$varstring/$value/g;
	}
	return $output_string;
}

1;
