# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::File::GFF::Record - Object representing a record of a gff file

=head1 SYNOPSIS

    # Object representing a record of a gff file 

    # To initialize 
    my $record = GenOO::Data::File::GFF::Record->new(
        seqname       => undef,
        source        => undef,
        feature       => undef,
        start_1_based => undef,
        stop_1_based  => undef,
        score         => undef,
        strand        => undef,
        frame         => undef,
        attributes    => undef,
        comment       => undef,
        extra_info    => undef,
    );


=head1 DESCRIPTION

    This object represents a record of a gff file and offers methods for accessing the different attributes.
    It transforms original attributes into ones compatible with the rest of the framework eg 1-based to 0-based.

=head1 EXAMPLES

    # Return 1 or -1 for the strand
    my $strand = $record->strand();

=cut

# Let the code begin...


package GenOO::Data::File::GFF::Record;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;


#######################################################################
#######################   Subtypes & Coercions   ######################
#######################################################################
subtype 'GenOO::Data::File::GFF::Record::Strand', as 'Int', where {($_ == 1) or ($_ == -1) or ($_ == 0)};
coerce 'GenOO::Data::File::GFF::Record::Strand', from 'Str', via { _sanitize_strand($_) };


#######################################################################
#######################   Interface attributes   ######################
#######################################################################
has 'seqname' => (
	isa      => 'Str',
	is       => 'ro',
	required => 1
); # The name of the sequence

has 'source' => (
	isa      => 'Str',
	is       => 'ro',
	required => 1
); # The source of the feature

has 'feature' => (
	isa      => 'Str',
	is       => 'ro',
	required => 1
); # The feature type name

has 'start_1_based' => (
	isa      => 'Int',
	is       => 'ro',
	required => 1
); # 1-based

has 'stop_1_based' => (
	isa      => 'Int',
	is       => 'ro',
	required => 1
); # 1-based

has 'score' => (
	is       => 'ro',
	required => 1
); # A floating point value.

has 'strand' => (
	isa      => 'GenOO::Data::File::GFF::Record::Strand',
	is       => 'ro',
	required => 1,
	coerce => 1
); # One of +, - or .

has 'frame' => (
	is       => 'ro',
	required => 1
); # 0, 1, 2, .. Is region in frame?

has 'comment' => (
	isa      => 'Maybe[Str]',
	is       => 'ro',
	required => 1
); # A comment

has 'attributes' => (
	traits    => ['Hash'],
	is        => 'ro',
	isa       => 'HashRef[Str]',
	default   => sub { {} },
	handles   => {
		set_attribute => 'set',
		attribute     => 'get',
	},
); # Hash with attribute-value (strings)

has 'rname' => (
	isa      => 'Str',
	is       => 'ro',
	builder  => '_set_rname',
	lazy     => 1
);

has 'start' => (
	isa      => 'Int',
	is       => 'ro',
	builder  => '_calculate_start',
	lazy     => 1
);

has 'stop' => (
	isa      => 'Int',
	is       => 'ro',
	builder  => '_calculate_stop',
	lazy     => 1
);

with 'GenOO::Region';


#######################################################################
############################   Accessors   ############################
#######################################################################
sub copy_number {
	return 1;
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

#######################################################################
#########################   Private methods  ##########################
#######################################################################
sub _sanitize_strand {
	my ($value) = @_;
	
	if ($value eq '+') {
		return 1;
	}
	elsif ($value eq '-') {
		return -1;
	}
	elsif ($value eq '.') {
		return 0;
	}
}

sub _set_rname {
	my ($self) = @_;
	
	return $self->seqname;
}

sub _calculate_start {
	my ($self) = @_;
	
	return $self->start_1_based - 1;
}

sub _calculate_stop {
	my ($self) = @_;
	
	return $self->stop_1_based - 1;
}

#######################################################################
############################   Finalize   #############################
#######################################################################
__PACKAGE__->meta->make_immutable;

1;
