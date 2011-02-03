package NGS::Track::Bed;

use warnings;
use strict;

use FileHandle;
use NGS::Track;

our @ISA = qw( NGS::Track );

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
	
	$self->SUPER::_init($data);
# 	$self->set_filehandle($$data{FILEHANDLE});
# 	$self->set_filehandle_start($$data{FILEHANDLE_START});
# 	$self->set_filehandle_pos($$data{FILEHANDLE_POS});
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
# sub get_name {
# 	return $_[0]->{NAME};
# }
#######################################################################
#############################   Setters   #############################
#######################################################################
# sub set_name {
# 	$_[0]->{NAME}=$_[1] if defined $_[1];
# }
#######################################################################
#########################   General Methods   #########################
#######################################################################

#######################################################################
##########################   Class Methods   ##########################
#######################################################################
{
	sub read_bedFile {
		my ($class,$filename) = @_;
		
		my $track;
		my @browser_info;
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
				$track = NGS::Track::Bed->new({
					NAME            => $info{"name"},
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
			}
			elsif ($line =~ /^browser/) {
				push @browser_info,$line;
			}
			elsif ($line =~ /^chr/) {
				my ($chr,$start,$stop,$name,$score,$strand,@others) = split(/\t/,$line);
				my $tag = NGS::Tag->new({
					STRAND        => $strand,
					CHR           => $chr,
					START         => $start,
					STOP          => $stop,
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
	}
}

1;