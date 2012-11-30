# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::File::FASTA::Record - Object representing a record of a fasta file

=head1 SYNOPSIS

    # Object representing a record of a fasta file 

    # To initialize 
    my $record = GenOO::Data::File::FASTA::Record->new({
        HEADER          => undef,
        SEQUENCE        => undef,
    });


=head1 DESCRIPTION

    This object represents a record of a fasta file and offers methods for accessing the different attributes.

=head1 EXAMPLES
    
    my $sequence = $record->sequence();
    
=cut

# Let the code begin...

package GenOO::Data::File::FASTA::Record;
use strict;

use base qw( GenOO::_Initializable );

our $VERSION = '1.0';

sub _init {
	my ($self,$data) = @_;
	
	$self->set_header($$data{HEADER});
	$self->set_sequence($$data{SEQUENCE});
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_header {
	my ($self,$value) = @_;
	
	$value =~ s/^>//;
	$self->{HEADER} = $value if defined $value;
}

sub set_sequence {
	my ($self,$value) = @_;
	$self->{SEQUENCE} = $value if defined $value;
}

#######################################################################
############################   Accessors   ############################
#######################################################################
sub header {
	my ($self) = @_;
	return $self->{HEADER};
}

sub sequence {
	my ($self) = @_;
	return $self->{SEQUENCE};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub length {
	my ($self) = @_;
	return length($self->sequence);
}

1;
