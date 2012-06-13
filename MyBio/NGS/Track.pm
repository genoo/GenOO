# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::Track - Object for a collection of MyBio::NGS::Tag objects, with features

=head1 SYNOPSIS

    # Object that manages a collection of L<MyBio::NGS::Tag> objects. 

    # To initialize 
    my $track = MyBio::NGS::Track->new({
        NAME            => undef,
        SPECIES         => undef,
        DESCRIPTION     => undef,
        EXTRA_INFO      => undef,
    });


=head1 DESCRIPTION

    The primary data structure of this object is a 2D hash whose primary key is the strand 
    and its secondary key is the chromosome name. Each such pair of keys correspond to an
    array reference which stores objects of the class L<MyBio::NGS::Tag> sorted by start position.

=head1 EXAMPLES

    # Print entries in FASTA format
    $track->print_all_entries("FASTA",'STDOUT',"/data1/data/UCSC/hg19/chromosomes/");

=cut

# Let the code begin...

package MyBio::NGS::Track;
use strict;

use MyBio::MySub;
use MyBio::NGS::Tag;
use MyBio::NGS::Track::Stats;

use base qw(MyBio::LocusCollection);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	return $self;
}

#######################################################################
#############################   Setters   #############################
#######################################################################

#######################################################################
#############################   Getters   #############################
#######################################################################

#######################################################################
##########################   Stats Methods   ##########################
#######################################################################
sub init_stats {
	my ($self) = @_;
	$self->{STATS} = MyBio::NGS::Track::Stats->new({
		COLLECTION => $self
	}); 
}

sub score_sum {
	my ($self) = @_;
	return $self->stats->get_or_calculate_score_sum;
}

sub score_mean {
	my ($self) = @_;
	return $self->stats->get_or_calculate_score_mean;
}

sub score_variance {
	my ($self) = @_;
	return $self->stats->get_or_calculate_score_variance;
}

sub score_stdv {
	my ($self) = @_;
	return $self->stats->get_or_calculate_score_stdv;
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub get_all_entries_score {
	my ($self) = @_;
	
	my @out = ();
	my $iterator = $self->get_entries_iterator;
	while (my $entry = $iterator->next) {
		push @out, $entry->get_score;
	}
	return @out;
}

#######################################################################
##################   Methods that modify the object  ##################
#######################################################################
=head2 collapse
  Example    : $track->collapse
  Description: Entries with the same start and stop positions are collapsed into a single entry.
=cut
sub collapse {
	my ($self) = @_;
	
	my $entries_ref = $self->get_entries;
	my %collapsed_hash;
	foreach my $strand (keys %{$entries_ref}) {
		foreach my $chr (keys %{$$entries_ref{$strand}}) {
			if (exists $$entries_ref{$strand}{$chr}) {
				$collapsed_hash{$strand}{$chr} = [];
				my %count;
				foreach my $entry (@{$$entries_ref{$strand}{$chr}}) {
					my $start = $entry->get_start;
					my $stop = $entry->get_stop;
					$count{"$start|$stop"}++;
				}
				foreach my $pos (keys %count) {
					my ($start, $stop) = split(/\|/,$pos);
					my $entryObj = MyBio::NGS::Tag->new({
						CHR           => $chr,
						START         => $start,
						STOP          => $stop,
						STRAND        => $strand,
						NAME          => $count{$pos},
						SCORE         => $count{$pos},
					});
					push (@{$collapsed_hash{$strand}{$chr}}, $entryObj);
					
				}
			}
		}
	}
	$self->set_entries(\%collapsed_hash);
}


=head2 merge

  Arg [1]    : string $method
               A descriptor of the desired output method (MERGE, SPLITSCORE)
               MERGE: scores of overlapping or whithin a distance entries are summed
               SPLITSCORE: overlapping entries are divided into parts and the score of each part is the sum of the
                           corresponding overlapping entries
  Arg [2..]  : array @attributes
               Additional attributes for the defined output method
  Example    : merge("MERGE", 0) 
               merge("SPLITSCORE", 10)
  Description: Merges loci which overlap or are closer than a given distance with each other (entries are replaced by merged ones)
  Returntype : NULL
  Caller     : ?
  Status     : Experimental / Unstable

=cut
sub merge {
	my ($self,$method,@attributes) = @_;
	
	
	my $entries_ref = $self->get_entries;
	my %merged_hash;
	foreach my $strand (keys %{$entries_ref}) {
		foreach my $chr (keys %{$$entries_ref{$strand}}) {
			if (exists $$entries_ref{$strand}{$chr}) {
				$merged_hash{$strand}{$chr} = [];
				@{$merged_hash{$strand}{$chr}} = $self->merge_entries_in_array($$entries_ref{$strand}{$chr},$method,@attributes);
			}
		}
	}
	$self->set_entries(\%merged_hash);
}

sub merge_entries_in_array {
	my ($self,$entries_array_ref,$method,@attributes) = @_;
	my @out = ();
	my @temp = ();
	my $offset;
	
	if ($method eq "MERGE") {
		$offset = $attributes[0];
	}
	
	my $region_of_overlap;
	foreach my $entry (@$entries_array_ref) {
		if (!defined $region_of_overlap) {
			$region_of_overlap = $entry->clone(); 
			push(@temp, $entry);
		}
		elsif ($region_of_overlap->overlaps($entry,$offset)) {
			push(@temp, $entry);
			my $start = $region_of_overlap->get_start < $entry->get_start ? $region_of_overlap->get_start : $entry->get_start;
			my $stop = $region_of_overlap->get_stop > $entry->get_stop ? $region_of_overlap->get_stop : $entry->get_stop;
			$region_of_overlap->set_start($start);
			$region_of_overlap->set_stop($stop);
		}
		else {
			$region_of_overlap = $entry->clone();
			if ($#temp == 0) {
				push (@out, $temp[0]);
			}
			else {
				push(@out,$self->resolve_overlaping_entries(\@temp,$method,@attributes));
			}
			@temp = ();
			push(@temp, $entry);
		}
	}
	
	if ($#temp == 0) {
		push (@out, $temp[0]);
	}
	else {
		push(@out,$self->resolve_overlaping_entries(\@temp,$method,@attributes));
	}
	@temp = ();
	return @out;
}

sub resolve_overlaping_entries {
	my ($self,$temp,$method,@attributes) = @_;
	
	if ($method eq "MERGE") {
		return $self->merge_overlaping_entries($temp);
	}
	elsif ($method eq "SPLITSCORE") {
		return $self->splitscore_overlaping_entries($temp);
	}
}

sub merge_overlaping_entries {
	my ($self,$temp) = @_;
	
	my @entryobjects = sort {$a->get_start() <=> $b->get_start()} @{$temp};
	
	my @out = ();
	my $newentry = $entryobjects[0];
	for (my $i = 1; $i < @entryobjects; $i++) {
		if ($entryobjects[$i]->get_start() < $newentry->get_start()) {
			$newentry->set_start($entryobjects[$i]->get_start());
		}
		if ($entryobjects[$i]->get_stop() > $newentry->get_stop()) {
			$newentry->set_stop($entryobjects[$i]->get_stop());
		}
		
		if ($newentry->can("get_score") and $entryobjects[$i]->can("get_score")) {
			my $tempscore = $newentry->get_score() + $entryobjects[$i]->get_score();
			$newentry->set_score($tempscore);
			$newentry->set_name($tempscore);
		}
		else {
			$newentry->set_name("");
		}
	}
	push (@out,$newentry);
	return @out;
}

sub splitscore_overlaping_entries {
	my ($self,$temp) = @_;
	
	my @entryobjects = sort {$a->get_start() <=> $b->get_start()} @{$temp};
	
	my @out = @entryobjects;
	my $entry1;
	my $entry2;
	for (my $i=0;$i<@entryobjects-1;$i++) {
		$entry1 = $entryobjects[$i];
		$entry2 = $entryobjects[$i+1];
		
		if ($entry1->overlaps($entry2)) {
			my @temp = $self->divide_entries_by_score($entry1,$entry2);
			if ($i > 0) {
				push (@temp, @entryobjects[0..($i-1)]);
			}
			if ($i+2 <= @entryobjects-1) {
				push (@temp, @entryobjects[($i+2)..@entryobjects-1]);
			}
			@out = $self->splitscore_overlaping_entries(\@temp);
			last;
		}
	}
	return @out;
}

sub divide_entries_by_score {
	my ($self,$entryobj1,$entryobj2) = @_;
	
	my @out = ();
	
	my $chr = $entryobj1->get_chr();
	my $strand = $entryobj1->get_strand();
	my ($newobj1_start, $newobj1_stop, $newobj1_score);
	my ($newobj2_start, $newobj2_stop, $newobj2_score);
	my ($newobj3_start, $newobj3_stop, $newobj3_score);
	
	$newobj1_start = $entryobj1->get_start();
	$newobj1_stop = $entryobj2->get_start()-1;
	$newobj1_score = $entryobj1->get_score();
	
	$newobj2_start = $entryobj2->get_start();
	$newobj2_score = $entryobj1->get_score() + $entryobj2->get_score();
		
	if ($entryobj1->get_stop() > $entryobj2->get_stop()) {
		$newobj2_stop = $entryobj2->get_stop();
		$newobj3_start = $entryobj2->get_stop()+1;
		$newobj3_stop = $entryobj1->get_stop();
		$newobj3_score = $entryobj1->get_score();
	}
	else {
		$newobj2_stop = $entryobj1->get_stop();
		$newobj3_start = $entryobj1->get_stop()+1;
		$newobj3_stop = $entryobj2->get_stop();
		$newobj3_score = $entryobj2->get_score();
	}
	
	if ($newobj1_start <= $newobj1_stop) {
		my $entryObj = MyBio::NGS::Tag->new({
			CHR           => $chr,
			START         => $newobj1_start,
			STOP          => $newobj1_stop,
			STRAND        => $strand,
			NAME          => undef,
			SCORE         => $newobj1_score,
		});
		push (@out, $entryObj);
	}
	if ($newobj2_start <= $newobj2_stop) {
		my $entryObj = MyBio::NGS::Tag->new({
			CHR           => $chr,
			START         => $newobj2_start,
			STOP          => $newobj2_stop,
			STRAND        => $strand,
			NAME          => undef,
			SCORE         => $newobj2_score,
		});
		push (@out,$entryObj);
	}
	if ($newobj3_start <= $newobj3_stop) {
		my $entryObj = MyBio::NGS::Tag->new({
			CHR           => $chr,
			START         => $newobj3_start,
			STOP          => $newobj3_stop,
			STRAND        => $strand,
			NAME          => undef,
			SCORE         => $newobj3_score,
		});
		push (@out,$entryObj);
	}
	return @out;
}

#######################################################################
######################   Normalization Methods   ######################
#######################################################################
sub normalize {
	my ($self, $params) = @_;
	
	my $scaling_factor = 1;
	my $normalization_factor = $self->get_entry_score_sum;
	if (exists $params->{'SCALE'}){$scaling_factor = $params->{'SCALE'};}
	if (exists $params->{'NORMALIZATION_FACTOR'}){$normalization_factor = $params->{'NORMALIZATION_FACTOR'};}
	my $entries_ref = $self->get_entries;
	foreach my $strand (keys %{$entries_ref}) {
		foreach my $chr (keys %{$$entries_ref{$strand}}) {
			if (exists $$entries_ref{$strand}{$chr}) {
				foreach my $entry (@{$$entries_ref{$strand}{$chr}})
				{
					my $normal_score = ($entry->get_score / $normalization_factor) * $scaling_factor;
					$entry->set_score($normal_score);
				}
			}
		}
	}
}

sub get_quantile {
	my ($self, $params) = @_;
	
	my $quantile = 25;
	my $score_threshold = 0;
	if (exists $params->{'QUANTILE'}){$quantile = $params->{'QUANTILE'};}
	if (exists $params->{'THRESHOLD'}){$score_threshold = $params->{'THRESHOLD'};}
	my @scores = sort {$b <=> $a} $self->get_all_entries_score;
	my $size;
	for ($size = 0; $size < @scores; $size++)
	{
		if ($scores[$size] < $score_threshold){last;}
	}
	my $index = int($size * ($quantile/100));
	warn "idx: $index\n";
	return $scores[$index];
}

#######################################################################
##########################   Print Methods   ##########################
#######################################################################
sub output_track_line {
	my ($self, $method, @attributes) = @_;
	if ($method eq "BED")
	{
		my $trackline = "track name=".$self->get_name;
		if (defined $self->get_description){$trackline .= " description=".$self->get_description;}
		if (defined $self->get_visibility){$trackline .= " visibility=".$self->get_visibility;}
		if (defined $self->get_color){$trackline .= " color=".$self->get_color;}
		if (defined $self->get_rgb_flag){$trackline .= " itemRgb=".$self->get_rgb_flag;}
		if (defined $self->get_color_by_strand){$trackline .= " colorByStrand=".$self->get_color_by_strand;}
		if (defined $self->get_use_score){$trackline .= " useScore=".$self->get_use_score;}
		return $trackline;
	}
	elsif ($method eq "WIG")
	{
		my $extrainfo = $attributes[0]; #will be appended to name
		my $name = $self->get_name;
		$name =~ s/\"//g;		
		my $trackline = "track type=wiggle_0 name=\"$name $extrainfo\"";
		if (defined $self->get_description){$trackline .= " description=".$self->get_description;}
		if (defined $self->get_visibility){$trackline .= " visibility=".$self->get_visibility;}
		if (defined $self->get_color){$trackline .= " color=".$self->get_color;}
		$trackline .= " autoScale=off alwaysZero=on";
		return $trackline;
	}
}

sub print_track_line {
	my ($self, $method, @attributes) = @_;
	if ($method eq "BED"){
		print $self->output_track_line("BED", @attributes)."\n";
	}
	elsif ($method eq "WIG"){
		print $self->output_track_line("WIG", @attributes)."\n";
	}
}

=head2 print_all_entries

  Arg [1]    : hash reference
               A hash reference containing the parameters for the output. Important: The type of output (BED, FASTA, WIG) must be specified!
  Example    : print_all_entries({METHOD=>"BED"})
  Description: Prints all entries for the track object.
  Returntype : NULL
  Caller     : ?
  Status     : Under development

=cut
sub print_all_entries {
	my ($self, $params) = @_;
	
	unless (ref($params) eq "HASH") {
		my $class = ref($self) || $self;
		die "\n\nDon't panic - Just change the way you call method \"print_all_entries\" through $class in your calling script $0\n\n";
	}
	
	my $method = $params->{'METHOD'};
	delete $params->{'METHOD'};
	unless (defined $method) {
		my $class = ref($self) || $self;
		die "\nNo print method specified in $class\::print_all_entries";
	}
	
	if ($method eq "BED"){
		$self->print_all_entries_BED($params);
	}
	elsif ($method eq "FASTA") {
		$self->print_all_entries_FASTA($params);
	}
	elsif ($method eq "WIG") {
		$self->print_all_entries_WIG($params);
	}
	else {
		my $class = ref($self) || $self;
		die "\nUnknown print method \"$method\" specified in $class\::print_all_entries. Try (BED|WIG|FASTA)";
	}
}

=head2 print_all_entries_BED

  Arg [1]    : hash reference
               A hash reference containing the parameters for the output
               Required parameters are:
                  1/ OUTPUT: STDOUT or filename
  Example    : print_all_entries({
                  OUTPUT       =>"STDOUT"
               })      
  Description: Prints all entries for a track object in BED format.
  Returntype : NULL
  Caller     : ?
  Status     : Stable

=cut
sub print_all_entries_BED {
	my ($self, $params) = @_;
	
	my $OUT;
	if ((!exists $params->{'OUTPUT'}) or ($params->{'OUTPUT'} eq "STDOUT")) {
		open ($OUT,">&=",STDOUT);
	}
	else {
		open($OUT,">",$params->{'OUTPUT'}) or die "Cannot open file ".$params->{'OUTPUT'}.". $!";
	}
	
	my $entries_ref = $self->get_entries;
	foreach my $strand (keys %{$entries_ref}) {
		foreach my $chr (keys %{$$entries_ref{$strand}}) {
			if (exists $$entries_ref{$strand}{$chr}) {
				foreach my $entry (@{$$entries_ref{$strand}{$chr}})
				{
					print $OUT $entry->to_string("BED")."\n";
				}
			}
		}
	}
	
	return 0;
}

=head2 print_all_entries_FASTA

  Arg [1]    : hash reference
               A hash reference containing the parameters for the output.
               Required parameters are:
                  1/ OUTPUT: STDOUT or filename
                  2/ CHR_FOLDER: The folder containing the fasta files of the chromosomes
  Example    : print_all_entries({
                  OUTPUT           => "STDOUT",
                  CHR_FOLDER       => "/chromosomes/hg19/"
                  UPDATE_SEQUENCE  => "1"
               })
  Description: Prints all entries for a track object in FASTA format.
  Returntype : NULL
  Caller     : ?
  Status     : Stable

=cut
sub print_all_entries_FASTA {
	my ($self, $params) = @_;
	
	my $chr_folder = exists $params->{'CHR_FOLDER'} ? $params->{'CHR_FOLDER'} : die "The method FASTA is requested in \"print_all_entries\" but the folder with chromosome sequences is not provided";
	my $upflank = exists $params->{'UP_FLANK'} ? $params->{'UP_FLANK'} : 0;
	my $downflank = exists $params->{'DOWN_FLANK'} ? $params->{'DOWN_FLANK'} : 0;
	my $maxflank = $upflank > $downflank ? $upflank : $downflank;
	
	my $OUT;
	if ((!exists $params->{'OUTPUT'}) or ($params->{'OUTPUT'} eq "STDOUT")) {
		open ($OUT,">&=",STDOUT);
	}
	else {
		open($OUT,">",$params->{'OUTPUT'});
	}
	
	my $entries_ref = $self->get_entries;
	my %available_chrs;
	foreach my $strand (keys %{$entries_ref}) {
		foreach my $chr (keys %{$$entries_ref{$strand}}) {
			$available_chrs{$chr} = 1;
		}
	}
	foreach my $chr (keys %available_chrs) {
		my $chr_file = $chr_folder."/chr$chr.fa";
		unless (-e $chr_file) {
			warn "Skipping chromosome. File $chr_file does not exist";
			next;
		}
		my $chr_seq = join('',map{'N'} (1..$maxflank)).MyBio::MySub::read_fasta($chr_file,"chr$chr").join('',map{'N'} (1..$maxflank));
		
		foreach my $strand (keys %{$entries_ref}) {
			if (exists $$entries_ref{$strand}{$chr}) {
				my $entries_array_ref = $$entries_ref{$strand}{$chr};
				# Unbelievable as it may be, although the if else statement is not needed, having it here speeds up the script by approximately 8 times
				if (defined $maxflank) {
					foreach my $entry (@$entries_array_ref) {
						my $entry_seq;
						if ($strand == 1) {
							$entry_seq = substr($chr_seq,$entry->get_start()+$maxflank-$upflank,$entry->get_length+$upflank+$downflank);
						}
						else {
							$entry_seq = substr($chr_seq,$entry->get_start()+$maxflank-$downflank,$entry->get_length+$upflank+$downflank);
							$entry_seq = reverse($entry_seq);
							if ($entry_seq =~ /U/i) {
								$entry_seq =~ tr/ATGCUatgcu/UACGAuacga/;
							}
							else {
								$entry_seq =~ tr/ATGCUatgcu/TACGAtacga/;
							}
						}
						if (exists $params->{'UPDATE_SEQUENCE'}){$entry->set_sequence($entry_seq);}
						my $header = $entry->to_string("BED");
						$header =~ s/\t/|/g;
						print $OUT ">$header\n$entry_seq\n";
					}
				}
				else {
					foreach my $entry (@$entries_array_ref) {
						my $entry_seq = substr($chr_seq,$entry->get_start,$entry->get_length);
						if ($strand == -1) {
							$entry_seq = reverse($entry_seq);
							if ($entry_seq =~ /U/i) {
								$entry_seq =~ tr/ATGCUatgcu/UACGAuacga/;
							}
							else {
								$entry_seq =~ tr/ATGCUatgcu/TACGAtacga/;
							}
						}
						if (exists $params->{'UPDATE_SEQUENCE'}){$entry->set_sequence($entry_seq);}
						my $header = $entry->to_string("BED");
						$header =~ s/\t/|/g;
						print $OUT ">$header\n$entry_seq\n";
					}
				}
			}
		}
	}
	return 0;
}

=head2 print_all_entries_WIG

  Arg [1]    : hash reference
               A hash reference containing the parameters for the output
               Required parameters are:
                  1/ OUTPUT: STDOUT or filename
                  2/ WINDOW: The size in nucleotides of each bin in the WIG filehandle
                  3/ STEP: The distance in nucleotides between adjacent bins in the WIG file
                  4/ SCORE_TYPE: It take the values "RPKM", "SUM" or "SIMPLE". "SUM" adds the scores of all entries in the window. "RPKM" divides this by the length of the window in kb. "SIMPLE" counts entries in the window
  Example    : print_all_entries({
                  OUTPUT       => "STDOUT",
                  WINDOW       => 1000,
                  STEP         => 100,
                  SCORE_TYPE   => "RPKM"
               })
  Description: Prints all entries for a track object in WIG format.
  Returntype : NULL
  Caller     : ?
  Status     : Stable

=cut
sub print_all_entries_WIG {
	my ($self, $params) = @_;
	
	my $OUT;
	if ((!exists $params->{'OUTPUT'}) or ($params->{'OUTPUT'} eq "STDOUT")) {
		open ($OUT,">&=",STDOUT);
	}
	else {
		open($OUT,">",$params->{'OUTPUT'});
	}
	
	my $window = defined $params->{'WINDOW'} ? $params->{'WINDOW'} : 1000;
	my $step = defined $params->{'STEP'} ? $params->{'STEP'} : 100;
	my $scoring_type = defined $params->{'SCORE_TYPE'} ? $params->{'SCORE_TYPE'} : "RPKM";
	my $entries_ref = $self->get_entries;
	$self->sort_entries();
	
	foreach my $strand (keys %{$entries_ref}) {
		$self->print_track_line("WIG", "strand($strand)");
		foreach my $chr (keys %{$$entries_ref{$strand}}) {
			if (exists $$entries_ref{$strand}{$chr}) {
				my $lastend = (sort {$a->get_stop() <=> $b->get_stop()} @{$$entries_ref{$strand}{$chr}})[-1]->get_stop();
				my $last_positive_entry_index = 0;
				print "variableStep chrom=chr$chr span=$step\n";
				for (my $start = $window; $start < $lastend; $start += $step)
				{
					my $wiglocus = MyBio::Locus->new({
						STRAND       => $strand,
						CHR          => $chr,
						START        => $start,
						STOP         => ($start+$window-1)
					});
					my $score = 0;
					for (my $i = $last_positive_entry_index; $i< $#{$$entries_ref{$strand}{$chr}}; $i++)
					{
						my $entry = ${$$entries_ref{$strand}{$chr}}[$i];
						
						if ($wiglocus->overlaps($entry))
						{
							if ($scoring_type eq "SUM"){$score += $entry->get_score;}
							elsif ($scoring_type eq "RPKM"){$score += (1000 * $entry->get_score) / $wiglocus->get_length;}
							elsif ($scoring_type eq "SIMPLE"){$score++;}
							$last_positive_entry_index = $i;
						}
						elsif ($wiglocus->get_stop < $entry->get_start)
						{
							last;
						}
					}
					if ($score > 0){print $wiglocus->get_start."\t".$score."\n";}
				}
			}
		}
	}
	return 0;
}

1;
