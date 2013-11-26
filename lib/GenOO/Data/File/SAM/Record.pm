# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::File::SAM::Record - Object representing a record of a sam file

=head1 SYNOPSIS

    # Object representing a record of a sam file 

    # To initialize 
    my $sam_record = GenOO::Data::File::SAM::Record->new(
        fields => [qname,flag, rname, pos, mapq, cigar,
                   rnext, pnext, tlen, seq, qual, tags]
    );


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

package GenOO::Data::File::SAM::Record;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Modern::Perl;
use autodie;
use Moose;
use namespace::autoclean;


#######################################################################
#######################   Interface attributes   ######################
#######################################################################
has 'fields' => (
	traits  => ['Array'],
	is      => 'ro',
	isa     => 'ArrayRef[Str]',
	default => sub { [] },
	handles => {
		all_fields    => 'elements',
		add_field     => 'push',
		map_fields    => 'map',
		filter_fields => 'grep',
		find_field    => 'first',
		get_field     => 'get',
		join_fields   => 'join',
		count_fields  => 'count',
		has_fields    => 'count',
		has_no_fields => 'is_empty',
		sorted_fields => 'sort',
	},
	required => 1,
);

has 'tags' => (
	is        => 'ro',
	builder   => '_read_tags',
	init_arg  => undef,
	lazy      => 1,
);

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

has 'copy_number' => (
	is      => 'ro',
	default => 1,
	lazy    => 1
);

has 'extra' => (
	is        => 'rw',
	init_arg  => undef,
);


#######################################################################
##########################   Consumed Roles   #########################
#######################################################################
with
	'GenOO::Region' => {
		-alias    => { mid_position => 'region_mid_position' },
		-excludes => 'mid_position',
	},
	'GenOO::Data::File::SAM::CigarAndMDZ' => {
	};



#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub qname { # String [!-?A-~]f1,255g Query template NAME
	my ($self) = @_;
	
	return $self->fields->[0];
}

sub flag { # Int [0,216-1] bitwise FLAG
	my ($self) = @_;
	
	return $self->fields->[1];
}

sub rname { # String \*|[!-()+-<>-~][!-~]* Reference sequence NAME
	my ($self) = @_;
	
	return $self->fields->[2];
}

sub pos { # Int [0,229-1] 1-based leftmost mapping POSition
	my ($self) = @_;
	
	return $self->fields->[3];
}

sub mapq { # Int [0,28-1] MAPping Quality
	my ($self) = @_;
	
	return $self->fields->[4];
}

sub cigar { # String \*|([0-9]+[MIDNSHPX=])+ CIGAR string
	my ($self) = @_;
	
	return $self->fields->[5];
}

sub rnext { # String \*|=|[!-()+-<>-~][!-~]* Ref. name of the mate/next segment
	my ($self) = @_;
	
	return $self->fields->[6];
}

sub pnext { # Int [0,229-1] Position of the mate/next segment
	my ($self) = @_;
	
	return $self->fields->[7];
}

sub tlen { # Int [-229+1,229-1] observed Template LENgth
	my ($self) = @_;
	
	return $self->fields->[8];
}

sub seq { # String \*|[A-Za-z=.]+ segment SEQuence
	my ($self) = @_;
	
	return $self->fields->[9];
}

sub qual { # String [!-~]+ ASCII of Phred-scaled base QUALity+33
	my ($self) = @_;
	
	return $self->fields->[10];
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

sub mdz {
	my ($self) = @_;
	
	return $self->tag('MD:Z');
}

sub to_string {
	my ($self) = @_;
	
	return $self->join_fields("\t");
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
	
	return $self->length;
}

sub _calculate_start {
	my ($self) = @_;
	
	return $self->pos - 1;
}

sub _calculate_stop {
	my ($self) = @_;
	
	return $self->start + $self->M_count + $self->D_count + $self->N_count + $self->EQ_count  + $self->X_count  + $self->P_count - 1;
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

sub _read_tags {
	my ($self) = @_;
	
	my %tags;
	
	my @tags_array = @{$self->fields}[11..$self->count_fields-1];
	foreach my $tag_var (@tags_array) { 
		my ($tag, $tag_type, $tag_value) = split(/:/,$tag_var);
		$tags{"$tag:$tag_type"} = $tag_value;
	}
	
	return \%tags;
}


#######################################################################
############################   Finalize   #############################
#######################################################################
__PACKAGE__->meta->make_immutable;

1;
