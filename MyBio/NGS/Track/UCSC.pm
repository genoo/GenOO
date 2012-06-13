# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::Track::UCSC - Object that corresponds to a UCSC defined track

=head1 SYNOPSIS

    # To initialize 
    my $track = MyBio::NGS::Track::UCSC->new({
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
    });


=head1 DESCRIPTION

    The primary data structure of this object is a 2D hash whose primary key is the strand 
    and its secondary key is the chromosome name. Each such pair of keys correspond to an
    array reference which stores objects of the class <MyBio::Locus> sorted by start position.

=head1 EXAMPLES

    # Read tracks from a file in BED format
    my %tracks = MyBio::NGS::Track::UCSC->read_tracks("BED",$filename);
    
    # Parse the above read hash and print tags for each track in FASTA format
    foreach my $track (values %tracks) {
        $track->print_all_tags("FASTA",'STDOUT',"/data1/data/UCSC/hg19/chromosomes/");
    }

=cut

# Let the code begin...

package MyBio::NGS::Track::UCSC;
use strict;

use base qw(MyBio::NGS::Track);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	$self->set_visibility($$data{VISIBILITY});
	$self->set_color($$data{COLOR});
	$self->set_rgb_flag($$data{RGB_FLAG});
	$self->set_color_by_strand($$data{COLOR_BY_STRAND});
	$self->set_use_score($$data{USE_SCORE});
	$self->set_browser($$data{BROWSER});
	
	return $self;
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_visibility {
	my ($self, $value) = @_;
	$self->{VISIBILITY}=$value if defined $value;
}

sub set_color {
	my ($self, $value) = @_;
	$self->{COLOR}=$value if defined $value;
}

sub set_rgb_flag {
	my ($self, $value) = @_;
	$self->{RGB_FLAG}=$value if defined $value;
}

sub set_color_by_strand {
	my ($self, $value) = @_;
	$self->{COLOR_BY_STRAND}=$value if defined $value;
}

sub set_use_score {
	my ($self, $value) = @_;
	$self->{USE_SCORE}=$value if defined $value;
}

sub set_browser {
	my ($self, $value) = @_;
	$self->{BROWSER} = defined $value ? $value : [];
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_visibility {
	my ($self) = @_;
	return $self->{VISIBILITY};
}
sub get_color {
	my ($self) = @_;
	return $self->{COLOR};
}
sub get_rgb_flag {
	my ($self) = @_;
	return $self->{RGB_FLAG};
}
sub get_color_by_strand {
	my ($self) = @_;
	return $self->{COLOR_BY_STRAND};
}
sub get_use_score {
	my ($self) = @_;
	return $self->{USE_SCORE};
}
sub get_browser {
	my ($self) = @_;
	return $self->{BROWSER};
}



#######################################################################
#########################   General Methods   #########################
#######################################################################
sub output_track_line {
	my ($self, $method, @attributes) = @_;
	if ($method eq "BED") {
		my $trackline = "track name=".$self->get_name;
		if (defined $self->get_description){$trackline .= " description=".$self->get_description;}
		if (defined $self->get_visibility){$trackline .= " visibility=".$self->get_visibility;}
		if (defined $self->get_color){$trackline .= " color=".$self->get_color;}
		if (defined $self->get_rgb_flag){$trackline .= " itemRgb=".$self->get_rgb_flag;}
		if (defined $self->get_color_by_strand){$trackline .= " colorByStrand=".$self->get_color_by_strand;}
		if (defined $self->get_use_score){$trackline .= " useScore=".$self->get_use_score;}
		return $trackline;
	}
	elsif ($method eq "WIG") {
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

1;
