# POD documentation - main docs before the code

=head1 NAME

GenOO::NGS::Track::Factory::GFF::Tag - Object that offers a GenOO::NGS::Tag interface for GenOO::NGS::Track::Factory::GFF::Record

=head1 SYNOPSIS

    # Object representing a record of a gff file 

    # To initialize 
    my $gff_record_tag = GenOO::NGS::Track::Factory::GFF::Tag->new({
        RECORD       => undef,
        EXTRA_INFO   => undef,
    });


=head1 DESCRIPTION

    This object provides a GenOO::NGS::Tag interface for a record of a gff file and offers methods for accessing the different attributes.

=head1 EXAMPLES

    # Return 1 or -1 for the strand
    my $strand = $gff_record_tag->strand();

=cut

# Let the code begin...

package GenOO::NGS::Track::Factory::GFF::Tag;
use strict;

use GenOO::Data::File::GFF::Record;

use base qw( GenOO::_Initializable );

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
	return $self->record->seqname;
}
sub chromosome {
	my ($self) = @_;
	return $self->record->seqname;
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
	return $self->record->feature;
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
