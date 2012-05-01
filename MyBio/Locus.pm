package MyBio::Locus;
use strict;

use base qw( MyBio::_Initializable Clone);
use MyBio::MyMath;

# HOW TO INITIALIZE THIS OBJECT
# my $Locus = MyBio::Locus->new({
# 		     SPECIES      => undef,
# 		     STRAND       => undef,
# 		     CHR          => undef,
# 		     START        => undef,
# 		     STOP         => undef,
# 		     SEQUENCE     => undef,
# 		     NAME         => undef,
# 		     EXTRA_INFO   => undef,
# 		     });

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
#############################   Getters   #############################
#######################################################################
sub get_species {
	return $_[0]->{SPECIES};
}
sub get_strand {
	return $_[0]->{STRAND};
}
sub get_chr {
	return $_[0]->{CHR};
}
sub get_start {
	return $_[0]->{START};
}
sub get_stop {
	return $_[0]->{STOP};
}
sub get_sequence {
	return $_[0]->{SEQUENCE};
}
sub get_name {
	return $_[0]->{NAME};
}
sub get_extra {
	return $_[0]->{EXTRA_INFO};
}
sub get_length {
	if    (defined $_[0]->{LENGTH})   {
	}
	elsif (defined $_[0]->{SEQUENCE}) {
		$_[0]->{LENGTH} = length($_[0]->get_sequence);
	}
	else {
		$_[0]->{LENGTH} = $_[0]->get_stop - $_[0]->get_start + 1;
	}
	return $_[0]->{LENGTH};
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_species {
	$_[0]->{SPECIES} = uc($_[1]) if defined $_[1];
}
sub set_strand {
	my ($self,$value) = @_;
	if (defined $value) {
		$value =~ s/^\+$/1/;
		$value =~ s/^\-$/-1/;
		$self->{STRAND} = $value;
	}
# 	else {
# 		$self->{STRAND} = 0;
# 	}
}
sub set_chr {
	my ($self,$value) = @_;
	if (defined $value) {
		$value =~ s/>*chr//;
		$self->{CHR} = $value;
	}
}
sub set_start {
	$_[0]->{START} = $_[1] if defined $_[1];
}
sub set_stop {
	$_[0]->{STOP} = $_[1] if defined $_[1];
}
sub set_sequence {
	my ($self,$value) = @_;
	if (defined $value) {
		unless ($value =~ /^[ATGCUN]*$/i) {
			$value =~ /([^ATGCUN])/i;
			warn "The nucleotide sequence provided for ".$self->get_name()." contains the following invalid characters $1 in $self\n";
		}
		$self->{SEQUENCE} = $value;
	}
}
sub set_name {
	$_[0]->{NAME} = $_[1] if defined $_[1];
}
sub set_extra {
	$_[0]->{EXTRA_INFO} = $_[1] if defined $_[1];
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub get_strand_symbol {
	if ($_[0]->get_strand == 1) {
		return '+';
	}
	elsif ($_[0]->get_strand == -1) {
		return '-';
	}
	else {
		return undef;
	}
}
sub get_5p {
	my ($self) = @_;
	if ($self->get_strand == 1) {
		return $self->get_start;
	}
	else {
		return $self->get_stop;
	}
}
sub get_3p {
	my ($self) = @_;
	if ($self->get_strand == 1) {
		return $self->get_stop;
	}
	else {
		return $self->get_start;
	}
}
sub get_id {
	return $_[0]->get_chr.":".$_[0]->get_start."-".$_[0]->get_stop.":".$_[0]->get_strand;
}
sub get_location {
	return $_[0]->get_chr.":".$_[0]->get_start."-".$_[0]->get_stop.":".$_[0]->get_strand;
}
sub to_string {
	my ($self,$method,@attributes) = @_;
	
	my $print_tag;
	if ($method eq "BED") {
		my $strand;
		if    ($self->get_strand == 1){$strand = "+";}
		elsif ($self->get_strand == -1){$strand = "-";}
		else {$strand = ".";}
		
		my $name = defined $self->get_name ? $self->get_name : ".";
		my $score = 0;
		
		$print_tag = "chr".$self->get_chr."\t".$self->get_start."\t".($self->get_stop+1)."\t".$name."\t".$score."\t".$strand;
		
	}
	$print_tag =~ s/\t+$//g;
	return $print_tag;
}
sub get_5p_5p_distance_from {
	my ($self,$from_locus) = @_;
	return ($self->get_5p - $from_locus->get_5p) * $self->get_strand;
}
sub get_5p_3p_distance_from {
	my ($self,$from_locus) = @_;
	return ($self->get_5p - $from_locus->get_3p) * $self->get_strand;
}
sub get_3p_5p_distance_from {
	my ($self,$from_locus) = @_;
	return ($self->get_3p - $from_locus->get_5p) * $self->get_strand;
}
sub get_3p_3p_distance_from {
	my ($self,$from_locus) = @_;
	return ($self->get_3p - $from_locus->get_3p) * $self->get_strand;
}
sub overlaps {
	my ($self,$loc2,$offset,$use_strand) = @_;
	
	if (!defined $offset) {$offset = 0;}
	if (!defined $use_strand) {$use_strand = 1;} 
	
	if ((($use_strand == 0) or ($self->get_strand() eq $loc2->get_strand())) and ($self->get_chr() eq $loc2->get_chr()) and (($self->get_start()-$offset) <= $loc2->get_stop()) and ($loc2->get_start() <= ($self->get_stop()+$offset))) {
		return 1; #overlap
	}
	else {
		return 0; #no overlap
	}
}

sub get_overlap_length {
	my ($self,$loc2) = @_;
	
	#will return number of nucleotides of $self that are covered by $loc2
	unless ($self->overlaps($loc2)){return 0;} #sanity check
	my $nt_overlap = $loc2->get_length;
	if ($loc2->get_start < $self->get_start){$nt_overlap -= ($self->get_start - $loc2->get_start);} #left overhang removed
	if ($loc2->get_stop > $self->get_stop){$nt_overlap -= ($loc2->get_stop - $self->get_stop);} #right overhang removed
	return $nt_overlap;
}

sub contains {
	my ($self,$loc2,$percent) = @_;
	
	if (!defined $percent) {$percent = 1;}
	my $overhang = 0;
	my $left_overhang = ($self->get_start - $loc2->get_start);
	my $right_overhang = ($loc2->get_stop - $self->get_stop);
	if ($left_overhang > 0){$overhang += $left_overhang;}
	if ($right_overhang > 0){$overhang += $right_overhang;}
# 	print $self->get_start." - ".$self->get_stop."\t".$loc2->get_start." - ".$loc2->get_stop."\t".($overhang / $loc2->get_length)."\t".$percent."\n";
	if (($overhang / $loc2->get_length) <= (1-$percent)){return 1;}
	return 0;
}

sub get_contained_locuses {
# 	$self is a locus
# 	$array is a reference to an array of locus objects
#	the sub will return an array of locus objects containing the parts (or whole) objects on the array that fall within $self
#
#	          ---------------------------------------------
#	  ---    ---              ---       ----              ------    -------
#return
#	          --              ---       ----              -                
#
	my ($self,$array) = @_;
	my @outarray;
	
	if ((defined $self->get_start) and (defined $self->get_stop)){ #sanity check!
		
		foreach my $region (@{$array})
		{
			if ($region->get_chr ne $self->get_chr){next;} #chromosome check! don't align things in diff chromosome
			if ($self->contains($region)){push @outarray, $region;} #fully contained in self
			elsif ($self->overlaps($region))
			{
				my $class = ref($region) || $region;
				my $partLocus = $class->new({
					SPECIES      => $region->get_species,
					STRAND       => $region->get_strand,
					CHR          => $region->get_chr,
					START        => (MyBio::MyMath::max( [$region->get_start, $self->get_start] ))[1],
					STOP         => (MyBio::MyMath::min( [$region->get_stop, $self->get_stop] ))[1],
					SEQUENCE     => undef, #not sure what to do with seq!!!
					EXTRA_INFO   => $region->get_extra,
				});
				push @outarray, $partLocus;
			}
			else {next;} #no overlap
		}
	}
	return \@outarray;
}

sub get_touching_locuses {
# 	$self is a locus
# 	$array is a reference to an array of locus objects
#	the sub will return an array of locus objects overlaping with $self within $offset
#
#	          ---------------------------------------------
#	  ---    ---              ---       ----              ------    -------
#return
#	         ---              ---       ----              ------                
#
	my ($self,$array,$offset) = @_;
	my @outarray;
	
	if ((defined $self->get_start) and (defined $self->get_stop)){ #sanity check!
		
		foreach my $region (@{$array})
		{
			if ($region->get_chr ne $self->get_chr){next;} #chromosome check! don't align things in diff chromosome
			if ($self->overlaps($region,$offset)){push @outarray, $region;} #overlaps with self
			else {next;} #no overlap
		}
	}
	return \@outarray;
}

1;
