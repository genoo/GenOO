# POD documentation - main docs before the code

=head1 NAME

MyBio::Data::File::BED::Record - Object representing a record of a bed file

=head1 SYNOPSIS

    # Object representing a record of a bed file 

    # To initialize 
    my $record = MyBio::Data::File::BED::Record->new({
        CHR          => undef,
        START        => undef,
        STOP_1       => undef,
        NAME         => undef,
        SCORE        => undef,
        STRAND       => undef,
        THICK_START  => undef,
        THICK_STOP   => undef,
        RGB          => undef,
        BLOCK_COUNT  => undef,
        BLOCK_SIZES  => undef,
        BLOCK_STARTS => undef,
        EXTRA_INFO   => undef,
    });


=head1 DESCRIPTION

    This object represents a record of a bed file and offers methods for accessing the different attributes.
    It implements several additional methods that transform original attributes in more manageable attributes.

=head1 EXAMPLES

    # Return 1 or -1 for the strand
    my $strand = $record->strand();

=cut

# Let the code begin...

package MyBio::Data::File::BED::Record;
use strict;

use base qw( MyBio::_Initializable );

our $VERSION = '1.0';

sub _init {
	my ($self,$data) = @_;
	
	$self->set_chr($$data{CHR}); # Name of the chromosome
	$self->set_start($$data{START}); # 0-based
	$self->set_stop($$data{STOP_1}); # 1-based
	$self->set_name($$data{NAME}); # Name of the BED
	$self->set_score($$data{SCORE}); # A score between 0 and 1000
	$self->set_strand($$data{STRAND}); # The strand '+' or '-'. 
	$self->set_thick_start($$data{THICK_START}); # 0-based start position at which feature is drawn thickly
	$self->set_thick_stop($$data{THICK_STOP}); # 1-based stop position at which feature is drawn thickly
	$self->set_rgb($$data{RGB}); # An RGB value of the form R,G,B (e.g. 255,0,0)
	$self->set_block_count($$data{BLOCK_COUNT}); # The number of blocks (exons) in the BED line
	$self->set_block_sizes($$data{BLOCK_SIZES}); # A comma-separated list of the block sizes
	$self->set_block_starts($$data{BLOCK_STARTS}); # A comma-separated list of block starts.
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_chr {
	my ($self,$value) = @_;
	$self->{CHR} = $value if defined $value;
}

sub set_start {
	my ($self,$value) = @_;
	$self->{START} = $value if defined $value;
}

sub set_stop {
	my ($self,$value) = @_;
	$self->{STOP} = $value - 1 if defined $value;
}

sub set_name {
	my ($self,$value) = @_;
	$self->{NAME} = $value if defined $value;
}

sub set_score {
	my ($self,$value) = @_;
	$self->{SCORE} = $value if defined $value;
}

sub set_strand {
	my ($self,$value) = @_;
	if (defined $value) {
		if ($value eq '+') {
			$self->{STRAND} = 1;
		}
		elsif ($value eq '-') {
			$self->{STRAND} = -1;
		}
		else {
			delete $self->{STRAND};
		}
	}
}

sub set_thick_start {
	my ($self,$value) = @_;
	$self->{THICK_START} = $value if defined $value;
}

sub set_thick_stop {
	my ($self,$value) = @_;
	$self->{THICK_STOP} = $value - 1 if defined $value;
}

sub set_rgb {
	my ($self,$value) = @_;
	$self->{RGB} = $value if defined $value;
}

sub set_block_count {
	my ($self,$value) = @_;
	$self->{BLOCK_COUNT} = $value if defined $value;
}

sub set_block_sizes {
	my ($self,$value) = @_;
	$self->{BLOCK_SIZES} = $value if defined $value;
}

sub set_block_starts {
	my ($self,$value) = @_;
	$self->{BLOCK_STARTS} = $value if defined $value;
}

#######################################################################
############################   Accessors   ############################
#######################################################################
sub chr {
	my ($self) = @_;
	return $self->{CHR};
}

sub start {
	my ($self) = @_;
	return $self->{START};
}

sub stop {
	my ($self) = @_;
	return $self->{STOP};
}

sub name {
	my ($self) = @_;
	return $self->{NAME};
}

sub score {
	my ($self) = @_;
	return $self->{SCORE};
}

sub strand {
	my ($self) = @_;
	return $self->{STRAND};
}

sub thick_start {
	my ($self) = @_;
	return $self->{THICK_START};
}

sub thick_stop {
	my ($self) = @_;
	return $self->{THICK_STOP};
}

sub rgb {
	my ($self) = @_;
	return $self->{RGB};
}

sub block_count {
	my ($self) = @_;
	return $self->{BLOCK_COUNT};
}

sub block_sizes {
	my ($self) = @_;
	return $self->{BLOCK_SIZES};
}

sub block_starts {
	my ($self) = @_;
	return $self->{BLOCK_STARTS};
}

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
	return undef;
}

#######################################################################
#########################   General Methods   #########################
#######################################################################

1;
