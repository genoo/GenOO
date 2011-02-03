package Transcript;

# This object describes a gene transcript.

use warnings;
use strict;

use Switch;
use Scalar::Util qw/weaken/;

use _Initializable;
use DBconnector;
use Gene;
use Transcript::UTR5;
use Transcript::CDS;
use Transcript::UTR3;

our $VERSION = '2.0';

our @ISA = qw( _Initializable);

# HOW TO INITIALIZE THIS OBJECT
# my $transcript = Transcript->new({
# 		     ENSTID         => undef,
# 		     STRAND         => undef,
# 		     CHR            => undef,
# 		     GENE           => undef, # Gene
# 		     UTR5           => undef, # Transcript::UTR5
# 		     CDS            => undef, # Transcript::CDS
# 		     UTR3           => undef, # Transcript::UTR3
# 		     EXTRA_INFO     => undef,
# 		     });

sub _init {
	my ($self,$data) = @_;
	
	$self->set_enstid($$data{ENSTID});
	$self->set_strand($$data{STRAND});
	$self->set_chr($$data{CHR});
	$self->set_gene($$data{GENE}); # Gene
	$self->set_utr5($$data{UTR5}); # Transcript::UTR5
	$self->set_cds($$data{CDS});  # Transcript::CDS
	$self->set_utr3($$data{UTR3}); # Transcript::UTR3
	$self->set_internalID($$data{INTERNAL_ID});
	$self->set_species($$data{SPECIES});
	$self->set_biotype($$data{BIOTYPE});
	$self->set_internalGID($$data{INTERNAL_GID});
	$self->set_extra($$data{EXTRA_INFO});
	$self->set_start($$data{START});
	$self->set_stop($$data{STOP});
	
	my $class = ref($self) || $self;
	$class->_add_to_all($self);
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_enstid {
	return $_[0]->{ENSTID};
}
sub get_strand {
	return $_[0]->{STRAND};
}
sub get_chr {
	return $_[0]->{CHR};
}
sub get_gene {
	return $_[0]->{GENE};
}
sub get_utr5 {
	my ($self) = @_;
	
	unless (defined $self->{UTR5}) {
		$self->set_utr5(Transcript::UTR5->create_new_UTR5_from_database($self));
	}
	return $self->{UTR5};
}
sub get_cds {
	my ($self) = @_;
	
	unless (defined $self->{CDS}) {
		$self->set_cds(Transcript::CDS->create_new_CDS_from_database($self));
	}
	return $self->{CDS};
}
sub get_utr3 {
	my ($self) = @_;
	
	unless (defined $self->{UTR3}) {
		$self->set_utr3(Transcript::UTR3->create_new_UTR3_from_database($self));
	}
	return $self->{UTR3};
}
sub get_start {
	return $_[0]->{START};
}
sub get_stop {
	return $_[0]->{STOP};
}
sub get_extra {
	return $_[0]->{EXTRA_INFO};
}
sub get_internalID {
	return $_[0]->{INTERNAL_ID};
}
sub get_species {
	return $_[0]->{SPECIES};
}
sub get_biotype {
	return $_[0]->{BIOTYPE};
}
sub get_internalGID {
	return $_[0]->{INTERNAL_GID};
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_enstid {
	my ($self,$value) = @_;
	if (defined $value) {
		$value =~ s/>//;
		$self->{ENSTID} = $value;
	}
}
sub set_strand {
	my ($self,$value) = @_;
	if (defined $value) {
		$value =~ s/^\+$/1/;
		$value =~ s/^\-$/-1/;
		$self->{STRAND} = $value;
	}
}
sub set_chr {
	my ($self,$value) = @_;
	if (defined $value) {
		$value =~ s/>*chr//;
		$self->{CHR} = $value;
	}
}
sub set_gene {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{GENE} = $value;
		weaken($self->{GENE}); # circular reference needs to be weakened to avoid memory leaks
	}
}
sub set_utr5 {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{UTR5} = $value;
	}
	else {
		$self->{UTR5} = Transcript::UTR5->new( {TRANSCRIPT => $self} );
	}
}
sub set_cds {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{CDS} = $value;
	}
	else {
		$self->{CDS} = Transcript::CDS->new( {TRANSCRIPT => $self} );
	}
}
sub set_utr3 {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{UTR3} = $value;
	}
	else {
		$self->{UTR3} = Transcript::UTR3->new( {TRANSCRIPT => $self} );
	}
}
sub set_start {
	$_[0]->{START} = $_[1] if defined $_[1];
}
sub set_stop {
	$_[0]->{STOP} = $_[1] if defined $_[1];
}
sub set_extra {
	$_[0]->{EXTRA_INFO} = $_[1] if defined $_[1];
}
sub set_internalID {
	$_[0]->{INTERNAL_ID} = $_[1] if defined $_[1];
}
sub set_species {
	$_[0]->{SPECIES} = uc($_[1]) if defined $_[1];
}
sub set_biotype {
	$_[0]->{BIOTYPE} = $_[1] if defined $_[1];
}
sub set_internalGID {
	$_[0]->{INTERNAL_GID} = $_[1] if defined $_[1];
}

#######################################################################
#########################   General Methods   #########################
#######################################################################

#######################################################################
##########################   Class Methods   ##########################
#######################################################################
{
	my %allTranscripts;
	
	sub _add_to_all {
		my ($class,$obj) = @_;
		$allTranscripts{$obj->get_enstid} = $obj;
	}
	
	sub _delete_from_all {
		my ($class,$obj) = @_;
		delete $allTranscripts{$obj->get_enstid};
	}
	
	sub get_all {
		my ($class) = @_;
		return %allTranscripts;
	}
	
	sub delete_all {
		my ($class) = @_;
		%allTranscripts = ();
	}
	
	sub get_by_enstid {
		my ($class,$enstid) = @_;
		if (exists $allTranscripts{$enstid}) {
			return $allTranscripts{$enstid};
		}
		else {
			return $class->create_new_transcript_from_database($enstid);
		}
	}
	
	sub read_transcripts {
		my ($class,$method,@attributes) = @_;
		
		if ($method eq "FILE") {
			my $filename = $attributes[0];
			return $class->_read_file_with_transcripts($filename);
		}
	}
	
	sub _read_file_with_transcripts {
		my ($class,$file)=@_;
		
		my $transcript;
		my $species;
		open (my $IN,"<",$file) or die "Cannot open file $file: $!";
		while (my $line=<$IN>){
			chomp($line);
			if (substr($line,0,1) ne '#') {
				my ($ensgid,$enstid,$chr,$strand,$start,$stop,$biotype) = split(/\t/,$line);
				
				# Search if the gene has already been defined. If not create it
				my $geneObj = Gene->get_by_ensgid($ensgid);
				unless ($geneObj) {
					$geneObj = Gene->new({
								ENSGID   => $ensgid,
								});
				}
				
				$transcript = $class->get_by_enstid($enstid);
				if ($transcript) {
					unless (defined $transcript->get_enstid)  {$transcript->set_enstid($enstid);}
					unless (defined $transcript->get_species) {$transcript->set_species($species);}
					unless (defined $transcript->get_strand)  {$transcript->set_strand($strand);}
					unless (defined $transcript->get_chr)     {$transcript->set_chr($chr);}
					unless (defined $transcript->get_start)   {$transcript->set_start($start);}
					unless (defined $transcript->get_stop)    {$transcript->set_stop($stop);}
					unless (defined $transcript->get_biotype) {$transcript->set_biotype($biotype);}
					unless (defined $transcript->get_gene)    {$transcript->set_gene($geneObj);}
					
				}
				else {
					$transcript = $class->new({
								ENSTID           => $enstid,
								SPECIES          => $species,
								STRAND           => $strand,
								CHR              => $chr,
								START            => $start,
								STOP             => $stop,
								BIOTYPE          => $biotype,
								GENE             => $geneObj,
								});
				}
			}
			elsif (substr($line,0,1) eq '#') {
				$line =~ /species="(.+)"/;
				$species = $1;
			}
		}
		close $IN;
		
		return %allTranscripts;
	}
	
	sub read_region_info_for_transcripts {
		my ($class,$method,@attributes) = @_;
		
		if ($method eq "FILE") {
			my $filename = $attributes[0];
			return $class->_read_file_with_region_info_for_transcripts($filename);
		}
	}
	
	sub _read_file_with_region_info_for_transcripts {
		my ($class,$file)=@_;
		
		my $transcript;
		open (my $FASTA,"<",$file) or die "Cannot open file $file: $!";
		while (my $line=<$FASTA>){
			chomp($line);
			if (substr($line,0,1) eq '>') {
				$line = substr($line,1);
				my ($enstid,$strand,$chr,$ensgid,$species) = split(/\|/,$line);
				
				# Search if the gene has already been defined. If not create it
				my $geneObj = Gene->get_by_ensgid($ensgid);
				unless ($geneObj) {
					$geneObj = Gene->new({
								ENSGID   => $ensgid,
								});
				}
				
				$transcript = $class->get_by_enstid($enstid);
				if ($transcript) {
					unless (defined $transcript->get_strand)  {$transcript->set_strand($strand);}
					unless (defined $transcript->get_chr)     {$transcript->set_chr($chr);}
					unless (defined $transcript->get_gene)    {$transcript->set_gene($geneObj);}
					unless (defined $transcript->get_species) {$transcript->set_species($species);}
				}
				else {
					$transcript = $class->new({
								ENSTID           => $enstid,
								STRAND           => $strand,
								CHR              => $chr,
								SPECIES          => $species,
								GENE             => $geneObj,
								});
				}
			}
			elsif (substr($line,0,4) eq 'UTR5') {
				my ($what,$splice_starts,$splice_stops,$sequence,$accessibility) = split(/\t/,$line);
				my $utr5Obj = Transcript::UTR5->new({
									TRANSCRIPT       => $transcript,
									SPLICE_STARTS    => $splice_starts,
									SPLICE_STOPS     => $splice_stops,
									SEQUENCE         => $sequence,
									ACCESSIBILITY    => $accessibility,
									});
				$transcript->set_utr5($utr5Obj);
			}
			elsif (substr($line,0,3) eq 'CDS') {
				my ($what,$splice_starts,$splice_stops,$sequence,$accessibility) = split(/\t/,$line);
				my $cdsObj = Transcript::CDS->new({
									TRANSCRIPT       => $transcript,
									SPLICE_STARTS    => $splice_starts,
									SPLICE_STOPS     => $splice_stops,
									SEQUENCE         => $sequence,
									ACCESSIBILITY    => $accessibility,
									});
				$transcript->set_cds($cdsObj);
			}
			elsif (substr($line,0,4) eq 'UTR3') {
				my ($what,$splice_starts,$splice_stops,$sequence,$accessibility) = split(/\t/,$line);
				my $utr3Obj = Transcript::UTR3->new({
									TRANSCRIPT       => $transcript,
									SPLICE_STARTS    => $splice_starts,
									SPLICE_STOPS     => $splice_stops,
									SEQUENCE         => $sequence,
									ACCESSIBILITY    => $accessibility,
									});
				$transcript->set_utr3($utr3Obj);
			}
		}
		close $FASTA;
		
		return %allTranscripts;
	}
	
	sub update_transcripts_with_accessibility {
		my ($class,$method,@attributes) = @_;
		
		if ($method eq "FILE") {
			my $filename = $attributes[0];
			$class->_read_accessibility_from_fasta_file_and_update_transcript_objects($filename);
		}
	}
	
	sub _read_accessibility_from_fasta_file_and_update_transcript_objects {
		my ($class,$file)=@_;
		
		my $transcript;
		open (my $FASTA,"<",$file) or die "Cannot open file $file: $!";
		while (my $line=<$FASTA>) {
			chomp($line);
			if (substr($line,0,1) eq '>') {
				my $enstid = substr($line,1);
				$transcript = $class->get_by_enstid($enstid);
			}
			elsif (substr($line,0,4) eq 'UTR5') {
				my ($what,$accessibility) = split(/\t/,$line);
				$transcript->get_utr5->set_accessibility($accessibility);
			}
			elsif (substr($line,0,3) eq 'CDS') {
				my ($what,$accessibility) = split(/\t/,$line);
				$transcript->get_cds->set_accessibility($accessibility);
			}
			elsif (substr($line,0,4) eq 'UTR3') {
				my ($what,$accessibility) = split(/\t/,$line);
				$transcript->get_utr3->set_accessibility($accessibility);
			}
		}
		close $FASTA;
	}
	
	sub read_transcript_internal_IDs {
		my ($class,$method,@attributes) = @_;
		
		if ($method eq "FILE") {
			my $filename = $attributes[0];
			return $class->_read_transcript_internal_IDs_from_file($filename);
		}
	}
	
	sub _read_transcript_internal_IDs_from_file {
		my ($class,$file) = @_;
		
		open (my $IDS,"<",$file) or die "Cannot open file $file: $!";
		while (my $line=<$IDS>){
			chomp($line);
			my ($internalID,$enstid,$ensgid) = split(/\|/,$line);
			my $transcript = $class->get_by_enstid($enstid);
			if (defined $transcript) {
				$transcript->set_internalID($internalID);
			}
		}
		close ($IDS);
	}
	
	########################################## database ##########################################
	my $DBconnector;
	my $allowDatabaseAccess;
	my $select_all_from_transcripts_where_enstid;
	my $select_all_from_transcripts_where_enstid_Query = qq/SELECT * FROM diana_transcripts WHERE diana_transcripts.enstid=?/;
	
	sub allow_database_access {
		$allowDatabaseAccess = 1;
	}
	
	sub deny_database_access {
		$allowDatabaseAccess = 0;
	}
	
	sub get_global_DBconnector {
		my ($class) = @_;
		$class = ref($class) || $class;
		
		if (!defined $DBconnector) {
			while (!defined $allowDatabaseAccess) {
				print STDERR 'Would you like to enable database access to retrieve Transcript data? (y/n) [y]';
				my $userChoice = <>;
				chomp ($userChoice);
				switch ($userChoice) {
					case ''     {$allowDatabaseAccess = 1;}
					case 'y'    {$allowDatabaseAccess = 1;}
					case 'n'    {$allowDatabaseAccess = 0;}
					else        {print STDERR 'Choice not recognised. Please specify (y/n)'."\n";}
				}
			}
			if ($allowDatabaseAccess) {
				if (DBconnector->exists("core")) {
					$DBconnector = DBconnector->get_dbconnector("core");
				}
				else {
					print STDERR "\nRequesting database connector with name \"transcript\"\n";
					$DBconnector = DBconnector->get_dbconnector("transcript");
				}
			}
		}
		return $DBconnector;
	}
	
	sub create_new_transcript_from_database {
		my ($class,$enstid) = @_;
		
		my $DBconnector = $class->get_global_DBconnector();
		if (defined $DBconnector) {
			my $dbh = $DBconnector->get_handle();
			unless (defined $select_all_from_transcripts_where_enstid) {
				$select_all_from_transcripts_where_enstid = $dbh->prepare($select_all_from_transcripts_where_enstid_Query);
			}
			$select_all_from_transcripts_where_enstid->execute($enstid);
			my $fetch_hash_ref = $select_all_from_transcripts_where_enstid->fetchrow_hashref;
			$select_all_from_transcripts_where_enstid->finish(); # there should be only one result so I have to indicate that fetching is over
			
			if (defined $$fetch_hash_ref{internal_tid}) {
				my $transcript = $class->new({
							   INTERNAL_ID      => $$fetch_hash_ref{internal_tid},
							   INTERNAL_GID     => $$fetch_hash_ref{internal_gid},
							   ENSTID           => $$fetch_hash_ref{enstid},
							   SPECIES          => $$fetch_hash_ref{species},
							   STRAND           => $$fetch_hash_ref{strand},
							   CHR              => $$fetch_hash_ref{chromosome},
							   START            => $$fetch_hash_ref{start},
							   STOP             => $$fetch_hash_ref{stop},
							   BIOTYPE          => $$fetch_hash_ref{biotype},
							});
				return $transcript;
			}
			else {
				warn "Transcript \"$enstid\" could not be found in database. Please check that the transcript already exists\n";
				return undef;
			}
			
		}
	}
	
}

1;