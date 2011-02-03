package Target::MockInteraction;

use warnings;
use strict;

use Target::Interaction;
use _Initializable;

our $VERSION = '1.0';

our @ISA = qw( _Initializable Target::Interaction);

# HOW TO INITIALIZE THIS OBJECT
# my $interactionObj = Target::Interaction->new({
# 		     UTR3           => undef, #Gene::UTR3
# 		     MIRNA          => undef, #Mirna::Mimat
# 		     MRES           => [],
# 		     SCORE          => undef,
# 		     SNR            => undef,
# 		     PRECISION      => undef,
# 		     EXTRA_INFO     => undef,
# 		     });


#######################################################################
##########################   Class Methods   ##########################
#######################################################################
{
	my %allInteractions;
	
	sub _add_to_all_interactions {
		my ($class,$obj) = @_;
		$allInteractions{$obj->get_mirna()->get_name()}{$obj->get_utr()->get_ensgid()} = $obj;
	}
	
	sub _delete_from_all_interactions {
		my ($class,$obj) = @_;
		delete $allInteractions{$obj->get_mirna()->get_name()}{$obj->get_utr()->get_ensgid()};
	}
	
	sub get_all_interactions {
		my ($class) = @_;
		return %allInteractions;
	}
	
	sub read_fasta_file_to_hash_of_interaction_objects {
		my ($class,$file,$mirnaObj)=@_;
		
		my $interactionObj;
		my %allUTR3Objs = Gene::UTR3->get_all_UTR3Objs();
		
		if ($file =~ /\.gz$/) { open (FASTA,"<:gzip",$file) or die "Cannot open file $file: $!";}
		else                  { open (FASTA,$file) or die "Cannot open file $file: $!";}
		while (my $line=<FASTA>){
			chomp($line);
			if (substr($line,0,1) eq '>') {
				my ($chr,$ensg,$name,$strand,$splice_starts,$splice_stops,$enst,$conservation,$score,$precision,$snr,@extra)=split(/\|/,$line);
				
				my $utrObj;
				if (exists $allUTR3Objs{$enst}) {
					$utrObj = $allUTR3Objs{$enst};
					$utrObj->set_conservation($conservation);
				}
				else {
					$utrObj = Gene::UTR3->new({
								      CHR              => $chr,
								      ENSTID           => $enst,
								      ENSGID           => $ensg,
								      COMMON_NAME      => $name,
								      REFSEQ           => undef,
								      STRAND           => $strand,
								      SPLICE_STARTS    => $splice_starts,
								      SPLICE_STOPS     => $splice_stops,
								      CONSERVATION     => $conservation,
								      LENGTH           => undef,
								      EXTRA_INFO       => join('|',@extra),
								      });
				}
				
				$interactionObj = $class->new({
							UTR3           => $utrObj,
							MIRNA          => $mirnaObj,
							MRES           => [],
							SCORE          => $score,
							SNR            => $snr,
							PRECISION      => $precision,
							EXTRA_INFO     => undef,
							});
				$class->_add_to_all_interactions($interactionObj);
			}
			elsif (substr($line,0,1) ne "#") {
				my ($miRNA,$seedStart,$seedStop,$dif1,$dif2,$categoryNum,$first_binding_nt,$MRE_start,$MRE_stop,$bindingVector,$RNAhybrid,$NA,$NA2,$energyPercentage,$conservationVector,$access_r1,$access_r2,$access_r3,$access_r4) = split(/\|/,$line);
				
				my $mreObj=Target::MRE->new({
						UTR3              => $interactionObj->get_utr(),
						MIRNA             => $mirnaObj,
						CATEG             => $categoryNum,
						MRE_UTR3_START    => $MRE_start,
						MRE_UTR3_STOP     => $MRE_stop,
						DRIVER_UTR3_START => $seedStart,
						DRIVER_UTR3_STOP  => $seedStop,
						DIF1              => $dif1,
						DIF2              => $dif2,
						FIRST_BINDING     => $first_binding_nt,
						BINDING_VECTOR    => $bindingVector,
						RNAHYBRID         => $RNAhybrid,
						ENERGY_PERCENTAGE => $energyPercentage,
						CONS_VECTOR       => $conservationVector,
						ACCESSIBILITY1    => $access_r1,
						ACCESSIBILITY2    => $access_r2,
						ACCESSIBILITY3    => $access_r3,
						ACCESSIBILITY4    => $access_r4,
						MRE_SCORE         => undef,
						EXTRA_INFO        => $line,
						});
				$interactionObj->push_mre($mreObj);
			}
		}
		close FASTA;
		
		return %allInteractions;
	}
}

1;