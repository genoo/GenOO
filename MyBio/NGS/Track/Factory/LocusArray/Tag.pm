# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::Track::Factory::LocusArray::Tag - Object that offers a MyBio::NGS::Tag interface for MyBio::NGS::Track::Factory::LocusArray::Record

=head1 SYNOPSIS

    # Object representing a record of a locus array

    # To initialize 
    my $bed_record_tag = MyBio::NGS::Track::Factory::LocusArray::Tag->new({
        RECORD       => undef,
        EXTRA_INFO   => undef,
    });


=head1 DESCRIPTION

    This object provides a MyBio::NGS::Tag interface for a record of a locus array and offers methods for accessing the different attributes.

=head1 EXAMPLES

    # Return 1 or -1 for the strand
    my $strand = $locus_array_record_tag->get_strand();

=cut

# Let the code begin...

package MyBio::NGS::Track::Factory::LocusArray::Tag;
use strict;

use base qw( MyBio::_Initializable );

our $VERSION = '1.0';

sub _init {
	my ($self,$data) = @_;
	
	$self->set_record($$data{RECORD});
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_record {
	my ($self,$value) = @_;
	$self->{RECORD} = $value if defined $value;
}

#######################################################################
#########################   Accessor Methods   ########################
#######################################################################
sub record {
	my ($self) = @_;
	return $self->{RECORD};
}

#######################################################################
############################   Interface   ############################
#######################################################################
sub strand {
	my ($self) = @_;
	return $self->record->strand;
}
sub chr {
	my ($self) = @_;
	return $self->record->chr;
}
sub start {
	my ($self) = @_;
	return $self->record->start;
}
sub stop {
	my ($self) = @_;
	return $self->record->stop;
}
sub name {
	my ($self) = @_;
	return $self->record->name;
}
sub score {
	my ($self) = @_;
	return $self->record->score;
}
sub length {
	my ($self) = @_;
	return $self->record->length;
}

1;
