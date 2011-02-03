package Misc::Peak;

use warnings;
use strict;

use _Initializable;

our @ISA = qw( _Initializable );

# HOW TO INITIALIZE THIS OBJECT
# my $peakObj = Misc::Peak->new({
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
	
	$$data{CHR} =~ s/>*chr//;
	$$data{STRAND} =~ s/^\+$/1/;
	$$data{STRAND} =~ s/^\-$/-1/;
	
	$self->{CHR}           = $$data{CHR};
	$self->{CHR_START}     = $$data{CHR_START};
	$self->{CHR_STOP}      = $$data{CHR_STOP};
	$self->{NAME}          = $$data{NAME};
	$self->{TAGS}          = $$data{TAGS};
	$self->{STRAND}        = $$data{STRAND};
	$self->{EXTRA_INFO}    = $$data{EXTRA_INFO};
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_chr        {return $_[0]->{CHR};}
sub get_chr_start  {return $_[0]->{CHR_START};}
sub get_chr_stop   {return $_[0]->{CHR_STOP};}
sub get_name       {return $_[0]->{NAME};}
sub get_tags       {return $_[0]->{TAGS};}
sub get_strand     {return $_[0]->{STRAND};}
sub get_extra      {return $_[0]->{EXTRA_INFO};}
sub get_length     {return $_[0]->{CHR_STOP}-$_[0]->{CHR_START}+1}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_tags   { $_[0]->{TAGS}=$_[1] if defined $_[1];}
sub set_extra  { $_[0]->{EXTRA_INFO} = $_[1] if defined $_[1];}

#######################################################################
##########################   Class Methods   ##########################
#######################################################################
{
	my %allPeaks;
	
	sub _add_to_all_peaks {
		my ($class,$obj) = @_;
		push @{$allPeaks{$obj->get_strand()}{$obj->get_chr()}},$obj;
	}
	
	sub _delete_from_all_interactions {
		my ($class,$obj) = @_;
		delete $allPeaks{$obj->get_strand()}{$obj->get_chr()};
	}
	
	sub get_all_peaks {
		my ($class) = @_;
		return %allPeaks;
	}
	
	sub read_bedFile_to_hash_of_peak_objects {
		my ($class,$inFile,$tagCountThreshold) = @_;
		
		open (IN,$inFile) or die "Cannot open file $inFile: $!";
		while (my $line=<IN>){
			chomp($line);
			
			my ($chr,$start,$stop,$name,$tagsCount,$strand)=split(/\t/,$line);
			if (($tagCountThreshold == 0) || ($tagsCount > $tagCountThreshold)) {
				my $peakObj = $class->new({
						CHR           => $chr,
						CHR_START     => $start,
						CHR_STOP      => $stop,
						NAME          => $name,
						TAGS          => $tagsCount,
						STRAND        => $strand,
						EXTRA_INFO    => undef,
						});
				$class->_add_to_all_peaks($peakObj);
			}
		}
		close IN;
		$class->sort_all_peaks();
		
		return %allPeaks;
	}
	
	sub sort_all_peaks {
		my ($class) = @_;
		
		foreach my $strand (keys %allPeaks) {
			foreach my $chr (keys %{$allPeaks{$strand}}) {
				if (exists $allPeaks{$strand}{$chr}) {
					@{$allPeaks{$strand}{$chr}} = sort {$a->get_chr_start() <=> $b->get_chr_start()} @{$allPeaks{$strand}{$chr}};
				}
			}
		}
	}
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub push_extra {
	unless (defined $_[0]->{EXTRA_INFO}) {
		$_[0]->{EXTRA_INFO}=[];
	}
	push @{$_[0]->{EXTRA_INFO}},$_[1];
}

1;