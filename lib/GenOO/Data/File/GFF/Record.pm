# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::File::GFF::Record - Object representing a record of a gff file

=head1 SYNOPSIS

    # Object representing a record of a gff file 

    # To initialize 
    my $record = GenOO::Data::File::GFF::Record->new({
        SEQNAME      => undef,
        SOURCE       => undef,
        FEATURE      => undef,
        START_1      => undef,
        STOP_1       => undef,
        SCORE        => undef,
        STRAND       => undef,
        FRAME        => undef,
        ATTRIBUTES   => undef,
        COMMENT      => undef,
        EXTRA_INFO   => undef,
    });


=head1 DESCRIPTION

    This object represents a record of a gff file and offers methods for accessing the different attributes.
    It implements several additional methods that transform original attributes in more manageable attributes.

=head1 EXAMPLES

    # Return 1 or -1 for the strand
    my $strand = $record->strand();

=head1 AUTHOR - Manolis Maragkakis

Email em.maragkakis@gmail.com

=cut

# Let the code begin...

package GenOO::Data::File::GFF::Record;
use strict;

use base qw( GenOO::_Initializable );

our $VERSION = '1.0';

sub _init {
	my ($self,$data) = @_;
	
	$self->set_seqname($$data{SEQNAME});       # The name of the sequence.
	$self->set_source($$data{SOURCE});         # The source of this feature.
	$self->set_feature($$data{FEATURE});       # The feature type name.
	$self->set_start($$data{START_1});         # 1-based
	$self->set_stop($$data{STOP_1});           # 1-based
	$self->set_score($$data{SCORE});           # A floating point value.
	$self->set_strand($$data{STRAND});         # One of '+', '-' or '.'.
	$self->set_frame($$data{FRAME});           # '0', '1', '2', '.'. Specifies if region is in frame
	$self->set_attributes($$data{ATTRIBUTES}); # Array reference with tag-value strings
	$self->set_comment($$data{COMMENT});       # A comment
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_seqname {
	my ($self,$value) = @_;
	$self->{SEQNAME} = $value if defined $value;
}
sub set_source {
	my ($self,$value) = @_;
	$self->{SOURCE} = $value if defined $value;
}
sub set_feature {
	my ($self,$value) = @_;
	$self->{FEATURE} = $value if defined $value;
}
sub set_start {
	my ($self,$value) = @_;
	$self->{START} = $value - 1 if defined $value;
}
sub set_stop {
	my ($self,$value) = @_;
	$self->{STOP} = $value - 1 if defined $value;
}
sub set_score {
	my ($self,$value) = @_;
	$self->{SCORE} = $value if defined $value;
}
sub set_strand {
	my ($self,$value) = @_;
	if (defined $value) {
		$value =~ s/^\+$/1/;
		$value =~ s/^\-$/-1/;
		$value =~ s/^\.$/0/;
		$self->{STRAND} = $value;
	}
}
sub set_frame {
	my ($self,$value) = @_;
	$self->{FRAME} = $value if defined $value;
}
sub set_attributes {
	my ($self,$value) = @_;
	
	if (defined $value) {
		unless (exists $self->{ATTRIBUTES}) {
			$self->{ATTRIBUTES} = {};
		}
		foreach my $attribute_var (@$value) {
			$attribute_var =~ /(.+)="(.+)"/;
			$self->attributes->{$1} = $2;
		}
	}
}
sub set_comment {
	my ($self,$value) = @_;
	$self->{COMMENT} = $value if defined $value;
}

#######################################################################
########################   Attribute Getters   ########################
#######################################################################
sub seqname {
	my ($self) = @_;
	return $self->{SEQNAME};
}
sub source {
	my ($self) = @_;
	return $self->{SOURCE};
}
sub feature {
	my ($self) = @_;
	return $self->{FEATURE};
}
sub start {
	my ($self) = @_;
	return $self->{START};
}
sub stop {
	my ($self) = @_;
	return $self->{STOP};
}
sub score {
	my ($self) = @_;
	return $self->{SCORE};
}
sub strand {
	my ($self) = @_;
	return $self->{STRAND};
}
sub frame {
	my ($self) = @_;
	return $self->{FRAME};
}
sub attributes {
	my ($self) = @_;
	return $self->{ATTRIBUTES};
}
sub comment {
	my ($self) = @_;
	return $self->{COMMENT};
}

#######################################################################
############################   Accessors   ############################
#######################################################################
sub length {
	my ($self) = @_;
	return $self->stop - $self->start + 1;
}
sub strand_symbol {
	my ($self) = @_;
	
	my $strand = $self->strand;
	if (defined $strand) {
		if ($strand == 1) {
			return '+';
		}
		elsif ($strand == -1) {
			return '-';
		}
		elsif ($strand == 0) {
			return '.';
		}
	}
	else {
		return undef;
	}
}
sub attribute {
	my ($self, $attribute) = @_;
	
	if (defined $self->attributes and defined $attribute) {
		return $self->attributes->{$attribute};
	}
	return;
}

#######################################################################
#########################   General Methods   #########################
#######################################################################

1;
