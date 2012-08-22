# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::Sample - Object for a deep sequencing sample

=head1 SYNOPSIS

    # Instantiate
    my $sample = MyBio::NGS::Sample->new({
        XML            => undef,
    });

=head1 DESCRIPTION

    This object is constructed from an xml file which contains information about a
    deep sequencing sample. It contains accessors for all relevant information in the XML

=head1 EXAMPLES

    # Read sample xml_data
    my $sample_name = $sample->name;
    
    # Print all contaminants
    my @contaminants = $sample->contaminants;
    print "$_\n" for @contaminants;
    
=cut

# Let the code begin...

package MyBio::NGS::Sample;
use strict;
use XML::Simple;

use base qw( MyBio::_Initializable );

sub _init {
	my ($self,$data) = @_;
	
	$self->read_xml($$data{XML});
	
	return $self;
}

#######################################################################
############################   Accessors  #############################
#######################################################################
sub xml_data {
	my ($self) = @_;
	return $self->{XML_DATA};
}

sub name {
	my ($self) = @_;
	return $self->xml_data->{'name'};
}

sub species {
	my ($self) = @_;
	return $self->xml_data->{'species'};
}

sub species_id {
	my ($self) = @_;
	return $self->xml_data->{'species_id'};
}

sub type {
	my ($self) = @_;
	return $self->xml_data->{'type'};
}

sub subtype {
	my ($self) = @_;
	return $self->xml_data->{'subtype'};
}

sub sequencer {
	my ($self) = @_;
	return $self->xml_data->{'sequencer'};
}

sub five_p_adaptor {
	my ($self) = @_;
	return $self->xml_data->{'five_p_adaptor'};
}

sub three_p_adaptor {
	my ($self) = @_;
	return $self->xml_data->{'three_p_adaptor'};
}

sub contaminants {
	my ($self) = @_;
	if (exists $self->xml_data->{'contaminant'}) {
		return @{$self->xml_data->{'contaminant'}};
	}
	else {
		return @{[]};
	}
}

sub align {
	my ($self) = @_;
	return $self->xml_data->{'align'};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub read_xml {
	my ($self,$filename) = @_;
	
	$self->{XML_DATA} = XMLin($filename, ForceArray => ['contaminant'], KeepRoot => 0, KeyAttr => []);
}

1;
