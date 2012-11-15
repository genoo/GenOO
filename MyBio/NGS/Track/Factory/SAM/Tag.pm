# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::Track::Factory::SAM::Tag - Object that offers a MyBio::NGS::Tag interface for MyBio::NGS::Track::Factory::SAM::Record

=head1 SYNOPSIS

    # Object representing a record of a sam file 

    # To initialize 
    my $sam_record_tag = MyBio::NGS::Track::Factory::SAM::Tag->new({
        RECORD       => undef,
        EXTRA_INFO   => undef,
    });


=head1 DESCRIPTION

    This object provides a MyBio::NGS::Tag interface for a record of a sam file and offers methods for accessing the different attributes.

=head1 EXAMPLES

    # Return 1 or -1 for the strand
    my $strand = $sam_record_tag->strand();

=cut

# Let the code begin...

package MyBio::NGS::Track::Factory::SAM::Tag;
use strict;

use MyBio::Data::File::SAM::Record;

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
	return $self->record->rname;
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
	return $self->record->qname;
}
sub score {
	my ($self) = @_;
	return $self->record->mapq;
}
sub length {
	my ($self) = @_;
	return $self->record->alignment_length;
}
sub sequence {
	my ($self) = @_;
	return $self->record->query_seq;
}

1;
