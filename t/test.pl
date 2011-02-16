use warnings;
use strict;

use lib '/home/pan.alexiou/lib/perl/class/v3.4';

use Transcript;
use Locus;

my $infile = shift;

Transcript->read_transcripts("GTF", $infile);

