use warnings;
use strict;

use lib '/home/pan.alexiou/lib/perl/class/v3.4';
use NGS::Track;
use Transcript;
use Locus;
use MyMath;

my $longest_tag = 200;
my $infile = "foo.bed"; #bed file
my $gtffile = "foo.gtf";

my %transcripts = Transcript->read_transcripts("GTF", $gtffile);

NGS::Track->read_tracks("BED",$infile);
my %tracks = NGS::Track->get_all;

foreach my $transcript (values %transcripts)
{
	foreach my $region ($transcript->get_utr3, $transcript->get_cdna, $transcript->get_utr5, $transcript->get_cds)
	{
		unless (defined $region){next;}
		my $regclass = ref($region) || $region;
		$regclass =~ s/Transcript:://g;
		foreach my $block (@{$region->get_introns}, @{$region->get_exons})
		{
			if ((!defined $block->get_start) or (!defined $block->get_stop))
			{
				warn "\n\t$block not defined start/end\n";
				warn "\tstart = ".$block->get_start."\n";
				warn "\tstop = ".$block->get_stop."\n";
				warn "\tchr = ".$block->get_chr."\n";
				warn "\tenstid = ".$transcript->get_enstid."\n";
				warn "\tregion = ".$regclass."\n\n";
				
				next;
			}
			
			my $blockclass = ref($block) || $block;
			$blockclass =~ s/Transcript:://g;
						
			foreach my $id (keys %tracks)
			{	
	# 				print "intron: ".$intron."\n";
				my $tag_count = count_overlapping_tags($block,$id, $longest_tag);
				my $xcoverage = count_coverage_by_tags($block,$id, $longest_tag);
				
				if($tag_count){print $tracks{$id}->get_name."\t".$transcript->get_enstid."\t".$transcript->get_biotype."\t".$regclass."\t".$blockclass."\t".$tag_count."\t".$block->get_length."\t".MyMath::round_digits(($xcoverage),4)."\n";}
			}
		}
	}
}

sub count_overlapping_tags {
	my ($locus_object, $track_id, $longest_tag) = @_;
# 	print $locus_object."\n";
	my $tags = 0;
	
	my $chr = $locus_object->get_chr;
	my $strand = $locus_object->get_strand;
	my %tracks = NGS::Track->get_all;
	my $track = $tracks{$track_id};
	if (exists $track->get_tags->{$strand}->{$chr})
	{
		my $upstream_start = $track->find_closest_tag_index_to_position(($locus_object->get_start-$longest_tag),$track->get_tags->{$strand}->{$chr},0,$#{$track->get_tags->{$strand}->{$chr}});
		for (my $i = $upstream_start; $i <= $#{$track->get_tags->{$strand}->{$chr}}; $i++) 
		{
			my $tag = ${$track->get_tags->{$strand}->{$chr}}[$i];
			if ($locus_object->overlaps($tag)) {
				$tags += $tag->get_score;
			}
			if ($tag->get_start > $locus_object->get_stop){last;}
	
		}
	}
	return $tags;
}

sub count_coverage_by_tags {
	my ($locus_object, $track_id, $longest_tag) = @_;
# 	print $locus_object."\n";
	my $coverage = 0;
	
	my $chr = $locus_object->get_chr;
	my $strand = $locus_object->get_strand;
	my %tracks = NGS::Track->get_all;
	my $track = $tracks{$track_id};
	if (exists $track->get_tags->{$strand}->{$chr})
	{
		my $upstream_start = $track->find_closest_tag_index_to_position(($locus_object->get_start-$longest_tag),$track->get_tags->{$strand}->{$chr},0,$#{$track->get_tags->{$strand}->{$chr}});
		for (my $i = $upstream_start; $i <= $#{$track->get_tags->{$strand}->{$chr}}; $i++) 
		{
			my $tag = ${$track->get_tags->{$strand}->{$chr}}[$i];
			if ($locus_object->overlaps($tag)) {
				$coverage += $locus_object->get_overlap_length($tag) * $tag->get_score;
			}
			if ($tag->get_start > $locus_object->get_stop){last;}
	
		}
	}
	if ($locus_object->get_length == 0){return 0;}
	my $average_coverage = $coverage / $locus_object->get_length;
	return $average_coverage;
}



