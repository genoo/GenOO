# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::Track - Object for a collection of MyBio::Locus objects, with features

=head1 SYNOPSIS

    # Object that manages a collection of L<MyBio::Locus> objects. 
    # It simulates tracks used in UCSC genome browser

    # To initialize 
    my $track = MyBio::NGS::Track->new({
        NAME            => undef,
        SPECIES         => undef,
        DESCRIPTION     => undef,
        VISIBILITY      => undef,
        COLOR           => undef,
        RGB_FLAG        => undef,
        COLOR_BY_STRAND => undef,
        USE_SCORE       => undef,
        BROWSER         => undef,
        TAGS            => undef,
        FILE            => undef,
        FILETYPE        => undef,
        EXTRA_INFO      => undef,
       	TAG_SCORE_MEAN  => undef,
	TAG_COUNT       => undef,
	TAG_SCORE_SUM   => undef,
	TAG_SCORE_VARIANCE => undef,
    });


=head1 DESCRIPTION

    The primary data structure of this object is a 2D hash whose primary key is the strand 
    and its secondary key is the chromosome name. Each such pair of keys correspond to an
    array reference which stores objects of the class L<MyBio::Locus> sorted by start position.

=head1 EXAMPLES

    # Read tracks from a file in BED format
    my %tracks = MyBio::NGS::Track->read_tracks("BED",$filename);
    
    # Parse the above read hash and print tags for each track in FASTA format
    foreach my $track (values %tracks) {
        $track->print_all_tags("FASTA",'STDOUT',"/data1/data/UCSC/hg19/chromosomes/");
    }

=head1 AUTHOR - Panagiotis Alexiou, Manolis Maragkakis

Email pan.alexiou@fleming.gr, maragkakis@fleming.gr

=cut

# Let the code begin...

package MyBio::NGS::Track;
use strict;
use FileHandle;
use MyBio::NGS::Tag;
use MyBio::MySub;

use base qw(MyBio::_Initializable);

sub _init {
	
	my ($self,$data) = @_;
	
	$self->set_name($$data{NAME});
	$self->set_species($$data{SPECIES});
	$self->set_description($$data{DESCRIPTION});
	$self->set_visibility($$data{VISIBILITY});
	$self->set_color($$data{COLOR});
	$self->set_rgb_flag($$data{RGB_FLAG});
	$self->set_color_by_strand($$data{COLOR_BY_STRAND});
	$self->set_use_score($$data{USE_SCORE});
	$self->set_browser($$data{BROWSER});
	$self->set_tags($$data{TAGS});
	$self->set_file($$data{FILE});
	$self->set_filetype($$data{FILETYPE});
	$self->set_extra($$data{EXTRA_INFO});
	#statistics
	$self->set_tag_score_mean($$data{TAG_SCORE_MEAN});
	$self->set_tag_count($$data{TAG_COUNT});
	$self->set_tag_score_sum($$data{TAG_SCORE_SUM});
	$self->set_tag_score_variance($$data{TAG_SCORE_VARIANCE});
	
	my $class = ref($self) || $self;
	$self->set_id($class->_increase_track_counter);
	$class->_add_to_all($self);
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_name {
	return $_[0]->{NAME};
}
sub get_species {
	return $_[0]->{SPECIES};
}
sub get_description {
	return $_[0]->{DESCRIPTION};
}
sub get_visibility {
	return $_[0]->{VISIBILITY};
}
sub get_color {
	return $_[0]->{COLOR};
}
sub get_rgb_flag {
	return $_[0]->{RGB_FLAG};
}
sub get_color_by_strand {
	return $_[0]->{COLOR_BY_STRAND};
}
sub get_use_score {
	return $_[0]->{USE_SCORE};
}
sub get_browser {
	return $_[0]->{BROWSER};
}
sub get_tags {
	return $_[0]->{TAGS};
}
sub get_all_tags {
	my @out = ();
	foreach my $strand (keys %{$_[0]->get_tags})
	{
		foreach my $chr (keys %{$_[0]->get_tags->{$strand}})
		{
			push @out, @{$_[0]->get_tags->{$strand}->{$chr}};
		}
	}
	return @out;
}
sub get_all_tags_score {
	my @out = ();
	foreach my $strand (keys %{$_[0]->get_tags})
	{
		foreach my $chr (keys %{$_[0]->get_tags->{$strand}})
		{
			foreach my $tag (@{$_[0]->get_tags->{$strand}->{$chr}})
			{
				push @out, $tag->get_score();
			}
		}
	}
	return @out;
}
sub get_file {
	return $_[0]->{FILE};
}
sub get_filetype {
	return $_[0]->{FILETYPE};
}
sub get_extra {
	return $_[0]->{EXTRA_INFO} ;
}
sub get_id {
	return $_[0]->{ID} ;
}
sub get_tag_score_mean {
	if (!defined $_[0]->{TAG_SCORE_MEAN}){
		$_[0]->calculate_tag_score_mean();
	}
	return $_[0]->{TAG_SCORE_MEAN};
}
sub get_tag_count {
	if (!defined $_[0]->{TAG_COUNT}){
		$_[0]->calculate_tag_count();
	}
	return $_[0]->{TAG_COUNT};
}
sub get_tag_score_sum {
	if (!defined $_[0]->{TAG_SCORE_SUM}){
		$_[0]->calculate_tag_score_sum();
	}
	return $_[0]->{TAG_SCORE_SUM};
}
sub get_tag_score_variance {
	if (!defined $_[0]->{TAG_SCORE_VARIANCE}){
		$_[0]->calculate_tag_score_variance();
	}
	return $_[0]->{TAG_SCORE_VARIANCE};
}
sub get_tag_score_stdev {
	if (!defined $_[0]->{TAG_SCORE_VARIANCE}){
		$_[0]->calculate_tag_score_variance();
	}
	return sqrt($_[0]->{TAG_SCORE_VARIANCE});
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_name {
	$_[0]->{NAME}=$_[1] if defined $_[1];
}
sub set_species {
	$_[0]->{SPECIES}=$_[1] if defined $_[1];
}
sub set_description {
	$_[0]->{DESCRIPTION}=$_[1] if defined $_[1];
}
sub set_visibility {
	$_[0]->{VISIBILITY}=$_[1] if defined $_[1];
}
sub set_color {
	$_[0]->{COLOR}=$_[1] if defined $_[1];
}
sub set_rgb_flag {
	$_[0]->{RGB_FLAG}=$_[1] if defined $_[1];
}
sub set_color_by_strand {
	$_[0]->{COLOR_BY_STRAND}=$_[1] if defined $_[1];
}
sub set_use_score {
	$_[0]->{USE_SCORE}=$_[1] if defined $_[1];
}
sub set_browser {
	$_[0]->{BROWSER} = defined $_[1] ? $_[1] : [];
}
sub set_tags {
	$_[0]->{TAGS} = defined $_[1] ? $_[1] : {};
}
sub set_file {
	$_[0]->{FILE} = defined $_[1] ? $_[1] : undef;
}
sub set_filetype {
	$_[0]->{FILETYPE} = defined $_[1] ? $_[1] : undef;
}
sub set_extra {
	$_[0]->{EXTRA_INFO} = $_[1] if defined $_[1];
}
sub set_id {
	$_[0]->{ID} = $_[1] if defined $_[1];
}
sub set_tag_score_mean {
	$_[0]->{TAG_SCORE_MEAN} = $_[1] if defined $_[1];
}
sub set_tag_score_sum {
	$_[0]->{TAG_SCORE_SUM} = $_[1] if defined $_[1];
}
sub set_tag_count {
	$_[0]->{TAG_COUNT} = $_[1] if defined $_[1];
}
sub set_tag_score_variance {
	$_[0]->{TAG_SCORE_VARIANCE} = $_[1] if defined $_[1];
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub get_longest_tag_length {
	my ($self) = @_;
	
	my $longest_tag = 0;
	my $tags_ref = $self->get_tags;
	foreach my $strand (keys %{$tags_ref}) {
		foreach my $chr (keys %{$tags_ref->{$strand}}) {
			if (exists $tags_ref->{$strand}->{$chr}) {
				foreach my $tag (@{$tags_ref->{$strand}->{$chr}})
				{
					if ($tag->get_length() > $longest_tag) {
						$longest_tag = $tag->get_length();
					}
				}
			}
		}
	}
	return $longest_tag;
}

sub delete_from_all {
	my ($self) = @_;
	my $class = ref($self) || $self;
	$class->_delete_from_all($self);
}

sub add_tag {
	my ($self,$tag) = @_;
	push @{$self->get_tags->{$tag->get_strand}->{$tag->get_chr}},$tag;
}

sub push_to_browser {
	my ($self,@values) = @_;
	push @{$self->get_browser},@values;
}

sub normalize {
	my ($self, $params) = @_;
	my $scaling_factor = 1;
	my $normalization_factor = $self->get_tag_score_sum;
	if (exists $params->{'SCALE'}){$scaling_factor = $params->{'SCALE'};}
	if (exists $params->{'NORMALIZATION_FACTOR'}){$normalization_factor = $params->{'NORMALIZATION_FACTOR'};}
	my $tags_ref = $self->get_tags;
	foreach my $strand (keys %{$tags_ref}) {
		foreach my $chr (keys %{$$tags_ref{$strand}}) {
			if (exists $$tags_ref{$strand}{$chr}) {
				foreach my $tag (@{$$tags_ref{$strand}{$chr}})
				{
					my $normal_score = ($tag->get_score / $normalization_factor) * $scaling_factor;
					$tag->set_score($normal_score);
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
	my @scores = sort {$b <=> $a} $self->get_all_tags_score;
	my $size;
	for ($size = 0; $size < @scores; $size++)
	{
		if ($scores[$size] < $score_threshold){last;}
	}
	my $index = int($size * ($quantile/100));
	warn "idx: $index\n";
	return $scores[$index];
}

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

=head2 print_all_tags

  Arg [1]    : hash reference
               A hash reference containing the parameters for the output. Important: The type of output (BED, FASTA, WIG) must be specified!
  Example    : print_all_tags({METHOD=>"BED"})
  Description: Prints all tags for the track object.
  Returntype : NULL
  Caller     : ?
  Status     : Under development

=cut
sub print_all_tags {
	my ($self, $params) = @_;
	
	unless (ref($params) eq "HASH") {
		my $class = ref($self) || $self;
		die "\n\nDon't panic - Just change the way you call method \"print_all_tags\" through $class in your calling script $0\n\n";
	}
	
	my $method = $params->{'METHOD'};
	delete $params->{'METHOD'};
	unless (defined $method) {
		my $class = ref($self) || $self;
		die "\nNo print method specified in $class\::print_all_tags";
	}
	
	if ($method eq "BED"){
		$self->print_all_tags_BED($params);
	}
	elsif ($method eq "FASTA") {
		$self->print_all_tags_FASTA($params);
	}
	elsif ($method eq "WIG") {
		$self->print_all_tags_WIG($params);
	}
	else {
		my $class = ref($self) || $self;
		die "\nUnknown print method \"$method\" specified in $class\::print_all_tags. Try (BED|WIG|FASTA)";
	}
}

=head2 print_all_tags_BED

  Arg [1]    : hash reference
               A hash reference containing the parameters for the output
               Required parameters are:
                  1/ OUTPUT: STDOUT or filename
  Example    : print_all_tags({
                  OUTPUT       =>"STDOUT"
               })      
  Description: Prints all tags for a track object in BED format.
  Returntype : NULL
  Caller     : ?
  Status     : Stable

=cut
sub print_all_tags_BED {
	my ($self, $params) = @_;
	
	my $OUT;
	if ((!exists $params->{'OUTPUT'}) or ($params->{'OUTPUT'} eq "STDOUT")) {
		open ($OUT,">&=",STDOUT);
	}
	else {
		open($OUT,">",$params->{'OUTPUT'}) or die "Cannot open file ".$params->{'OUTPUT'}.". $!";
	}
	
	my $tags_ref = $self->get_tags;
	foreach my $strand (keys %{$tags_ref}) {
		foreach my $chr (keys %{$$tags_ref{$strand}}) {
			if (exists $$tags_ref{$strand}{$chr}) {
				foreach my $tag (@{$$tags_ref{$strand}{$chr}})
				{
					print $OUT $tag->to_string("BED")."\n";
				}
			}
		}
	}
	
	return 0;
}

=head2 print_all_tags_FASTA

  Arg [1]    : hash reference
               A hash reference containing the parameters for the output.
               Required parameters are:
                  1/ OUTPUT: STDOUT or filename
                  2/ CHR_FOLDER: The folder containing the fasta files of the chromosomes
  Example    : print_all_tags({
                  OUTPUT           => "STDOUT",
                  CHR_FOLDER       => "/chromosomes/hg19/"
                  UPDATE_SEQUENCE  => "1"
               })
  Description: Prints all tags for a track object in FASTA format.
  Returntype : NULL
  Caller     : ?
  Status     : Stable

=cut
sub print_all_tags_FASTA {
	my ($self, $params) = @_;
	
	my $chr_folder = exists $params->{'CHR_FOLDER'} ? $params->{'CHR_FOLDER'} : die "The method FASTA is requested in \"print_all_tags\" but the folder with chromosome sequences is not provided";
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
	
	my $tags_ref = $self->get_tags;
	my %available_chrs;
	foreach my $strand (keys %{$tags_ref}) {
		foreach my $chr (keys %{$$tags_ref{$strand}}) {
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
		
		foreach my $strand (keys %{$tags_ref}) {
			if (exists $$tags_ref{$strand}{$chr}) {
				my $tags_array_ref = $$tags_ref{$strand}{$chr};
				# Unbelievable as it may be, although the if else statement is not needed, having it here speeds up the script by approximately 8 times
				if (defined $maxflank) {
					foreach my $tag (@$tags_array_ref) {
						my $tag_seq;
						if ($strand == 1) {
							$tag_seq = substr($chr_seq,$tag->get_start()+$maxflank-$upflank,$tag->get_length+$upflank+$downflank);
						}
						else {
							$tag_seq = substr($chr_seq,$tag->get_start()+$maxflank-$downflank,$tag->get_length+$upflank+$downflank);
							$tag_seq = reverse($tag_seq);
							if ($tag_seq =~ /U/i) {
								$tag_seq =~ tr/ATGCUatgcu/UACGAuacga/;
							}
							else {
								$tag_seq =~ tr/ATGCUatgcu/TACGAtacga/;
							}
						}
						if (exists $params->{'UPDATE_SEQUENCE'}){$tag->set_sequence($tag_seq);}
						my $header = $tag->to_string("BED");
						$header =~ s/\t/|/g;
						print $OUT ">$header\n$tag_seq\n";
					}
				}
				else {
					foreach my $tag (@$tags_array_ref) {
						my $tag_seq = substr($chr_seq,$tag->get_start,$tag->get_length);
						if ($strand == -1) {
							$tag_seq = reverse($tag_seq);
							if ($tag_seq =~ /U/i) {
								$tag_seq =~ tr/ATGCUatgcu/UACGAuacga/;
							}
							else {
								$tag_seq =~ tr/ATGCUatgcu/TACGAtacga/;
							}
						}
						if (exists $params->{'UPDATE_SEQUENCE'}){$tag->set_sequence($tag_seq);}
						my $header = $tag->to_string("BED");
						$header =~ s/\t/|/g;
						print $OUT ">$header\n$tag_seq\n";
					}
				}
			}
		}
	}
	return 0;
}

=head2 print_all_tags_WIG

  Arg [1]    : hash reference
               A hash reference containing the parameters for the output
               Required parameters are:
                  1/ OUTPUT: STDOUT or filename
                  2/ WINDOW: The size in nucleotides of each bin in the WIG filehandle
                  3/ STEP: The distance in nucleotides between adjacent bins in the WIG file
                  4/ SCORE_TYPE: It take the values "RPKM", "SUM" or "SIMPLE". "SUM" adds the scores of all tags in the window. "RPKM" divides this by the length of the window in kb. "SIMPLE" counts tags in the window
  Example    : print_all_tags({
                  OUTPUT       => "STDOUT",
                  WINDOW       => 1000,
                  STEP         => 100,
                  SCORE_TYPE   => "RPKM"
               })
  Description: Prints all tags for a track object in WIG format.
  Returntype : NULL
  Caller     : ?
  Status     : Stable

=cut
sub print_all_tags_WIG {
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
	my $tags_ref = $self->get_tags;
	$self->sort_tags();
	
	foreach my $strand (keys %{$tags_ref}) {
		$self->print_track_line("WIG", "strand($strand)");
		foreach my $chr (keys %{$$tags_ref{$strand}}) {
			if (exists $$tags_ref{$strand}{$chr}) {
				my $lastend = (sort {$a->get_stop() <=> $b->get_stop()} @{$$tags_ref{$strand}{$chr}})[-1]->get_stop();
				my $last_positive_tag_index = 0;
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
					for (my $i = $last_positive_tag_index; $i< $#{$$tags_ref{$strand}{$chr}}; $i++)
					{
						my $tag = ${$$tags_ref{$strand}{$chr}}[$i];
						
						if ($wiglocus->overlaps($tag))
						{
							if ($scoring_type eq "SUM"){$score += $tag->get_score;}
							elsif ($scoring_type eq "RPKM"){$score += (1000 * $tag->get_score) / $wiglocus->get_length;}
							elsif ($scoring_type eq "SIMPLE"){$score++;}
							$last_positive_tag_index = $i;
						}
						elsif ($wiglocus->get_stop < $tag->get_start)
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

sub sort_tags {
	my ($self) = @_;
	
	my $tags_ref = $self->get_tags;
	foreach my $strand (keys %{$tags_ref}) {
		foreach my $chr (keys %{$$tags_ref{$strand}}) {
			if (exists $$tags_ref{$strand}{$chr}) {
				@{$$tags_ref{$strand}{$chr}} = sort {$a->get_start() <=> $b->get_start()} @{$$tags_ref{$strand}{$chr}};
			}
		}
	}
}

=head2 set_all_tags_sequence

  Arg [1]    : hash reference
               A hash reference containing the parameters for the output.
               Required parameters are:
                  1/ CHR_FOLDER: The folder containing the fasta files of the chromosomes
  Example    : set_all_tags_sequence({
                 CHR_FOLDER       => "/chromosomes/hg19/"
               })
  Description: Sets the SEQUENCE for all tags in the Track.
  Returntype : NULL
  Caller     : ?
  Status     : Stable

=cut
sub set_all_tags_sequence {
	my ($self, $params) = @_;
	
	my $chr_folder = exists $params->{'CHR_FOLDER'} ? $params->{'CHR_FOLDER'} : die "The method FASTA is requested in \"print_all_tags\" but the folder with chromosome sequences is not provided";
	my $tags_ref = $self->get_tags;
	my %available_chrs;
	foreach my $strand (keys %{$tags_ref}) {
		foreach my $chr (keys %{$$tags_ref{$strand}}) {
			$available_chrs{$chr} = 1;
		}
	}
	foreach my $chr (keys %available_chrs) {
		my $chr_file = $chr_folder."/chr$chr.fa";
		unless (-e $chr_file) {
			warn "Skipping chromosome. File $chr_file does not exist";
			next;
		}
		my $chr_seq = MyBio::MySub::read_fasta($chr_file,"chr$chr");
		unless (defined $chr_seq){die "No Chromosome Sequence chr$chr\n";}
		
		foreach my $strand (keys %{$tags_ref}) {
			if (exists $$tags_ref{$strand}{$chr}) {
				my $tags_array_ref = $$tags_ref{$strand}{$chr};
				foreach my $tag (@$tags_array_ref) {
					my $tag_seq = substr($chr_seq,$tag->get_start,$tag->get_length);
					if ($strand == -1) {
						$tag_seq = reverse($tag_seq);
						if ($tag_seq =~ /U/i) {
							$tag_seq =~ tr/ATGCUatgcu/UACGAuacga/;
						}
						else {
							$tag_seq =~ tr/ATGCUatgcu/TACGAtacga/;
						}
					}
					$tag->set_sequence($tag_seq);
				}
			}
		}
	}
	return 0;
}

=head2 calculate_tag_score_mean

  Example    : calculate_tag_score_mean 
  Description: Calculates the mean score of all tags in the track
  Returntype : NULL
  Caller     : ?
  Status     : Experimental / Unstable

=cut
sub calculate_tag_score_mean
{
	my ($self) = @_;
	my $sum;
	my $N;
	my $tags_ref = $self->get_tags;
	foreach my $strand (keys %{$tags_ref}) {
		foreach my $chr (keys %{$$tags_ref{$strand}}) {
			if (exists $$tags_ref{$strand}{$chr}) {
				foreach my $tag ($$tags_ref{$strand}{$chr})
				{
					if (defined $tag->get_score)
					{
						$sum += $tag->get_score;
						$N++;
					}
				}
			}
		}
	}
	my $mean_score = "NaN";
	if (defined $N){
		$mean_score = $sum / $N;
		$self->set_tag_score_mean($mean_score);
		$self->set_tag_count($N);
		$self->set_tag_score_sum($sum);
	}
	
}
=head2 calculate_tag_score_variance

  Example    : calculate_tag_score_variance 
  Description: Calculates the variance of the scores of all tags in the track
  Returntype : NULL
  Caller     : ?
  Status     : Experimental / Unstable

=cut
sub calculate_tag_score_variance
{
	my ($self) = @_;
	my $sumsqdiff;
	my $N;
	my $mean = $self->get_tag_score_mean;
	my $tags_ref = $self->get_tags;
	foreach my $strand (keys %{$tags_ref}) {
		foreach my $chr (keys %{$$tags_ref{$strand}}) {
			if (exists $$tags_ref{$strand}{$chr}) {
				foreach my $tag ($$tags_ref{$strand}{$chr})
				{
					if (defined $tag->get_score)
					{
						$sumsqdiff += ($tag->get_score - $mean) ** 2;
						$N++;
					}
				}
			}
		}
	}
	
	if (defined $N){
		my $variance = $sumsqdiff / $N;
		$self->set_tag_score_variance($variance);
	}
	
}

=head2 calculate_tag_score_sum

  Example    : calculate_tag_score_sum 
  Description: Calculates the sum score of all tags in the track
  Returntype : NULL
  Caller     : ?
  Status     : Experimental / Unstable

=cut
sub calculate_tag_score_sum
{
	my ($self) = @_;
	my $sum;
	my $tags_ref = $self->get_tags;
	foreach my $strand (keys %{$tags_ref}) {
		foreach my $chr (keys %{$$tags_ref{$strand}}) {
			if (exists $$tags_ref{$strand}{$chr}) {
				foreach my $tag (@{$tags_ref->{$strand}->{$chr}})
				{
					if (defined $tag->get_score)
					{
						$sum += $tag->get_score;
					}
				}
			}
		}
	}
	$self->set_tag_score_sum($sum);
	
	
}

=head2 calculate_tag_count

  Example    : calculate_tag_count 
  Description: Calculates the number of all tags in the track
  Returntype : NULL
  Caller     : ?
  Status     : Experimental / Unstable

=cut
sub calculate_tag_score_mean
{
	my ($self) = @_;
	my $N;
	my $tags_ref = $self->get_tags;
	foreach my $strand (keys %{$tags_ref}) {
		foreach my $chr (keys %{$$tags_ref{$strand}}) {
			if (exists $$tags_ref{$strand}{$chr}) {
				foreach my $tag (@{$tags_ref->{$strand}->{$chr}})
				{
					$N++;
				}
			}
		}
	}
	$self->set_tag_count($N);
}

=head2 merge_tags

  Arg [1]    : string $method
               A descriptor of the desired output method (MERGE, SPLITSCORE)
               MERGE: scores of overlapping or whithin a distance tags are summed
               SPLITSCORE: overlapping tags are divided into parts and the score of each part is the sum of the
                           corresponding overlapping tags
  Arg [2..]  : array @attributes
               Additional attributes for the defined output method
  Example    : merge_tags("MERGE", 0) 
               merge_tags("SPLITSCORE", 10)
  Description: Merges loci which overlap or are closer than a given distance with each other (tags are replaced by merged ones)
  Returntype : NULL
  Caller     : ?
  Status     : Experimental / Unstable

=cut
sub merge_tags {
	my ($self,$method,@attributes) = @_;
	
	
	my $tags_ref = $self->get_tags;
	my %merged_hash;
	foreach my $strand (keys %{$tags_ref}) {
		foreach my $chr (keys %{$$tags_ref{$strand}}) {
			if (exists $$tags_ref{$strand}{$chr}) {
				$merged_hash{$strand}{$chr} = [];
				@{$merged_hash{$strand}{$chr}} = $self->merge_tags_in_array($$tags_ref{$strand}{$chr},$method,@attributes);
			}
		}
	}
	$self->set_tags(\%merged_hash);
}

sub collapse_tags {
	
	#will collapse tags that have the same position - the score will be the number of tags that collapsed
	
	my ($self) = @_;
	
	my $tags_ref = $self->get_tags;
	my %collapsed_hash;
	foreach my $strand (keys %{$tags_ref}) {
		foreach my $chr (keys %{$$tags_ref{$strand}}) {
			if (exists $$tags_ref{$strand}{$chr}) {
				$collapsed_hash{$strand}{$chr} = [];
				my %count;
				foreach my $tag (@{$$tags_ref{$strand}{$chr}})
				{
					my $start = $tag->get_start;
					my $stop = $tag->get_stop;
					$count{"$start|$stop"}++;
				}
				foreach my $pos (keys %count)
				{
					my ($start, $stop) = split(/\|/,$pos);
					my $tagObj = MyBio::NGS::Tag->new({
						CHR           => $chr,
						START         => $start,
						STOP          => $stop,
						STRAND        => $strand,
						NAME          => $count{$pos},
						SCORE         => $count{$pos},
					});
					push (@{$collapsed_hash{$strand}{$chr}}, $tagObj);
					
				}
			}
		}
	}
	$self->set_tags(\%collapsed_hash);
}

sub merge_tags_in_array {
	my ($self,$tags_array_ref,$method,@attributes) = @_;
	my @out = ();
	my @temp = ();
	my $offset;
	
	if ($method eq "MERGE") {
		$offset = $attributes[0];
	}
	
	my $region_of_overlap;
	foreach my $tag (@$tags_array_ref) {
		if (!defined $region_of_overlap) {
			$region_of_overlap = $tag->clone(); 
			push(@temp, $tag);
		}
		elsif ($region_of_overlap->overlaps($tag,$offset)) {
			push(@temp, $tag);
			my $start = $region_of_overlap->get_start < $tag->get_start ? $region_of_overlap->get_start : $tag->get_start;
			my $stop = $region_of_overlap->get_stop > $tag->get_stop ? $region_of_overlap->get_stop : $tag->get_stop;
			$region_of_overlap->set_start($start);
			$region_of_overlap->set_stop($stop);
		}
		else {
			$region_of_overlap = $tag->clone();
			if ($#temp == 0) {
				push (@out, $temp[0]);
			}
			else {
				push(@out,$self->resolve_overlaping_tags(\@temp,$method,@attributes));
			}
			@temp = ();
			push(@temp, $tag);
		}
	}
	
	if ($#temp == 0) {
		push (@out, $temp[0]);
	}
	else {
		push(@out,$self->resolve_overlaping_tags(\@temp,$method,@attributes));
	}
	@temp = ();
	return @out;
}
sub resolve_overlaping_tags {
	my ($self,$temp,$method,@attributes) = @_;
	
	if ($method eq "MERGE") {
		return $self->merge_overlaping_tags($temp);
	}
	elsif ($method eq "SPLITSCORE") {
		return $self->splitscore_overlaping_tags($temp);
	}
}
sub merge_overlaping_tags {
	my ($self,$temp) = @_;
	
	my @tagobjects = sort {$a->get_start() <=> $b->get_start()} @{$temp};
	
	my @out = ();
	my $newtag = $tagobjects[0];
	for (my $i = 1; $i < @tagobjects; $i++) {
		if ($tagobjects[$i]->get_start() < $newtag->get_start()) {
			$newtag->set_start($tagobjects[$i]->get_start());
		}
		if ($tagobjects[$i]->get_stop() > $newtag->get_stop()) {
			$newtag->set_stop($tagobjects[$i]->get_stop());
		}
		my $tempscore = $newtag->get_score() + $tagobjects[$i]->get_score();
		$newtag->set_score($tempscore);
		$newtag->set_name($tempscore);
	}
	push (@out,$newtag);
	return @out;
}
sub splitscore_overlaping_tags {
	my ($self,$temp) = @_;
	
	my @tagobjects = sort {$a->get_start() <=> $b->get_start()} @{$temp};
	
	my @out = @tagobjects;
	my $tag1;
	my $tag2;
	for (my $i=0;$i<@tagobjects-1;$i++) {
		$tag1 = $tagobjects[$i];
		$tag2 = $tagobjects[$i+1];
		
		if ($tag1->overlaps($tag2)) {
			my @temp = $self->divide_tags_by_score($tag1,$tag2);
			if ($i > 0) {
				push (@temp, @tagobjects[0..($i-1)]);
			}
			if ($i+2 <= @tagobjects-1) {
				push (@temp, @tagobjects[($i+2)..@tagobjects-1]);
			}
			@out = $self->splitscore_overlaping_tags(\@temp);
			last;
		}
	}
	return @out;
}
sub divide_tags_by_score {
	my ($self,$tagobj1,$tagobj2) = @_;
	
	my @out = ();
	
	my $chr = $tagobj1->get_chr();
	my $strand = $tagobj1->get_strand();
	my ($newobj1_start, $newobj1_stop, $newobj1_score);
	my ($newobj2_start, $newobj2_stop, $newobj2_score);
	my ($newobj3_start, $newobj3_stop, $newobj3_score);
	
	$newobj1_start = $tagobj1->get_start();
	$newobj1_stop = $tagobj2->get_start()-1;
	$newobj1_score = $tagobj1->get_score();
	
	$newobj2_start = $tagobj2->get_start();
	$newobj2_score = $tagobj1->get_score() + $tagobj2->get_score();
		
	if ($tagobj1->get_stop() > $tagobj2->get_stop()) {
		$newobj2_stop = $tagobj2->get_stop();
		$newobj3_start = $tagobj2->get_stop()+1;
		$newobj3_stop = $tagobj1->get_stop();
		$newobj3_score = $tagobj1->get_score();
	}
	else {
		$newobj2_stop = $tagobj1->get_stop();
		$newobj3_start = $tagobj1->get_stop()+1;
		$newobj3_stop = $tagobj2->get_stop();
		$newobj3_score = $tagobj2->get_score();
	}
	
	if ($newobj1_start <= $newobj1_stop) {
		my $tagObj = MyBio::NGS::Tag->new({
			CHR           => $chr,
			START         => $newobj1_start,
			STOP          => $newobj1_stop,
			STRAND        => $strand,
			NAME          => undef,
			SCORE         => $newobj1_score,
		});
		push (@out, $tagObj);
	}
	if ($newobj2_start <= $newobj2_stop) {
		my $tagObj = MyBio::NGS::Tag->new({
			CHR           => $chr,
			START         => $newobj2_start,
			STOP          => $newobj2_stop,
			STRAND        => $strand,
			NAME          => undef,
			SCORE         => $newobj2_score,
		});
		push (@out,$tagObj);
	}
	if ($newobj3_start <= $newobj3_stop) {
		my $tagObj = MyBio::NGS::Tag->new({
			CHR           => $chr,
			START         => $newobj3_start,
			STOP          => $newobj3_stop,
			STRAND        => $strand,
			NAME          => undef,
			SCORE         => $newobj3_score,
		});
		push (@out,$tagObj);
	}
	return @out;
}
sub find_closest_tag_index_to_position {
	my ($self,$target_value,$tags,$fromIndex,$toIndex)=@_; 
	#target_value = the value we want to match
	#tags = a reference to an array of tag objects. the index will match this array 
	#fromIndex - toIndex = range of indexes that will be used for the search
	
	if ($toIndex == -1){return $fromIndex;}
	my $closest_index;
	if ($fromIndex == $toIndex){return $fromIndex;}	
	
	my $scanIndex=int($fromIndex+($toIndex-$fromIndex)/2); #begin at half-way point

	if ($toIndex == $fromIndex+1){$closest_index = $self->compare_value_to_the_two_others($target_value,$tags,($scanIndex+1),$scanIndex);} #end
	elsif ($target_value == $$tags[$scanIndex]->get_start()) {$closest_index = $scanIndex;} #end - found exact value
	elsif ($target_value <  $$tags[$scanIndex]->get_start()) {
		if   ($target_value >=  $$tags[$scanIndex-1]->get_start()) {
		
			$closest_index = $self->compare_value_to_the_two_others($target_value,$tags,$scanIndex,($scanIndex-1));
		}
		else {
			$closest_index = $self->find_closest_tag_index_to_position($target_value,$tags,$fromIndex,$scanIndex);
		}
	}
	elsif ($target_value >  $$tags[$scanIndex]->get_start()) {
		if   ($target_value <=  $$tags[$scanIndex+1]->get_start()) {
		
			$closest_index = $self->compare_value_to_the_two_others($target_value,$tags,($scanIndex+1),$scanIndex);
		}
		else {
			$closest_index = $self->find_closest_tag_index_to_position($target_value,$tags,$scanIndex,$toIndex);
		}
	}
	return $closest_index;
}
sub compare_value_to_the_two_others {
	my ($self,$value,$tags,$index1,$index2)=@_;
	
	my $dif1=abs($value-($$tags[$index1]->get_start()));
	my $dif2=abs($value-($$tags[$index2]->get_start()));
	
	if ($dif1 <= $dif2) {return $index1;}
	else                {return $index2;}
}

=head2 overlaps

  Arg [1]    : object MyBio::NGS:Track
               The track against which $self is compared. 
  Arg [2]    : hash reference
               A hash reference containing the parameters for the overlap. Important: The type of overlap (IS_CONTAINED, TOUCHES) must be specified!
  Example    : $track->overlaps($track2, {
                   METHOD  =>"TOUCHES",
                   OFFSET  => 0
               })
  Description: Sets for all tags in the $self track the overlap attribute.
               This attribute indicates whether the tag overlaps with any of the tags on the reference track
  Returntype : NULL
  Caller     : ?
  Status     : Experimental / Unstable

=cut
sub overlaps {
	my ($self, $track2, $params) = @_;
	
	# Check to enable correction of legacy programs. Previously this sub accepted parameters through an array instead of a hash
	unless (ref($params) eq "HASH") {
		my $class = ref($self) || $self;
		die "\n\nDon't panic - Just change the way you call method \"overlaps\" through $class in your calling script $0\n\n";
	}
	
	# Get the method to check overlap
	my $method = $params->{'METHOD'}; delete $params->{'METHOD'};
	unless (defined $method) {
		my $class = ref($self) || $self;
		die "\nNo print method specified in $class\::print_all_tags";
	}
	
	if ($method eq "IS_CONTAINED"){
		$self->_overlaps_IS_CONTAINED($track2, $params);
	}
	elsif ($method eq "TOUCHES") {
		$self->_overlaps_TOUCHES($track2, $params);
	}
	else {
		my $class = ref($self) || $self;
		die "\nUnknown overlap method \"$method\" specified in $class\::overlaps. Try (IS_CONTAINED|TOUCHES)";
	}
}

=head2 _overlaps_IS_CONTAINED

  Arg [1]    : object MyBio::NGS:Track
               The track against which $self is compared. 
  Example    : $track->_overlaps_IS_CONTAINED($track2)
  Description: Sets for all tags in the $self track the overlap attribute.
               This attribute indicates whether the tag overlaps with any of the tags on the reference track.
               A tag is said to overlap with another tag if it is contained within (both start and end position) the other tag.
  Returntype : NULL
  Caller     : ?
  Status     : Experimental / Unstable

=cut
sub _overlaps_IS_CONTAINED {
	my ($self, $track2, $params) = @_;
	
	my $tags_ref = $self->get_tags;
	my $tags2_ref = $track2->get_tags;
	foreach my $strand (keys %{$tags_ref}) {
		foreach my $chr (keys %{$$tags_ref{$strand}}) {
			if (exists $$tags_ref{$strand}{$chr}) {
				if (exists $$tags2_ref{$strand}{$chr}) {
					foreach my $tag (@{$$tags_ref{$strand}{$chr}}) {
						foreach my $tag2 (@{$$tags2_ref{$strand}{$chr}}) {
							if ($tag->get_stop < $tag2->get_start) {
								last;
							}
							elsif ($tag2->contains($tag)) {
								$tag->set_overlap($track2->get_id,1);
							}
						}
					}
				}
			}
		}
	}
}

=head2 _overlaps_TOUCHES

  Arg [1]    : object MyBio::NGS:Track
               The track against which $self is compared.
  Arg [2]    : hash reference
               A hash reference containing the parameters for the overlap.
  Example    : $track->_overlaps_TOUCHES($track2, {
                   OFFSET  => 0
               })
  Description: Sets for all tags in the $self track the overlap attribute.
               This attribute indicates whether the tag overlaps with any of the tags on the reference track.
               A tag is said to overlap with another tag if it is located within OFFSET distance from the other tag.
  Returntype : NULL
  Caller     : ?
  Status     : Experimental / Unstable

=cut
sub _overlaps_TOUCHES {
	my ($self, $track2, $params) = @_;
	
	my $offset = exists $params->{'OFFSET'} ? $params->{'OFFSET'} : 0;
	
	my $tags_ref = $self->get_tags;
	my $tags2_ref = $track2->get_tags;
	foreach my $strand (keys %{$tags_ref}) {
		foreach my $chr (keys %{$$tags_ref{$strand}}) {
			if (exists $$tags_ref{$strand}{$chr}) {
				if (exists $$tags2_ref{$strand}{$chr}) {
					foreach my $tag (@{$$tags_ref{$strand}{$chr}}) {
						foreach my $tag2 (@{$$tags2_ref{$strand}{$chr}}) {
							if ($tag->get_stop < $tag2->get_start) {
								last;
							}
							elsif ($tag2->overlaps($tag, $offset)) {
								$tag->set_overlap($track2->get_id,1);
								$tag2->set_overlap($self->get_id,1);
							}
						}
					}
				}
			}
		}
	}
}


#######################################################################
##########################   Class Methods   ##########################
#######################################################################
{
	my %allTracks;
	my $track_counter = 0;
	
	sub _increase_track_counter {
		$track_counter++;
		return $track_counter;
	}
	
	sub _add_to_all {
		my ($class,$obj) = @_;
		$allTracks{$obj->get_id} = $obj;
	}
	sub _delete_from_all {
		my ($class,$obj) = @_;
		delete $allTracks{$obj->get_id};
	}
	sub get_all {
		my ($class) = @_;
		return %allTracks;
	}
	sub delete_all {
		my ($class) = @_;
		%allTracks = ();
	}
	sub get_by_id {
		my ($class,$id) = @_;
		return $allTracks{$id};
	}
	sub get_by_name {
		my ($class,$name) = @_;
		my @outtracks = ();
		foreach my $track (values %allTracks) {
			if ($name eq $track->get_name) {
				push @outtracks, $track;
			}
		}
		if (@outtracks > 0) {
			return @outtracks;
		}
		else {
			return undef;
		}
	}
	sub read_tracks {
		my ($class,$method,@attributes) = @_;
		
		my %tracks;
		if ($method eq "BED") {
			my $filename = $attributes[0];
			my $trackname = $attributes[1];
			%tracks = $class->_read_bedFile($filename, $trackname);
			
		}
		else {
			die "\nUnknown read method \"$method\" specified in $class\::read_tracks. Try (BED)";
		}
		$_->sort_tags for (values %tracks);
		return %tracks;
	}
	sub _read_bedFile {
		my ($class,$filename, $trackname) = @_;
		
		if (!defined $trackname){$trackname = scalar(localtime());}
		my $track;
		my @browser_info;
		my %return_tracks;
		my $BED = new FileHandle;
# 		my $maf_read_pos=$MAF->getpos; # reading place in the filehandle
# 		$MAF->setpos($maf_read_pos);
		$BED->open($filename) or die "Cannot open file $filename $!";
		while (my $line=<$BED>){
			chomp($line);
			if ($line =~ /^track/){
				my %info;
				while ($line =~ /(\S+?)=(".+?"|\d+?)/g) {
					$info{$1} = $2;
				}
				$track = $class->new({
					NAME            => $info{"name"} || $trackname,
					DESCRIPTION     => $info{"description"},
					VISIBILITY      => $info{"visibility"},
					COLOR           => $info{"color"},
					RGB_FLAG        => $info{"itemRgb"},
					COLOR_BY_STRAND => $info{"colorByStrand"},
					USE_SCORE       => $info{"useScore"},
				});
				if (@browser_info > 0) {
					$track->push_to_browser(@browser_info);
					@browser_info = ();
				}
				$return_tracks{$track->get_name} = $track;
			}
			elsif ($line =~ /^browser/) {
				push @browser_info,$line;
			}
			elsif ($line =~ /^chr/) {
				
				if (!defined $track){
					$track = $class->new({
						NAME            => $trackname
					});
					if (@browser_info > 0) {
						$track->push_to_browser(@browser_info);
						@browser_info = ();
					}
					$return_tracks{$track->get_name} = $track;
				}
				
				
				my ($chr,$start,$stop,$name,$score,$strand,@others) = split(/\t/,$line);
				
				my $tag = MyBio::NGS::Tag->new({
					STRAND        => $strand,
					CHR           => $chr,
					START         => $start,
					STOP          => $stop - 1, #[start,stop)
					NAME          => $name,
					SCORE         => $score,
					THICK_START   => $others[0],
					THICK_STOP    => $others[1],
					RGB           => $others[2],
					BLOCK_COUNT   => $others[3],
					BLOCK_SIZES   => $others[4],
					BLOCK_STARTS  => $others[5],
				});
				
				$track->add_tag($tag);
			}
		}
		close $BED;
		return %return_tracks;
	}
	
	sub available_strands {
		my ($class) = @_;
		
		my %tracks = MyBio::NGS::Track->get_all();
		my %available_strands;
		foreach my $track (values %tracks) {
			my $tags_ref = $track->get_tags;
			foreach my $strand (keys %{$tags_ref}) {
				$available_strands{$strand} = 1;
			}
		}
		return %available_strands;
	}
	
	sub available_chromosomes {
		my ($class) = @_;
		
		my %tracks = MyBio::NGS::Track->get_all();
		my %available_chrs;
		foreach my $track (values %tracks) {
			my $tags_ref = $track->get_tags;
			foreach my $strand (keys %{$tags_ref}) {
				foreach my $chr (keys %{$tags_ref->{$strand}}) {
					$available_chrs{$chr} = 1;
				}
			}
		}
		return %available_chrs;
	}
}

1;
