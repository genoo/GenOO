# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Job::Description - Class that handles a job description

=head1 SYNOPSIS
    
    # Instantiate 
    my $description = MyBio::JobGraph::Job::Description->new({
        HEADER     => 'A title for the job',
        ABSTRACT   => 'A short summary of the job',
        TEXT       => 'All details for job documentation',
    });

=head1 DESCRIPTION

    This object contains information that consist a description of a job. It supports 
    placeholders within header, abstract and text in the form {{placeholder_1}}.
    Placeholders are replaced by the corresponding values when the output is requested.

=head1 EXAMPLES

    # Creare a new description
    my $description = MyBio::JobGraph::Job::Description->new({
        HEADER     => 'Job No 1',
    });
    
    $description->to_string # returns 'Job No 1'
    
    $description->set_abstract('A small summary of Job No {{job_id}}')
    $description->add_placeholder('job_id',1)
    
    $description->to_string # returns 'Job No 1'
                                      'A small summary of Job No 1'

=cut

# Let the code begin...

package MyBio::JobGraph::Job::Description;
use strict;

use base qw(MyBio::_Initializable);

sub _init {
	my ($self,$data) = @_;
	
	$self->set_header($$data{HEADER});
	$self->set_abstract($$data{ABSTRACT});
	$self->set_text($$data{TEXT});
	
	$self->init_placeholders;
	
	return $self;
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_header {
	my ($self,$value) = @_;
	$self->{HEADER} = $value if defined $value;
}

sub set_abstract {
	my ($self,$value) = @_;
	$self->{ABSTRACT} = $value if defined $value;
}

sub set_text {
	my ($self,$value) = @_;
	$self->{TEXT} = $value if defined $value;
}

#######################################################################
############################   Accessors  #############################
#######################################################################
sub header {
	my ($self) = @_;
	return $self->{HEADER};
}

sub abstract {
	my ($self) = @_;
	return $self->{ABSTRACT};
}

sub text {
	my ($self) = @_;
	return $self->{TEXT};
}

sub placeholders {
	my ($self) = @_;
	return $self->{PLACEHOLDERS};
}

#######################################################################
#############################   Methods   #############################
#######################################################################
sub init_placeholders {
	my ($self) = @_;
	$self->{PLACEHOLDERS} = {};
}

sub add_placeholder {
	my ($self, $name, $value) = @_;
	
	if (defined $name and defined $value) {
		$self->{PLACEHOLDERS}->{$name} = $value;
	}
}

sub placeholder_names {
	my ($self) = @_;
	return keys %{$self->placeholders};
}

sub placeholder_value {
	my ($self, $placeholder_name) = @_;
	return $self->placeholders->{$placeholder_name};
}


=head2 to_string
  Description: Returns a string with the header, abstract and text concatenated and with all placeholders replaced by the corresponding values
  Returntype : string
=cut
sub to_string { 
	my ($self) = @_;
	
	my $output_string = $self->header."\n".$self->abstract."\n".$self->text;
	
	foreach my $name ($self->placeholder_names) {
		my $value = $self->placeholder_value($name);
		my $search_string = "{{$name}}";
		
		$output_string =~ s/$search_string/$value/g;
	}
	
	return $output_string;
}

1;
