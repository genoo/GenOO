package MyBio::Transcript::UTR3;

# Corresponds to the 3'UTR of a gene transcript. It inherits all the attributes and methods of the class MyBio::Transcript::Region.

use strict;

our $VERSION = '2.0';

use base qw(MyBio::Transcript::Region);

# HOW TO CREATE THIS OBJECT
# my $utr3Obj = Transcript::UTR3->new({
# 		     TRANSCRIPT       => undef,
# 		     SPLICE_STARTS    => undef,
# 		     SPLICE_STOPS     => undef,
# 		     LENGTH           => undef,
# 		     SEQUENCE         => undef,
# 		     ACCESSIBILITY    => undef,
# 		     CONSERVATION     => undef,
# 		     EXTRA_INFO       => undef,
# 		     });

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	$self->set_conservation($$data{CONSERVATION});
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_conservation {
	return $_[0]->{CONSERVATION};
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_conservation {
	$_[0]->{CONSERVATION} = $_[1] if defined $_[1];
}

#######################################################################
#############################   General   #############################
#######################################################################
sub whatami {
	return 'UTR3';
}

#######################################################################
##########################   Class Methods   ##########################
#######################################################################
{
	sub read_conservation_profiles {
		my ($class,$method,@attributes) = @_;
		
		if ($method eq "FILE") {
			my $filename = $attributes[0];
			$class->_read_conservation_profiles_from_file($filename);
		}
	}
	
	sub _read_conservation_profiles_from_file {
		my ($class,$filename)=@_;
		
		open (PROFILE,$filename) or die "cannot open file $filename $!";
		while (my $line=<PROFILE>) {
			chomp $line;
			my ($enstid,$cons_profile) = split(/\t/,$line);
			my $transcript = MyBio::Transcript->get_by_enstid($enstid);
			if (defined $transcript) {
				$transcript->get_utr3->set_conservation($cons_profile);
			}
		}
		close PROFILE;
	}
	
	########################################## database ##########################################
	my $select_region_info_from_transcripts_where_internal_tid;
	my $select_region_info_from_transcripts_where_internal_tid_Query = qq/SELECT UTR3_start,UTR3_stop,UTR3_seq FROM diana_transcripts WHERE diana_transcripts.internal_tid=?/;
	
	sub create_new_UTR3_from_database {
		my ($class,$transcript) = @_;
		
		my $internal_tid = $transcript->get_internalID();
		my $DBconnector = $class->get_global_DBconnector();
		if (defined $DBconnector) {
			my $dbh = $DBconnector->get_handle();
			unless (defined $select_region_info_from_transcripts_where_internal_tid) {
				$select_region_info_from_transcripts_where_internal_tid = $dbh->prepare($select_region_info_from_transcripts_where_internal_tid_Query);
			}
			$select_region_info_from_transcripts_where_internal_tid->execute($internal_tid);
			my $fetch_hash_ref = $select_region_info_from_transcripts_where_internal_tid->fetchrow_hashref;
			$select_region_info_from_transcripts_where_internal_tid->finish(); # there should be only one result so I have to indicate that fetching is over
			
			my $utr3Obj = MyBio::Transcript::UTR3->new({
								TRANSCRIPT       => $transcript,
								SPLICE_STARTS    => $$fetch_hash_ref{UTR3_start},
								SPLICE_STOPS     => $$fetch_hash_ref{UTR3_stop},
								SEQUENCE         => $$fetch_hash_ref{UTR3_seq},
								});
			
			return $utr3Obj;
		}
		else {
			return undef;
		}
	}
}

#######################################################################
##########################   Class Methods   ##########################
#######################################################################


1;