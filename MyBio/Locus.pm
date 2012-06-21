# POD documentation - main docs before the code

=head1 NAME

MyBio::Locus - Object that represents an area in the genome

=head1 SYNOPSIS

    # Instantiate 
    my $locus = MyBio::Locus->new({
        SPECIES      => undef,
        STRAND       => undef,
        CHR          => undef,
        START        => undef,
        STOP         => undef,
        SEQUENCE     => undef,
        NAME         => undef,
        EXTRA_INFO   => undef,
    });


=head1 DESCRIPTION

    This class corresponds to an area in the genome.

=head1 EXAMPLES

    # Get locus start
    $locus->start();

=cut

# Let the code begin...

package MyBio::Locus;
use strict;

use base qw( MyBio::_Initializable Clone);
use MyBio::MyMath;

sub _init {
	my ($self,$data) = @_;
	
	$self->set_species($$data{SPECIES});
	$self->set_strand($$data{STRAND});
	$self->set_chr($$data{CHR});
	$self->set_start($$data{START});
	$self->set_stop($$data{STOP});
	$self->set_sequence($$data{SEQUENCE});
	$self->set_name($$data{NAME});
	$self->set_extra($$data{EXTRA_INFO});
	
	return $self;
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_species {
	my ($self, $value) = @_;
	$self->{SPECIES} = uc($value) if defined $value;
}

sub set_strand {
	my ($self,$value) = @_;
	
	if (defined $value) {
		$value =~ s/^\+$/1/;
		$value =~ s/^\-$/-1/;
		$self->{STRAND} = $value;
	}
}

sub set_chr {
	my ($self,$value) = @_;
	
	if (defined $value) {
		$value =~ s/^>*//;
		$self->{CHR} = $value;
	}
}

sub set_start {
	my ($self, $value) = @_;
	$self->{START} = $value if defined $value;
}

sub set_stop {
	my ($self, $value) = @_;
	$self->{STOP} = $value if defined $value;
}

sub set_sequence {
	my ($self,$value) = @_;
	
	if (defined $value) {
		unless ($value =~ /^[ATGCUN]*$/i) {
			$value =~ /([^ATGCUN])/i;
			warn "The nucleotide sequence provided for ".$self->name()." contains the following invalid characters $1 in $self\n";
		}
		$self->{SEQUENCE} = $value;
	}
}

sub set_name {
	my ($self,$value) = @_;
	$self->{NAME} = $value if defined $value;
}

#######################################################################
############################   Accessors   ############################
#######################################################################
sub species {
	my ($self) = @_;
	return $self->{SPECIES};
}

sub strand {
	my ($self) = @_;
	return $self->{STRAND};
}

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

sub sequence {
	my ($self) = @_;
	return $self->{SEQUENCE};
}

sub name {
	my ($self) = @_;
	return $self->{NAME};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub id {
	my ($self) = @_;
	return $self->location;
}

sub location {
	my ($self) = @_;
	return $self->chr . ':' . $self->start . '-' . $self->stop . ':' . $self->strand;
}

sub length {
	my ($self) = @_;
	
	if (defined $self->{LENGTH}) {
		return $self->{LENGTH};
	}
	elsif (defined $self->{SEQUENCE}) {
		return $self->{LENGTH} = length($self->sequence);
	}
	else {
		return $self->{LENGTH} = $self->stop - $self->start + 1;
	}
	
}

sub strand_symbol {
	my ($self) = @_;
	
	if ($self->strand == 1) {
		return '+';
	}
	elsif ($self->strand == -1) {
		return '-';
	}
	return undef;
}

sub get_5p {
	my ($self) = @_;
	
	if ($self->strand == 1) {
		return $self->start;
	}
	elsif ($self->strand == -1) {
		return $self->stop;
	}
	else {
		return undef;
	}
}

sub get_3p {
	my ($self) = @_;
	
	if ($self->strand == 1) {
		return $self->stop;
	}
	elsif ($self->strand == -1) {
		return $self->start;
	}
	else {
		return undef;
	}
}

sub get_5p_5p_distance_from {
	my ($self, $from_locus) = @_;
	return ($self->get_5p - $from_locus->get_5p) * $self->strand;
}

sub get_5p_3p_distance_from {
	my ($self, $from_locus) = @_;
	return ($self->get_5p - $from_locus->get_3p) * $self->strand;
}

sub get_3p_5p_distance_from {
	my ($self, $from_locus) = @_;
	return ($self->get_3p - $from_locus->get_5p) * $self->strand;
}

sub get_3p_3p_distance_from {
	my ($self, $from_locus) = @_;
	return ($self->get_3p - $from_locus->get_3p) * $self->strand;
}

sub to_string {
	my ($self, $params) = @_;
	
	#changed from the old ($self,$method,@attributes) way to the new ($self,$params) way
	my $method;
	if ($params eq 'BED'){
		warn "Don't panic - Just use hash notation when calling ".(caller(0))[3]." in script $0 - Your output is ok.\n";
		$method = 'BED';
	}
	else {
		$method = exists $params->{'METHOD'} ? $params->{'METHOD'} : undef;
	}
	
	if ($method eq 'BED') {
		return $self->to_string_bed;
	}
	else {
		die "\n\nUnknown or no method provided when calling ".(caller(0))[3]." in script $0\n\n";
	}
}

sub to_string_bed {
	my ($self) = @_;
	
	my $strand = defined $self->strand_symbol ? $self->strand_symbol : ".";
	my $name = defined $self->name ? $self->name : ".";
	return $self->chr."\t".$self->start."\t".($self->stop+1)."\t".$name."\t".'0'."\t".$strand;
}

sub overlaps {
	my ($self,$loc2,$params) = @_;
	
	if ((!defined $params) or (UNIVERSAL::isa( $params, "HASH" ))){
		my $offset = defined $params->{OFFSET} ? $params->{OFFSET} : 0;
		my $use_strand = defined $params->{USE_STRAND} ? $params->{USE_STRAND} : 0;
		
		if ((($use_strand == 0) or ($self->strand eq $loc2->strand)) and ($self->chr eq $loc2->chr) and (($self->start-$offset) <= $loc2->stop) and ($loc2->start <= ($self->stop+$offset))) {
			return 1; #overlap
		}
		else {
			return 0; #no overlap
		}
	}
	else {
		die "\n\nUnknown or no method provided when calling ".(caller(0))[3]." in script $0\n\n";
	}
}

=head2 get_overlap_length
  Arg [1]    : locus. Locus object self is compared to.
  Description: Return the number of nucleotides of self that are covered by provided locus
  Returntype : int
=cut
sub get_overlap_length {
	my ($self, $loc2) = @_;
	
	unless ($self->overlaps($loc2)){return 0;}
	my $nt_overlap = $loc2->length;
	if ($loc2->start < $self->start){$nt_overlap -= ($self->start - $loc2->start);} #left overhang removed
	if ($loc2->stop > $self->stop){$nt_overlap -= ($loc2->stop - $self->stop);} #right overhang removed
	return $nt_overlap;
}

sub contains {
	my ($self,$loc2,$params) = @_;
	
	if ((!defined $params) or (UNIVERSAL::isa( $params, "HASH" ))){
		my $percent = defined $params->{PERCENT} ? $params->{PERCENT} : 1;
		my $overhang = 0;
		my $left_overhang = ($self->start - $loc2->start);
		my $right_overhang = ($loc2->stop - $self->stop);
		if ($left_overhang > 0){$overhang += $left_overhang;}
		if ($right_overhang > 0){$overhang += $right_overhang;}
		if (($overhang / $loc2->length) <= (1-$percent)){return 1;}
		return 0;
	}
	else {
		die "\n\nUnknown or no method provided when calling ".(caller(0))[3]." in script $0\n\n";
	}
}

sub contains_position {
	my ($self, $position) = @_;
	
	if (($self->start <= $position) and ($position <= $self->stop)) {
		return 1;
	}
	else {return 0;}
}

=head2 get_contained_locuses

  Arg [1]    : array reference. Reference to an array of locus objects
  Description: Return an array of locus objects containing the parts (or the whole) objects of the array that are contained within $self
                       ---------------------------------------------
               ---    ---              ---       ----            ------   ---
                                     returns
                       --              ---       ----            ---               
  Returntype : array reference
=cut
sub get_contained_locuses {
	my ($self, $array) = @_;
	
	my @outarray;
	if ((defined $self->start) and (defined $self->stop)) {
		foreach my $region (@{$array}) {
			if ($region->chr ne $self->chr){next;} #chromosome check! don't align things in diff chromosome
			if ($self->contains($region)){push @outarray, $region;} #fully contained in self
			elsif ($self->overlaps($region)) {
				my $class = ref($region) || $region;
				my $partLocus = $class->new({
					SPECIES      => $region->species,
					STRAND       => $region->strand,
					CHR          => $region->chr,
					START        => (MyBio::MyMath::max( [$region->start, $self->start] ))[1],
					STOP         => (MyBio::MyMath::min( [$region->stop, $self->stop] ))[1],
					SEQUENCE     => undef, #not sure what to do with seq!!!
					EXTRA_INFO   => $region->get_extra,
				});
				push @outarray, $partLocus;
			}
			else {
				next; #no overlap
			}
		}
	}
	return \@outarray;
}

=head2 get_touching_locuses

  Arg [1]    : array reference. Reference to an array of locus objects
  Description: Return the locus objects from the given array that overlap with $self within an $offset
                       ---------------------------------------------
               ---    ---              ---       ----              ------    -------
                                     returns
                      ---              ---       ----              ------                
  Returntype : array reference
=cut
sub get_touching_locuses {
	my ($self, $array, $offset) = @_;
	
	my @outarray;
	if ((defined $self->start) and (defined $self->stop)) {		
		foreach my $region (@{$array}) {
			if ($region->chr ne $self->chr){next;} #chromosome check! don't align things in diff chromosome
			if ($self->overlaps($region,$offset)){push @outarray, $region;} #overlaps with self
			else {next;} #no overlap
		}
	}
	return \@outarray;
}

#######################################################################
#######################   Deprecated Methods   ########################
#######################################################################
sub get_species {
	my ($self) = @_;
	warn 'Deprecated method "get_species". Consider using "species" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->species;
}

sub get_strand {
	my ($self) = @_;
	warn 'Deprecated method "get_strand". Consider using "strand" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->strand;
}

sub get_chr {
	my ($self) = @_;
	warn 'Deprecated method "get_chr". Consider using "chr" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->chr;
}

sub get_start {
	my ($self) = @_;
	warn 'Deprecated method "get_start". Consider using "start" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->start;
}

sub get_stop {
	my ($self) = @_;
	warn 'Deprecated method "get_stop". Consider using "stop" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->stop;
}

sub get_sequence {
	my ($self) = @_;
	warn 'Deprecated method "get_sequence". Consider using "sequence" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->sequence;
}

sub get_name {
	my ($self) = @_;
	warn 'Deprecated method "get_name". Consider using "name" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->name;
}

sub get_length {
	my ($self) = @_;
	warn 'Deprecated method "get_length". Consider using "length" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->length;
}

sub get_strand_symbol {
	my ($self) = @_;
	warn 'Deprecated method "get_strand_symbol". Consider using "strand_symbol" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->strand_symbol;
}

sub get_id {
	my ($self) = @_;
	warn 'Deprecated method "get_id". Consider using "id" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->id;
}

sub get_location {
	my ($self) = @_;
	warn 'Deprecated method "get_location". Consider using "location" instead '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->location;
}

1;
