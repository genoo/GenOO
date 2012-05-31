# POD documentation - main docs before the code

=head1 NAME

MyBio::Data::File::GFF::Record - Object representing a record of a gff file

=head1 SYNOPSIS

    # Object representing a record of a gff file 

    # To initialize 
    my $record = MyBio::Data::File::GFF::Record->new({
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
    my $strand = $record->get_strand();

=head1 AUTHOR - Manolis Maragkakis

Email em.maragkakis@gmail.com

=cut

# Let the code begin...

package MyBio::Data::File::GFF::Record;
use strict;

use base qw( MyBio::_Initializable );

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
			$self->get_attributes->{$1} = $2;
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
sub get_seqname {
	my ($self) = @_;
	return $self->{SEQNAME};
}
sub get_source {
	my ($self) = @_;
	return $self->{SOURCE};
}
sub get_feature {
	my ($self) = @_;
	return $self->{FEATURE};
}
sub get_start {
	my ($self) = @_;
	return $self->{START};
}
sub get_stop {
	my ($self) = @_;
	return $self->{STOP};
}
sub get_score {
	my ($self) = @_;
	return $self->{SCORE};
}
sub get_strand {
	my ($self) = @_;
	return $self->{STRAND};
}
sub get_frame {
	my ($self) = @_;
	return $self->{FRAME};
}
sub get_attributes {
	my ($self) = @_;
	return $self->{ATTRIBUTES};
}
sub get_comment {
	my ($self) = @_;
	return $self->{COMMENT};
}

#######################################################################
############################   Accessors   ############################
#######################################################################
sub get_length {
	my ($self) = @_;
	return $self->get_stop - $self->get_start + 1;
}
sub get_strand_symbol {
	my ($self) = @_;
	
	my $strand = $self->get_strand;
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
sub get_attribute {
	my ($self, $attribute) = @_;
	
	if (defined $self->get_attributes) {
		return $self->get_attributes->{$attribute};
	}
}

#######################################################################
#########################   General Methods   #########################
#######################################################################

1;
