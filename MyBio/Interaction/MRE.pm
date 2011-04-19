package MyBio::Interaction::MRE;

# Corresponds to a miRNA binding site on a gene transcript.
# The class is designed to be used either directly or through the classes Interaction::MirnaUTR5, Interaction::MirnaCDS, Interaction::MirnaUTR3 which are its descendants. 

use strict;
use Scalar::Util qw/weaken/;

use MyBio::Transcript;
use MyBio::Mirna::Mimat;

use base qw(MyBio::_Initializable);

# HOW TO INITIALIZE THIS OBJECT
# $mreObj->_init({
# 		     MIRNA_TRANSCRIPT_INTERACTION => undef, # Interaction::MirnaTranscript
# 		     WHERE                        => undef,
# 		     CATEG                        => undef,
# 		     MRE_UTR3_START               => undef,
# 		     MRE_UTR3_STOP                => undef,
# 		     DRIVER_UTR3_START            => undef,
# 		     DRIVER_UTR3_STOP             => undef,
# 		     DIF1                         => undef,
# 		     DIF2                         => undef,
# 		     FIRST_BINDING                => undef,
# 		     BINDING_VECTOR               => undef,
# 		     RNAHYBRID                    => undef,
# 		     ENERGY_PERCENTAGE            => undef,
# 		     CONSERVATION                 => undef,
# 		     MRE_SCORE                    => undef,
# 		     EXTRA_INFO                   => undef,
# 		     });

sub _init {
	my ($self,$data) = @_;
	my $class = ref($self) || $self;
	
	my $mirnaTranscriptInteraction = $$data{MIRNA_TRANSCRIPT_INTERACTION};
	unless (defined $mirnaTranscriptInteraction) {
		die "An MRE object cannot be created unless a MirnaTranscript interaction has been previously defined\n";
	}
	my $where = $$data{WHERE};
	unless (defined $where) {
		warn "An MRE object is created missing the \"WHERE\" attribute. This may create serious inconsistencies in the class $class. Procceed with caution or otherwise....\n";
	}
	
	$self->{MIRNA_TRANSCRIPT_INTERACTION} = $mirnaTranscriptInteraction; # Interaction::MirnaTranscript
	weaken($self->{MIRNA_TRANSCRIPT_INTERACTION}); # the line above creates a circular reference so it needs to be weakened to avoid memory leaks
	$self->{WHERE}                        = $where;
	$self->{CATEG}                        = $$data{CATEG};
	$self->{POS_ON_REGION}                = $$data{POS_ON_REGION};
	$self->{DIF1}                         = $$data{DIF1};
	$self->{DIF2}                         = $$data{DIF2};
	$self->{FIRST_BINDING}                = $$data{FIRST_BINDING};
	$self->{BINDING_VECTOR}               = $$data{BINDING_VECTOR};
	$self->{RNAHYBRID}                    = $$data{RNAHYBRID};
	$self->{ENERGY_PERCENTAGE}            = $$data{ENERGY_PERCENTAGE};
	$self->{CONSERVATION}                 = $$data{CONSERVATION};
	$self->{MRE_SCORE}                    = $$data{MRE_SCORE};
	$self->{EXTRA_INFO}                   = $$data{EXTRA_INFO};
	$self->{RELATIVE_CONS}                = $$data{RELATIVE_CONS};
	$self->{DRIVER_BINDING_COUNT}         = $$data{DRIVER_BINDING_COUNT};
	$self->{FLANKING_AU_CONTENT}          = $$data{FLANKING_AU_CONTENT};
	
	$mirnaTranscriptInteraction->push_mre($self);
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_mirnaTranscriptInteraction {return $_[0]->{MIRNA_TRANSCRIPT_INTERACTION};}
sub get_where            {return $_[0]->{WHERE};}
sub get_mirna            {return $_[0]->{MIRNA_TRANSCRIPT_INTERACTION}->get_mirna();}
sub get_category         {return $_[0]->{CATEG};}
sub get_position         {return $_[0]->{POS_ON_REGION};}
sub get_dif1             {return $_[0]->{DIF1};}
sub get_dif2             {return $_[0]->{DIF2};}
sub get_binding_vector   {return $_[0]->{BINDING_VECTOR};}
sub get_rnahybrid        {return $_[0]->{RNAHYBRID};}
sub get_energy_percentage{return $_[0]->{ENERGY_PERCENTAGE};}
sub get_mre_score        {return $_[0]->{MRE_SCORE};}
sub get_first_binding_nt {return $_[0]->{FIRST_BINDING};}
sub get_conservation     {return $_[0]->{CONSERVATION};}
sub get_extra            {return $_[0]->{EXTRA_INFO};}

sub get_region {
	my ($self) = @_;
	
	my $where = $self->{WHERE};
	
	if ($where eq 'CDS') {
		$self->{REGION} = $self->get_mirnaTranscriptInteraction->get_transcript->get_cds;
	}
	elsif ($where eq 'UTR3') {
		$self->{REGION} = $self->get_mirnaTranscriptInteraction->get_transcript->get_utr3;
	}
	elsif ($where eq 'UTR5') {
		$self->{REGION} = $self->get_mirnaTranscriptInteraction->get_transcript->get_utr5;
	}
	else {
		die "Unknown region ($where) for the MRE in class ".ref($self)."\n";
	}
	
	return $self->{REGION};
}
sub get_mre_start {
	my ($self) = @_;
	return $self->{POS_ON_REGION} - 28;
}
sub get_mre_stop {
	my ($self) = @_;
	return $self->{POS_ON_REGION};
}
sub get_driver_start {
	my ($self) = @_;
	return $self->{POS_ON_REGION} - 8;
}
sub get_driver_stop {
	my ($self) = @_;
	return $self->{POS_ON_REGION};
}
sub get_mre_chr_start { 
	my ($self) = @_;
	unless (defined $self->{MRE_CHR_START}) {
		($self->{MRE_CHR_START},$self->{MRE_CHR_STOP}) = $self->_find_genomic_location($self->get_mre_start(),$self->get_mre_stop());
	}
	return $self->{MRE_CHR_START};
}
sub get_mre_chr_stop {
	my ($self) = @_;
	unless (defined $self->{MRE_CHR_STOP}) {
		($self->{MRE_CHR_START},$self->{MRE_CHR_STOP}) = $self->_find_genomic_location($self->get_mre_start(),$self->get_mre_stop());
	}
	return $self->{MRE_CHR_STOP};
}
sub get_driver_chr_start {
	my ($self) = @_;
	unless (defined $self->{DRIVER_CHR_START}) {
		($self->{DRIVER_CHR_START},$self->{DRIVER_CHR_STOP}) = $self->_find_genomic_location($self->get_driver_start(),$self->get_driver_stop());
	}
	return $self->{DRIVER_CHR_START};
}
sub get_driver_chr_stop {
	my ($self) = @_;
	unless (defined $self->{DRIVER_CHR_STOP}) {
		($self->{DRIVER_CHR_START},$self->{DRIVER_CHR_STOP}) = $self->_find_genomic_location($self->get_driver_start(),$self->get_driver_stop());
	}
	return $self->{DRIVER_CHR_STOP};
}
sub get_chr_start_inArray {
	my ($self) = @_;
	return split(/\D/,$self->get_mre_chr_start());
}
sub get_chr_stop_inArray  {
	my ($self) = @_;
	return split(/\D/,$self->get_mre_chr_stop());
}
sub get_category_readable {
	my ($self) = @_;
	return $self->_translate_category_num();
}
sub get_energy {
	my ($self) = @_;
	unless (defined $self->{ENERGY}) {
		$self->_parse_rnahybrid();
	}
	return $self->{ENERGY};
}
sub get_graphic {
	my ($self) = @_;
	unless (defined $self->{GRAPHIC}) {
		$self->_parse_rnahybrid();
	}
	return $self->{GRAPHIC};
}
sub get_driver_binding_count {
	my ($self) = @_;
	unless (defined $self->{DRIVER_BINDING_COUNT}) {
		$self->{DRIVER_BINDING_COUNT} = $self->_count_num_of_driver_bindings();
	}
	return $self->{DRIVER_BINDING_COUNT};
}
sub get_flanking_AU_content {
	my ($self) = @_;
	unless (defined $self->{FLANKING_AU_CONTENT}) {
		$self->{FLANKING_AU_CONTENT} = $self->_calculate_flanking_AU_content();
	}
	return $self->{FLANKING_AU_CONTENT};
}
sub get_category_strength {
	my ($self) = @_;
	return $self->_category_strength();
}
sub get_new_category {
	my ($self) = @_;
	unless (defined $self->{NEW_BINDING_CATEGORY}) {
		$self->{NEW_BINDING_CATEGORY} = $self->_find_new_category();
	}
	return $self->{NEW_BINDING_CATEGORY};
}
sub get_distance_to_closest_end {
	my ($self) = @_;
	unless (defined $self->{DISTANCE_TO_CLOSEST_END}) {
		$self->{DISTANCE_TO_CLOSEST_END} = $self->_calculate_distance_to_closest_end();
	}
	return $self->{DISTANCE_TO_CLOSEST_END};
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_chr_start { $_[0]->{MRE_CHR_START}=$_[1] if defined $_[1];}
sub set_chr_stop  { $_[0]->{MRE_CHR_STOP}=$_[1] if defined $_[1];}
sub set_mre_score { $_[0]->{MRE_SCORE} = $_[1] if defined $_[1];}
sub set_extra     { $_[0]->{EXTRA_INFO} = $_[1] if defined $_[1];}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub _find_genomic_location {
	my ($self,$start,$stop) = @_;
	
	my @starts = @{$self->get_region->get_splice_starts()};
	my @stops  = @{$self->get_region->get_splice_stops()};
	
	if ($self->get_mirnaTranscriptInteraction->get_transcript->get_strand() == -1) {
		my $temp_start = $start;
		my $temp_stop  = $stop;
		$start = $self->get_region->get_length()-$temp_stop-1;
		$stop  = $self->get_region->get_length()-$temp_start-1;
	}
	
	my @real_target_starts;
	my @real_target_stops;
	my $exon_cumulative=0;
	my $found_start=0;
	my $found_start_block=0;
	for (my $i=0; $i<@starts; $i++)  {
		my $exon_size = $stops[$i]-$starts[$i]+1;
		if (($stops[$i] eq '') or ($starts[$i] eq '')) {
			print STDERR "@starts\n@stops\n".$self->get_mirnaTranscriptInteraction->get_transcript->get_enstid()."\n";
		}
		#print "splice start: $starts[$i]\tsplice stop: $stops[$i]\texon size: $exon_size\tcumulative: $exon_cumulative\tstart: $start\tstop: $stop\tfound:$found_start\n";
		#find the start posisiton if it has not already been found
		if ( (($start-($exon_cumulative+$exon_size))<=0) && ($found_start==0) ) {
			$found_start=1;
			$found_start_block=$i;
			push @real_target_starts,($starts[$i]+($start-$exon_cumulative));
			#if the stop position lies in the same block as the start position
			if ( (($stop-($exon_cumulative+$exon_size))<=0) && ($found_start_block==$i) ) {
				push @real_target_stops,($starts[$i]+($stop-$exon_cumulative));
				last;
			}
			else {
				push @real_target_stops,$stops[$i];
			}
		}
		elsif ($found_start) {
			#if the stop position lies on a different block than the start position
			if ( (($stop-($exon_cumulative+$exon_size))<=0) && ($found_start_block!=$i) ) {
				push @real_target_starts,$starts[$i];
				push @real_target_stops,($starts[$i]+($stop-$exon_cumulative));
				last;
			}
			#else if the stop position has not been found yet
			else {
				push @real_target_starts,$starts[$i];
				push @real_target_stops,$stops[$i];
			}
		}
		$exon_cumulative = $exon_cumulative + $exon_size;
	}
	return (join(';',@real_target_starts),join(';',@real_target_stops));
}

sub _translate_category_num {
	my ($self) = @_;
	my $categ_num = $self->get_category();
	my $category;
	
	#TO speed up search I have re-arranged the category checks
	if    ($categ_num==16)	{$category="4mer";}
	elsif ($categ_num==15)	{$category="5mer";}
	elsif ($categ_num==14)	{$category="6mer";}
	elsif ($categ_num==13)	{$category="6mer";}
	
	elsif ($categ_num==6)	{$category="7mer";}
	elsif ($categ_num==5)	{$category="7mer";}
	elsif ($categ_num==4)	{$category="8mer";}
	elsif ($categ_num==3)	{$category="8mer";}
	elsif ($categ_num==2)	{$category="9mer";}
	elsif ($categ_num==1)	{$category="9mer";}
	
	elsif ($categ_num==7)	{$category="9mer+wobble";}
	elsif ($categ_num==8)	{$category="8mer+wobble";}
	elsif ($categ_num==9)	{$category="8mer+target bulge";}
	elsif ($categ_num==10)	{$category="8mer+miRNA bulge";}
	elsif ($categ_num==11)	{$category="8mer+mismatch";}
	elsif ($categ_num==12)	{$category="7mer+wobble";}
	
	unless ($category) { die "Fatal Error!!!\nUnrecognised category number $categ_num.\n"; }
	
	return $category;
}

sub _category_strength {
	my ($self) = @_;
	my @strength = (0,9,9,8,8,7,7,8,7,6,6,6,6,6,6,5,4);
	return $strength[$self->get_category()];
}

sub _count_num_of_driver_bindings {
	my ($self) = @_;
	
	my $bindingVector = $self->get_binding_vector();
	my $driverBindingVector = substr(reverse($bindingVector),0,9);
	my $bindingCount = 0;
	
	$bindingCount++ while ($driverBindingVector =~ /1/g);
	
	return $bindingCount;
}

sub _parse_rnahybrid{
	my ($self) = @_;
	
	my $RNA_hybrid=$self->{RNAHYBRID};
	my @split_RNA_hybrid = split(/\:/,$RNA_hybrid);
	
	$self->{ENERGY}  = $split_RNA_hybrid[4];
	$self->{GRAPHIC} = "Target 5' ".$split_RNA_hybrid[7]." 3'\n          ".$split_RNA_hybrid[8]."\n          ".$split_RNA_hybrid[9]."\nmiRNA  3' ".$split_RNA_hybrid[10]." 5'";
}

sub _calculate_flanking_AU_content {
	my ($self) = @_;
	
	my @categoryAUWeight = (0,0.50,0.50,0.50,0.50,0.42,0.42,0.50,0.42,0.241,0.241,0.241,0.241,0.241,0.241,0.241,0.241);
	
	my $sequence = $self->get_region->get_sequence();
	my $seqLength = $self->get_region->get_length();
	my $normalizationConst = 0;
	
	# we want the flanking sequence of the 8mer          
	my $rightBorder = $self->get_driver_stop()+1;
	my $leftBorder = $self->get_driver_start();

	my $pp = 1;
	my $rnau = 0;
	for (my $p=$rightBorder;$p<$rightBorder+10;$p++) {
		if ($p<$seqLength) {
			my $c = substr($sequence,$p,1);
			if (($c eq 'A') || ($c eq 'T') || ($c eq 'U')) {
				$rnau += 1 / $pp;
			}
			$normalizationConst += 1/$pp;
			$pp++;
		}
		else {
			last;
		}
	}

	$pp = 1;
	my $lnau = 0;
	for (my $p=$leftBorder;$p>$leftBorder-10;$p--) {
		if ($p>0) {
			my $c = substr($sequence,$p,1);
			if (($c eq 'A') || ($c eq 'T') || ($c eq 'U')) {
				$lnau += 1 / $pp;
			}
			$normalizationConst += 1/$pp;
			$pp++;
		}
		else {
			last;
		}
	}
	return (($rnau + $lnau)*$categoryAUWeight[$self->get_category()])/$normalizationConst;
}

sub _find_new_category {
	my ($self) = @_;
	
	my $maxCategoryNum = 16;
	
	my $categoryNum = $self->get_category();
	my $firstBindingNt = $self->get_first_binding_nt();
	my $sequence = $self->get_region->get_sequence();
	my $isFirstNtA = 0;
	
	if (substr($sequence,$self->get_driver_stop(),1) eq 'A') {
		$isFirstNtA = 1;
	}
	
	for (my $i=0;$i<$maxCategoryNum;$i++) {
		if ($i == $categoryNum-1) {
			# if the first nucleotide binds AND it is not an A
			if (($firstBindingNt == 0) && ($isFirstNtA == 0)){
				return $categoryNum;
			}
			# if the first nucleotide does not bind AND it is an A
			elsif (($firstBindingNt != 0) && ($isFirstNtA == 1)){
				return ($categoryNum + $maxCategoryNum);
			}
			# if the first nucleotide binds AND it is an A
			elsif (($firstBindingNt == 0) && ($isFirstNtA == 1)){
				return ($categoryNum + 2*$maxCategoryNum);
			}
			# if the first nucleotide does not bind AND it is not an A
			elsif (($firstBindingNt != 0) && ($isFirstNtA == 0)){
				return ($categoryNum + 3*$maxCategoryNum);
			}
		}
	}
}

sub _calculate_distance_to_closest_end {
# Calculate the MRE distance from the closest region end. If the closest distance is higher than 1500 then set a limit to 1500.
	my ($self) = @_;
	
	my $distance_to_closest_end;
	my $distance_from_start = $self->get_position();
	my $distance_from_stop = $self->get_region->get_length() - $self->get_position();
	
	if ($distance_from_start <= $distance_from_stop) {
		$distance_to_closest_end = $distance_from_start;
	}
	else {
		$distance_to_closest_end = $distance_from_stop;
	}
	if ($distance_to_closest_end > 1500) {
		$distance_to_closest_end = 1500;
	}
	
	return $distance_to_closest_end;
}
1;