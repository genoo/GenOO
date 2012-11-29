# POD documentation - main docs before the code

=head1 NAME

MyBio::GenomicRegion - Object that corresponds to a region on a genome

=head1 SYNOPSIS

    # Instantiate 
    my $genomic_region = MyBio::GenomicRegion->new({
        name         => undef,
        species      => undef,
        strand       => undef,
        chromosome   => undef,
        start        => undef,
        stop         => undef,
        copy_number  => undef,
        sequence     => undef,
    });

=head1 DESCRIPTION

    A genomic region object is an area on a reference genome. It has a
    specific start and stop position and a specific strand. The main
    difference from the the L<MyBio::Region> role is that it has the
    "chromosome" attribute instead of the generic "rname"

=head1 EXAMPLES

    # Get the genomic location information
    $genomic_region->start;      # 10
    $genomic_region->stop;       # 20
    $genomic_region->strand;     # -1
    $genomic_region->chromosome; # chrY
    $genomic_region->rname;      # chrY
    
    # Get the head (5p) position on the reference sequence
    $obj_with_role->head_position;  # 20

=cut

# Let the code begin...

package MyBio::GenomicRegion;

use Moose;
use namespace::autoclean;

has 'name'        => (isa => 'Str', is => 'rw');
has 'species'     => (isa => 'Str', is => 'rw');
has 'strand'      => (is => 'rw', required => 1);
has 'chromosome'  => (isa => 'Str', is => 'rw', required => 1);
has 'start'       => (isa => 'Int', is => 'rw', required => 1);
has 'stop'        => (isa => 'Int', is => 'rw', required => 1);
has 'copy_number' => (isa => 'Int', is => 'rw', default => 1, lazy => 1);
has 'sequence'    => (isa => 'Str', is => 'rw');
has 'extra'       => (is => 'rw');

with 'MyBio::Region';

sub BUILD {
	my $self = shift;
	
	$self->_sanitize_strand();
	$self->_sanitize_chromosome();
}

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
	my ($self) = @_;
	
	if ($self->strand eq '+') {
		$self->strand(1);
	}
	elsif ($self->strand eq '-') {
		$self->strand(-1);
	}
}

sub _sanitize_chromosome {
	my ($self) = @_;
	
	if ($self->chromosome =~ /^>/) {
		warn 'Deprecated chromosome value. Prefix ">" is no longer supported. Consider changing value before creating the object in '.(caller)[1].' line '.(caller)[2]."\n";
		my $value = $self->chromosome;
		$value =~ s/^>//;
		$self->chromosome($value);
	}
}


#######################################################################
#######################   Deprecated Methods   ########################
#######################################################################
sub get_5p {
	my ($self) = @_;
	warn 'Deprecated method "get_5p". Use "head_position" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->head_position;
}

sub get_3p {
	my ($self) = @_;
	warn 'Deprecated method "get_3p". Use "tail_position" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->tail_position;
}

sub get_5p_5p_distance_from {
	my ($self, $from_region) = @_;
	warn 'Deprecated method "get_5p_5p_distance_from". Use "head_head_distance_from" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->head_head_distance_from($from_region);
}

sub get_5p_3p_distance_from {
	my ($self, $from_region) = @_;
	warn 'Deprecated method "get_5p_3p_distance_from". Use "head_tail_distance_from" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->head_tail_distance_from($from_region);
}

sub get_3p_5p_distance_from {
	my ($self, $from_region) = @_;
	warn 'Deprecated method "get_3p_5p_distance_from". Use "tail_head_distance_from" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->tail_head_distance_from($from_region);
}

sub get_3p_3p_distance_from {
	my ($self, $from_region) = @_;
	warn 'Deprecated method "get_3p_3p_distance_from". Use "tail_tail_distance_from" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->tail_tail_distance_from($from_region);
}

sub get_species {
	my ($self) = @_;
	warn 'Deprecated method "get_species". Use "species" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->species;
}

sub get_strand {
	my ($self) = @_;
	warn 'Deprecated method "get_strand". Use "strand" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->strand;
}

sub chr {
	my ($self) = @_;
	warn 'Deprecated method "chr". Use "chromosome" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->chromosome;
}

sub get_chr {
	my ($self) = @_;
	warn 'Deprecated method "get_chr". Use "chromosome" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->chromosome;
}

sub get_start {
	my ($self) = @_;
	warn 'Deprecated method "get_start". Use "start" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->start;
}

sub get_stop {
	my ($self) = @_;
	warn 'Deprecated method "get_stop". Use "stop" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->stop;
}

sub get_sequence {
	my ($self) = @_;
	warn 'Deprecated method "get_sequence". Use "sequence" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->sequence;
}

sub get_name {
	my ($self) = @_;
	warn 'Deprecated method "get_name". Use "name" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->name;
}

sub get_length {
	my ($self) = @_;
	warn 'Deprecated method "get_length". Use "length" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->length;
}

sub get_strand_symbol {
	my ($self) = @_;
	warn 'Deprecated method "get_strand_symbol". Use "strand_symbol" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->strand_symbol;
}

sub get_id {
	my ($self) = @_;
	warn 'Deprecated method "get_id". Use "id" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->id;
}

sub get_location {
	my ($self) = @_;
	warn 'Deprecated method "get_location". Use "location" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->location;
}

__PACKAGE__->meta->make_immutable;
1;
