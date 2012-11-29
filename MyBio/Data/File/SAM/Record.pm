# POD documentation - main docs before the code

=head1 NAME

MyBio::Data::File::SAM::Record - Object representing a record of a sam file

=head1 SYNOPSIS

    # Object representing a record of a sam file 

    # To initialize 
    my $sam_record = MyBio::Data::File::SAM::Record->new({
        qname      => undef,
        flag       => undef,
        rname      => undef,
        pos        => undef,
        mapq       => undef,
        cigar      => undef,
        rnext      => undef,
        pnext      => undef,
        tlen       => undef,
        seq        => undef,
        qual       => undef,
        tags       => undef,
        extra      => undef,
    });


=head1 DESCRIPTION

    This object represents a record of a sam file and offers methods for accessing the different attributes.
    It implements several additional methods that transform original attributes in more manageable attributes.
    eg. from the FLAG attribute the actual strand is extracted etc.

=head1 EXAMPLES

    # Check if the record corresponds to a match
    my $mapped = $sam_record->is_mapped;
    
    # Check if the record corresponds to a non match
    my $unmapped = $sam_record->is_unmapped;
    
    # Parse the FLAG attribute and return 1 or -1 for the strand
    my $strand = $sam_record->strand;

=cut

# Let the code begin...

package MyBio::Data::File::SAM::Record;

use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

subtype 'HashRefOfTags', as 'HashRef';
coerce 'HashRefOfTags', from 'ArrayRef',via { _coerce_arrayref_to_hashref_for_tags($_) };

has 'qname' => (isa => 'Str', is => 'rw'); # String [!-?A-~]f1,255g Query template NAME
has 'flag' => (isa => 'Int', is => 'rw');  # Int [0,216-1] bitwise FLAG
has 'rname' => (isa => 'Str', is => 'rw'); # String \*|[!-()+-<>-~][!-~]* Reference sequence NAME
has 'pos' => (isa => 'Int', is => 'rw');   # Int [0,229-1] 1-based leftmost mapping POSition
has 'mapq' => (isa => 'Int', is => 'rw');  # Int [0,28-1] MAPping Quality
has 'cigar' => (isa => 'Str', is => 'rw'); # String \*|([0-9]+[MIDNSHPX=])+ CIGAR string
has 'rnext' => (isa => 'Str', is => 'rw'); # String \*|=|[!-()+-<>-~][!-~]* Ref. name of the mate/next segment
has 'pnext' => (isa => 'Int', is => 'rw'); # Int [0,229-1] Position of the mate/next segment
has 'tlen' => (isa => 'Int', is => 'rw');  # Int [-229+1,229-1] observed Template LENgth
has 'seq' => (isa => 'Str', is => 'rw');   # String \*|[A-Za-z=.]+ segment SEQuence
has 'qual' => (isa => 'Str', is => 'rw');  # String [!-~]+ ASCII of Phred-scaled base QUALity+33
has 'tags' => (isa => 'HashRefOfTags', is => 'rw', coerce => 1,); # Extra tags
has 'extra' => (is => 'rw');

has 'alignment_length' => (
	is        => 'ro',
	builder   => '_calculate_alignment_length',
	init_arg  => undef,
	lazy      => 1,
);

has 'start' => (
	is        => 'ro',
	builder   => '_calculate_start',
	init_arg  => undef,
	lazy      => 1,
);

has 'stop' => (
	is        => 'ro',
	builder   => '_calculate_stop',
	init_arg  => undef,
	lazy      => 1,
);

has 'strand' => (
	is        => 'ro',
	builder   => '_calculate_strand',
	init_arg  => undef,
	lazy      => 1,
);

#######################################################################
########################   Interface Methods   ########################
#######################################################################
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
	}
	return undef;
}

sub query_seq {
	my ($self) = @_;
	
	if (defined $self->strand) {
		if ($self->strand == 1) {
			return $self->seq;
		}
		elsif ($self->strand == -1) {
			my $seq = reverse($self->seq);
			$seq =~ tr/ATGCUatgcu/TACGAtacga/;
			return $seq;
		}
	}
	elsif ($self->is_unmapped) {
		return $self->seq;
	}
	else {
		return undef;
	}
}

sub query_length {
	my ($self) = @_;
	return CORE::length($self->seq); # using seq to avoid costs of query_seq
}

sub tag {
	my ($self, $tag_id) = @_;
	
	if (defined $self->tags) {
		return $self->tags->{$tag_id};
	}
}

sub number_of_best_hits {
	my ($self) = @_;
	return $self->tag('X0:i');
}

sub number_of_suboptimal_hits {
	my ($self) = @_;
	return $self->tag('X1:i');
}

sub alternative_mappings {
	my ($self) = @_;
	
	my @alternative_mappings;
	my $value = $self->tag('XA:Z');
	if (defined $value) {
		@alternative_mappings = split(/;/,$value);
	}
	return @alternative_mappings;
}

sub insertion_count {
	my ($self) = @_;
	
	my $insertion_count = 0;
	my $cigar = $self->cigar;
	while ($cigar =~ /(\d)I/g) {
		$insertion_count += $1;
	}
	return $insertion_count;
}

sub deletion_count {
	my ($self) = @_;
	
	my $deletion_count = 0;
	my $cigar = $self->cigar;
	while ($cigar =~ /(\d)D/g) {
		$deletion_count += $1;
	}
	return $deletion_count;
}

sub deletion_positions_on_query {
	my ($self) = @_;
	#Tag:    AGTGATGGGA------GGATGTCTCGTCTGTGAGTTACAGCA -> CIGAR: 2M1I7M6D26M
	#            -   -
	#Genome: AG-GCTGGTAGCTCAGGGATGTCTCGTCTGTGAGTTACAGCA -> MD:Z:  3C3T1^GCTCAG26
	
	my @deletion_positions;
	if ($self->cigar =~ /D/) {
		my $cigar = $self->cigar_relative_to_query;
		
		my $relative_position = 0;
		while ($cigar =~ /(\d+)([A-Z])/g) {
			my $count = $1;
			my $identifier = $2;
			
			if ($identifier eq 'D') {
				push @deletion_positions, $relative_position;
			}
			else {
				$relative_position += $count;
			}
		}
	}
	
	return @deletion_positions;
}

sub deletion_positions_on_reference {
	my ($self) = @_;
	#Tag:    AGTGATGGGA------GGATGTCTCGTCTGTGAGTTACAGCA -> CIGAR: 2M1I7M6D26M
	#            -   -
	#Genome: AG-GCTGGTAGCTCAGGGATGTCTCGTCTGTGAGTTACAGCA -> MD:Z:  3C3T1^GCTCAG26
	
	my @deletion_positions;
	my $mdz = $self->tag('MD:Z');
	
	if ($mdz =~ /\^/) {
		my $relative_position = 0;
		while ($mdz ne '') {
			if ($mdz =~ s/^(\d+)//) {
				$relative_position += $1;
			}
			elsif ($mdz =~ s/^\^([A-Z]+)//) {
				my $deletion_length = CORE::length($1);
				for (my $i=0;$i<$deletion_length;$i++) {
					push @deletion_positions, $self->start + $relative_position + $i;
				}
				$relative_position += $deletion_length;
			}
			elsif ($mdz =~ s/^\w//) {
				$relative_position += 1;
			}
		}
	}
	
	return @deletion_positions;
}

sub mismatch_positions_on_reference {
	my ($self) = @_;
	#Tag:    AGTGATGGGA------GGATGTCTCGTCTGTGAGTTACAGCA -> CIGAR: 2M1I7M6D26M
	#            -   -
	#Genome: AG-GCTGGTAGCTCAGGGATGTCTCGTCTGTGAGTTACAGCA -> MD:Z:  3C3T1^GCTCAG26

	my @mismatch_positions;
	my $mdz = $self->tag('MD:Z');
	
	if ($mdz =~ /\^/) {
		my $relative_position = 0;
		while ($mdz ne '') {
			if ($mdz =~ s/^(\d+)//) {
				$relative_position += $1;
			}
			elsif ($mdz =~ s/^\^([A-Z]+)//) {
				my $deletion_length = CORE::length($1);
				$relative_position += $deletion_length;
			}
			elsif ($mdz =~ s/^\w//) {
				push @mismatch_positions, $self->start + $relative_position;
				$relative_position += 1;
			}
		}
	}
	
	return @mismatch_positions;
}

sub mismatch_positions_on_query {
	my ($self) = @_;
	#Tag:    AGTGATGGGA------GGATGTCTCGTCTGTGAGTTACAGCA -> CIGAR: 2M1I7M6D26M
	#            -   -
	#Genome: AG-GCTGGTAGCTCAGGGATGTCTCGTCTGTGAGTTACAGCA -> MD:Z:  3C3T1^GCTCAG26
	
	my $cigar = $self->cigar;
	
	# Find positions of insertions and deletions (dashes) on the query sequence
	my @deletion_positions;
	my @insertion_positions;
	my $position = 0;
	while ($cigar =~ /(\d+)([A-Z])/g) {
		my $count = $1;
		my $identifier = $2;
		
		if ($identifier eq 'D') {
			push (@deletion_positions, $position + $_) for (0..$count-1)
		}
		elsif ($identifier eq 'I') {
			push (@insertion_positions, $position + $_) for (0..$count-1)
		}
		$position += $count;
	}
	
	my @mismatch_positions_on_reference = $self->mismatch_positions_on_reference;
	my @relative_mismatch_positions_on_reference = map {$_ - $self->start} @mismatch_positions_on_reference;
	
	my @mismatch_positions;
	foreach my $relative_mismatch_position_on_reference (@relative_mismatch_positions_on_reference) {
		my $deletion_adjustment = _how_many_are_smaller($relative_mismatch_position_on_reference, \@deletion_positions);
		my $insertion_adjustment = _how_many_are_smaller($relative_mismatch_position_on_reference, \@insertion_positions);
		
		my $mismatch_position_on_query = $relative_mismatch_position_on_reference - $deletion_adjustment + $insertion_adjustment;
		
		if ($self->strand == -1) {
			$mismatch_position_on_query = ($self->query_length - 1) - $mismatch_position_on_query;
		}
		
		push @mismatch_positions, $mismatch_position_on_query;
	}
	
	return @mismatch_positions;
}

sub cigar_relative_to_query {
	my ($self) = @_;
	
	my $cigar = $self->cigar;
	
	# if negative strand -> reverse the cigar string
	if (defined $self->strand and ($self->strand == -1)) {
		my $reverse_cigar = '';
		while ($cigar =~ /(\d+)([A-Z])/g) {
			$reverse_cigar = $1.$2.$reverse_cigar;
		}
		return $reverse_cigar;
	}
	else {
		return $cigar;
	}
}

sub to_string {
	my ($self) = @_;
	
	my $tags_string = join("\t", map{$_.':'.$self->tag($_)} keys %{$self->tags});
	return join("\t",$self->qname, $self->flag, $self->rname, $self->pos, $self->mapq, $self->cigar, $self->rnext, $self->pnext, $self->tlen, $self->seq, $self->qual, $tags_string);
}

sub is_mapped {
	my ($self) = @_;
	
	if ($self->flag & 4) {
		return 0;
	}
	else {
		return 1;
	}
}

sub is_unmapped {
	my ($self) = @_;
	
	if ($self->flag & 4) {
		return 1;
	}
	else {
		return 0;
	}
}

#######################################################################
#########################   Private methods  ##########################
#######################################################################
sub _calculate_alignment_length {
	my ($self) = @_;
	return $self->stop - $self->start + 1;
}

sub _calculate_start {
	my ($self) = @_;
	return $self->pos - 1;
}

sub _calculate_stop {
	my ($self) = @_;
	return $self->start + $self->query_length - 1 - $self->insertion_count + $self->deletion_count;
}

sub _calculate_strand {
	my ($self) = @_;
	
	if ($self->flag & 16) {
		return -1;
	}
	elsif ($self->is_mapped) {
		return 1;
	}
	else {
		return undef;
	}
}

#######################################################################
#######################   Private subroutines  ########################
#######################################################################
sub _coerce_arrayref_to_hashref_for_tags {
	my ($value) = @_;
	
	my $hash_ref = {};
	if (defined $value) {
		foreach my $tag_var (@$value) { #"XT:A:R\tNM:i:0\tX0:i:2\tX1:i:0\tXM:i:0\tXO:i:0\tXG:i:0\tMD:Z:32\tXA:Z:chr9,+110183777,32M,0;"
			my ($tag, $tag_type, $tag_value) = split(/:/,$tag_var);
			$hash_ref->{"$tag:$tag_type"} = $tag_value;
		}
	}
	return $hash_ref;
}

sub _how_many_are_smaller {
	my ($value, $array) = @_;
	
	my $count = 0;
	foreach my $array_value (@$array) {
		if ($array_value < $value) {
			$count++;
		}
	}
	return $count;
}

#######################################################################
#######################   Deprecated Methods   ########################
#######################################################################
sub length {
	my ($self) = @_;
	warn 'Deprecated method "length". Consider using "alignment_length" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->alignment_length;
}

__PACKAGE__->meta->make_immutable;
1;
