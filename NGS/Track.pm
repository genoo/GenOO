package NGS::Track;

use warnings;
use strict;

use FileHandle;
use _Initializable;
use NGS::Tag;

our @ISA = qw( _Initializable );

# HOW TO INITIALIZE THIS OBJECT
# my $tagObj = Misc::Peak->new({
# 		     CHR           => undef,
# 		     CHR_START     => undef,
# 		     CHR_STOP      => undef,
# 		     NAME          => undef,
# 		     TAGS          => undef,
# 		     STRAND        => undef,
# 		     EXTRA_INFO    => undef,
# 		     });

sub _init {
	
	my ($self,$data) = @_;
	
	$self->set_name($$data{NAME});
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
	
		
	my $class = ref($self) || $self;
	$class->_add_to_all($self);
	my $id = $class->_increase_track_counter;
	
	$self->set_id($id);
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_name {
	return $_[0]->{NAME};
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
#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_name {
	$_[0]->{NAME}=$_[1] if defined $_[1];
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

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub add_tag {
	my ($self,$tag) = @_;
	push @{$self->get_tags->{$tag->get_strand}->{$tag->get_chr}},$tag;
}
sub push_to_browser {
	my ($self,@values) = @_;
	push @{$self->get_browser},@values;
}

sub output_track_line {
	my ($self, $method) = @_;
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
}

sub print_track_line {
	my ($self, $method) = @_;
	if ($method eq "BED"){
		print $self->output_track_line("BED")."\n";
	}
}

sub print_all_tags {
	my ($self, $method) = @_;
	
	if ($method eq "BED"){
		my $tags_ref = $self->get_tags;
		foreach my $strand (keys %{$tags_ref}) {
			foreach my $chr (keys %{$$tags_ref{$strand}}) {
				if (exists $$tags_ref{$strand}{$chr}) {
					foreach my $tag (@{$$tags_ref{$strand}{$chr}})
					{
						print $tag->output_tag("BED")."\n";
					}
				}
			}
		}
	}

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
					my $tagObj = NGS::Tag->new({
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
		my $tagObj = NGS::Tag->new({
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
		my $tagObj = NGS::Tag->new({
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
		my $tagObj = NGS::Tag->new({
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

sub overlaps {
	my ($self, $track2, $method, @attributes) = @_;
	
	if ($method eq "IS_CONTAINED"){
		my $tags_ref = $self->get_tags;
		my $tags2_ref = $track2->get_tags;
		foreach my $strand (keys %{$tags_ref}) {
			foreach my $chr (keys %{$$tags_ref{$strand}}) {
				if (exists $$tags_ref{$strand}{$chr}) {
					if (exists $$tags2_ref{$strand}{$chr}) {
						foreach my $tag (@{$$tags_ref{$strand}{$chr}})
						{
							foreach my $tag2 (@{$$tags2_ref{$strand}{$chr}})
							{
								if ($tag->get_stop < $tag2->get_start){last;}
								elsif ($tag2->contains($tag)){$tag->set_overlap($track2->get_id,1);}
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
		$allTracks{$obj->get_name} = $obj;
	}
	sub _delete_from_all {
		my ($class,$obj) = @_;
		delete $allTracks{$obj->get_name};
	}
	sub get_all {
		my ($class) = @_;
		return %allTracks;
	}
	sub delete_all {
		my ($class) = @_;
		%allTracks = ();
	}
	sub get_by_name {
		my ($class,$name) = @_;
		if (exists $allTracks{$name}) {
			return $allTracks{$name};
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
				
				my $tag = NGS::Tag->new({
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
}

1;