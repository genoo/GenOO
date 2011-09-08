package MyBio::Transcript::CDS;

# Corresponds to the CDS of a gene transcript. It inherits all the attributes and methods of the class Transcript::Region.

use strict;

our $VERSION = '2.0';

use base qw(MyBio::Transcript::Region);

# HOW TO CREATE THIS OBJECT
# my $cdsObj = Transcript::CDS->new({
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
sub get_cds_start_locus {
#this will return the coding start nucleotide not the "start"/ ie it will be strand specific!
	my $self = $_[0];
	my $start;
	if ($self->get_strand == 1){$start = $self->get_start;}
	elsif ($self->get_strand == -1){$start = $self->get_stop;}
	else {return undef;}
	my $cdsstart = MyBio::Locus->new({
				STRAND       => $self->get_strand,
				CHR          => $self->get_chr,
				START        => $start,
				STOP         => $start,
	});
	
}
#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_conservation { $_[0]->{CONSERVATION} = $_[1] if defined $_[1];}

#######################################################################
#############################   General   #############################
#######################################################################
sub whatami {
	return 'CDS';
}

#######################################################################
##########################   Class Methods   ##########################
#######################################################################
{
	########################################## database ##########################################
	my $select_region_info_from_transcripts_where_internal_tid;
	my $select_region_info_from_transcripts_where_internal_tid_Query = qq/SELECT CDS_start,CDS_stop,CDS_seq FROM diana_transcripts WHERE diana_transcripts.internal_tid=?/;
	
	sub create_new_CDS_from_database {
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
			
			my $cdsObj = Transcript::CDS->new({
								TRANSCRIPT       => $transcript,
								SPLICE_STARTS    => $$fetch_hash_ref{CDS_start},
								SPLICE_STOPS     => $$fetch_hash_ref{CDS_stop},
								SEQUENCE         => $$fetch_hash_ref{CDS_seq},
								});
			
			return $cdsObj;
		}
		else {
			return undef;
		}
	}
}


1;