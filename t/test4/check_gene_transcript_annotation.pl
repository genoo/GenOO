#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
use XML::Simple;
use File::Path qw(make_path);
use Data::Dumper;

use lib '/home/mns/lib/perl/class/v5.2';
use MyBio::Transcript;

# Read command options
my $help;
GetOptions(
        'h'            => \$help,
) or usage();
usage() if $help;

my $time = time;

# Read arguments and die if not correct
my $species_id = shift;

unless (defined $species_id) {
	usage();
}
my $gtffile = "/data1/data/UCSC/$species_id/annotation/UCSC_gene_parts.gtf";
my $exoninfofile = "/data1/data/UCSC/$species_id/annotation/UCSC_exons.txt";
# my $gtffile = "UCSC_gene_parts.gtf";

warn "Reading EXON_INFO_FILE\n";
# my %transcripts = MyBio::Transcript->read_transcripts("GTF", $gtffile);
my %transcripts = MyBio::Transcript->read_transcripts("EXON_INFO_FILE", $exoninfofile);
warn "Reading EXON_INFO_FILE\tDONE\n";

# print join("\t", ('strand','chr','start','stop','exon','intron','utr5','cds','utr3'))."\n";
foreach my $transcript (values %transcripts) {
	if (($transcript->get_chr =~ /hap/) or ($transcript->get_chr =~ /^Un_/) or ($transcript->get_chr =~ /random/) or (length($transcript->get_chr) > 10) or ($transcript->get_strand eq '.')){
		warn "Discarding ".$transcript->get_enstid." in chr ".$transcript->get_chr."\n";
		next;
	}
	unless ($transcript->get_enstid eq "uc008atc.1") {
		next;
	}
	$transcript->get_cdna();
	$transcript->get_utr5();
	$transcript->get_cds();
	$transcript->get_utr3();
	warn Dumper($transcript);
	die;
	my $exons = $transcript->get_exons_split_by_function;
	my $introns = $transcript->get_introns;
	
	foreach my $annotated_region (@$introns, @$exons) {
		my $intron_flag = 0;
		my $exon_flag = 0;
		my $utr5_flag = 0;
		my $cds_flag = 0;
		my $utr3_flag = 0;
		
		if ($annotated_region->whatami eq 'Intron') {
			$intron_flag = 1;
		}
		elsif ($annotated_region->whatami eq 'Exon') {
			$exon_flag = 1;
			if ($annotated_region->get_where->whatami eq 'UTR5') {
				$utr5_flag = 1;
			}
			if ($annotated_region->get_where->whatami eq 'CDS') {
				$cds_flag = 1;
			}
			if ($annotated_region->get_where->whatami eq 'UTR3') {
				$utr3_flag = 1;
			}
		}
		print join("\t",(
			$annotated_region->get_strand,
			$annotated_region->get_chr,
			$annotated_region->get_start,
			$annotated_region->get_stop,
			$exon_flag,
			$intron_flag,
			$utr5_flag,
			$cds_flag,
			$utr3_flag,
			$transcript->get_enstid,
		))."\n";
# 		my $strand  = ($annotated_region->get_strand) == 1 ? '+' : '-';
# 		print join("\t",(
# 			"chr".$annotated_region->get_chr,
# 			$annotated_region->get_start,
# 			$annotated_region->get_stop,
# 			$annotated_region->whatami,
# 			$cds_flag,
# 			$strand,
# 		))."\n";
	}
}

###########################################
# Subroutines used
###########################################
sub usage {
	print "\nUsage:   $0 [options] <species_id>\n\n".
	      "Options:\n".
	      "        -h             print this help\n\n";
	exit;
}
