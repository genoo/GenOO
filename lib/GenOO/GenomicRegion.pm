# POD documentation - main docs before the code

=head1 NAME

GenOO::GenomicRegion - Object that corresponds to a region on a genome

=head1 SYNOPSIS
    
    # This object represents a genomic region (location on the genome)
    # It extends the L<GenOO::Region> object
    
    # Instantiate 
    my $genomic_region = GenOO::GenomicRegion->new(
        name         => undef,
        species      => undef,
        strand       => undef,    #required
        chromosome   => undef,    #required
        start        => undef,    #required
        stop         => undef,    #required
        copy_number  => undef,    #defaults to 1
        sequence     => undef,
    );

=head1 DESCRIPTION

    A genomic region object is an area on a reference genome. It has a
    specific start and stop position and specific strand and chromosome.
    The main difference from the the L<GenOO::Region> role is that it has the
    "chromosome" attribute instead of the generic "rname". The copy number
    attribute is useful when counting aligned reads so that the number of
    reads in this specific location can be collapsed. It defaults to 1.
    See L<GenOO::Region> and for more available methods

=head1 EXAMPLES
    
    my $genomic_region = GenOO::GenomicRegion->new(
        name        => 'test_object_0',
        species     => 'human',
        strand      => '+',
        chromosome  => 'chr1',
        start       => 3,
        stop        => 10,
        copy_number => 7,
        sequence    => 'AGCTAGCU'
    );
    # Get the genomic location information
    $genomic_region->start;      # 3
    $genomic_region->stop;       # 10
    $genomic_region->strand;     # 1
    $genomic_region->chromosome; # chr1
    $genomic_region->rname;      # chr1 - this is always the same as chromosome
    
    # Get the head (5p) position on the reference sequence
    $genomic_region->head_position;  # 3 - this method comes from L<GenOO::Region>

=cut

# Let the code begin...

package GenOO::GenomicRegion;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Modern::Perl;
use autodie;
use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

subtype 'RegionStrand', as 'Int', where {($_ == 1) or ($_ == -1)};

coerce 'RegionStrand', from 'Str', via { _sanitize_strand($_) };


#######################################################################
#######################   Interface attributes   ######################
#######################################################################
has 'name' => (
	isa => 'Str',
	is  => 'rw'
);

has 'species' => (
	isa => 'Str',
	is  => 'rw'
);

has 'strand' => (
	isa      => 'RegionStrand',
	is       => 'rw',
	required => 1,
	coerce   => 1
);

has 'chromosome' => (
	isa      => 'Str',
	is       => 'rw',
	required => 1
);

has 'start' => (
	isa      => 'Int',
	is       => 'rw',
	required => 1
);

has 'stop' => (
	isa      => 'Int',
	is       => 'rw',
	required => 1
);

has 'copy_number' => (
	isa     => 'Int',
	is      => 'rw',
	default => 1,
	lazy    => 1
);

has 'sequence' => (
	isa => 'Str',
	is  => 'rw'
);

has 'extra' => (
	is => 'rw'
);


#######################################################################
##########################   Consumed Roles   #########################
#######################################################################
with 'GenOO::Region';


#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub rname {
	my ($self) = @_;
	
	return $self->chromosome;
}

sub id {
	my ($self) = @_;
	
	return $self->location;
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
}


#######################################################################
############################   Finalize   #############################
#######################################################################
__PACKAGE__->meta->make_immutable;
1;
