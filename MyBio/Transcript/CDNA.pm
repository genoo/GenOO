package MyBio::Transcript::CDNA;

# Corresponds to the whole region of a gene transcript. It inherits all the attributes and methods of the class Transcript::Region.

use strict;

use MyBio::_Initializable;
use MyBio::Transcript::Region;

our $VERSION = '2.0';

our @ISA = qw(MyBio::Transcript::Region);

# HOW TO CREATE THIS OBJECT
# my $cdnaObj = Transcript::CDNA->new({
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

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_conservation {
	$_[0]->{CONSERVATION} = $_[1] if defined $_[1];
}

#######################################################################
##########################   Class Methods   ##########################
#######################################################################
{
	########################################## database ##########################################
	my $select_region_info_from_transcripts_where_internal_tid;
	my $select_region_info_from_transcripts_where_internal_tid_Query = qq/SELECT CDNA_start,CDNA_stop,CDNA_seq FROM diana_transcripts WHERE diana_transcripts.internal_tid=?/;
	
	sub create_new_CDNA_from_database {
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
			
			my $cdnaObj = MyBio::Transcript::CDNA->new({
								TRANSCRIPT       => $transcript,
								SPLICE_STARTS    => $$fetch_hash_ref{CDNA_start},
								SPLICE_STOPS     => $$fetch_hash_ref{CDNA_stop},
								SEQUENCE         => $$fetch_hash_ref{CDNA_seq},
								});
			
			return $cdnaObj;
		}
		else {
			return undef;
		}
	}
}


1;