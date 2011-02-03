use warnings;
use strict;

use lib '/home/pan.alexiou/lib/perl/class/v3.3';

use NGS::Track;
my $filename = $ARGV[0];
my $sample_name = (split(/\//, $filename))[-3];

my %tracks = NGS::Track->read_tracks("BED",$ARGV[0],"$sample_name");

foreach my $track (values %tracks) {
	$track->collapse_tags;
	$track->sort_tags;
	$track->set_color_by_strand("\"255,0,0 0,255,0\"");
	$track->print_track_line("BED");
	$track->print_all_tags("BED");
}
