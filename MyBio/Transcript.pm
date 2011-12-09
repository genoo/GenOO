# POD documentation - main docs before the code

=head1 NAME

MyBio::Transcript - Transcript object, with features

=head1 SYNOPSIS

    # This is the main transcript object
    # It represents a transcript of a gene
    
    # To initialize 
    my $transcript = MyBio::Transcript->new({
        ENSTID         => undef,
        SPECIES        => undef,
        STRAND         => undef,
        CHR            => undef,
        GENE           => undef, # MyBio::Gene
        UTR5           => undef, # MyBio::Transcript::UTR5
        CDS            => undef, # MyBio::Transcript::CDS
        UTR3           => undef, # MyBio::Transcript::UTR3
        CDNA           => undef, # MyBio::Transcript::CDNA
        BIOTYPE        => undef,
        INTERNAL_ID    => undef,
        INTERNAL_GID   => undef,
        START          => undef,
        STOP           => undef,
        EXTRA_INFO     => undef,
    });

=head1 DESCRIPTION

    Not provided yet

=head1 EXAMPLES

    my %transcripts = MyBio::Transcript->read_region_info_for_transcripts('FILE',"$database/Ensembl_release_54/CDS_and_3UTR_sequences_CLEAN.txt");

=head1 AUTHOR - Manolis Maragkakis, Panagiotis Alexiou

Email maragkakis@fleming.gr, pan.alexiou@fleming.gr

=cut

# Let the code begin...

package MyBio::Transcript;
use strict;

use Scalar::Util qw/weaken/;
use MyBio::DBconnector;
use MyBio::Gene;
use MyBio::Transcript::UTR5;
use MyBio::Transcript::CDS;
use MyBio::Transcript::UTR3;
use MyBio::Transcript::Exon;
use MyBio::Transcript::CDNA;

use base qw(MyBio::Locus);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	$self->set_enstid($$data{ENSTID});
	$self->set_gene($$data{GENE}); # MyBio::Gene
	$self->set_utr5($$data{UTR5}); # MyBio::Transcript::UTR5
	$self->set_cds($$data{CDS});   # MyBio::Transcript::CDS
	$self->set_utr3($$data{UTR3}); # MyBio::Transcript::UTR3
	$self->set_cdna($$data{CDNA}); # MyBio::Transcript::CDNA
	$self->set_internalID($$data{INTERNAL_ID});
	$self->set_biotype($$data{BIOTYPE});
	$self->set_internalGID($$data{INTERNAL_GID});
	$self->set_extra($$data{EXTRA_INFO});
	
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
sub get_gene {
	return $_[0]->{GENE};
}
sub get_utr5 {
	my ($self) = @_;
	
	unless (defined $self->{UTR5}) {
		$self->set_utr5(MyBio::Transcript::UTR5->create_new_UTR5_from_database($self));
	}
	return $self->{UTR5};
}
sub get_cds {
	my ($self) = @_;
	
	unless (defined $self->{CDS}) {
		$self->set_cds(MyBio::Transcript::CDS->create_new_CDS_from_database($self));
	}
	return $self->{CDS};
}
sub get_cdna {
	my ($self) = @_;
	return $self->{CDNA};
}
sub get_utr3 {
	my ($self) = @_;
	
	unless (defined $self->{UTR3}) {
		$self->set_utr3(MyBio::Transcript::UTR3->create_new_UTR3_from_database($self));
	}
	return $self->{UTR3};
}
sub get_extra {
	return $_[0]->{EXTRA_INFO};
}
sub get_internalID {
	return $_[0]->{INTERNAL_ID};
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
		$self->{UTR5} = MyBio::Transcript::UTR5->new( {TRANSCRIPT => $self} );
	}
}
sub set_cds {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{CDS} = $value;
	}
	else {
		$self->{CDS} = MyBio::Transcript::CDS->new( {TRANSCRIPT => $self} );
	}
}
sub set_cdna {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{CDNA} = $value;
	}
	else {
		$self->{CDNA} = MyBio::Transcript::CDNA->new( {TRANSCRIPT => $self} );
	}
}
sub set_utr3 {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{UTR3} = $value;
	}
	else {
		$self->{UTR3} = MyBio::Transcript::UTR3->new( {TRANSCRIPT => $self} );
	}
}
sub set_extra {
	$_[0]->{EXTRA_INFO} = $_[1] if defined $_[1];
}
sub set_internalID {
	$_[0]->{INTERNAL_ID} = $_[1] if defined $_[1];
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

=head2 get_by_enstid

  Arg [1]    : string $enstid
               The primary id of the transcript.
  Example    : MyBio::Transcript->get_by_enstid;
  Description: Class method that returns the object which corresponds to the provided primary transcript id.
               If no object is found, then depending on the database access policy the method either attempts
               to create a new object or returns NULL
  Returntype : MyBio::Transcript / NULL
  Caller     : ?
  Status     : Stable

=cut
	sub get_by_enstid {
		my ($class,$enstid) = @_;
		if (exists $allTranscripts{$enstid}) {
			return $allTranscripts{$enstid};
		}
		elsif ($class->database_access eq 'ALLOW') {
			return $class->create_new_transcript_from_database($enstid);
		}
		else {
			return;
		}
	}
	
	sub read_transcripts {
		my ($class,$method,@attributes) = @_;
		
		if ($method eq "FILE") {
			my $filename = $attributes[0];
			return $class->_read_file_with_transcripts($filename);
		}
		if ($method eq "GTF") {
			my $filename = $attributes[0];
			return $class->_read_gtf_with_transcripts($filename);
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
				my $geneObj = MyBio::Gene->get_by_ensgid($ensgid);
				unless ($geneObj) {
					$geneObj = MyBio::Gene->new({
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
	sub _read_gtf_with_transcripts {
		my ($class,$file)=@_;
		
		my %allexons;
		my %coding_start;
		my %coding_stop;
		my %t_start;
		my %t_stop;
		my %ensg;
		open (my $IN,"<",$file) or die "Cannot open file $file: $!";
		while (my $line=<$IN>){
			chomp($line);
			if (substr($line,0,1) ne '#') {
				if ($line eq ""){next;}
				if ($line =~ /^\s*$/){next;}
				my ($chr, $genome, $type, $start, $stop, $score, $strand, undef, $nameinfo) = split(/\t/, $line);
				$start = $start-1; #GTF is one based closed => convert to 0-based closed.
				$stop = $stop-1;
				
				$nameinfo =~ /gene_id\s+\"(.+)\"\;\s+transcript_id\s+\"(.+)\"/;
				my $ensgid = $1;
				my $enstid = $2;
				
				$ensg{$enstid} = $ensgid; 
				
				my $exon = MyBio::Transcript::Exon->new({
				     SPECIES      => undef,
				     STRAND       => $strand,
				     CHR          => $chr,
				     START        => $start,
				     STOP         => $stop,
				     SEQUENCE     => undef,
				     WHERE        => undef,
				     EXTRA_INFO   => $type,
				});
				
				if ((!defined $t_start{$enstid}) or ($start < $t_start{$enstid})){$t_start{$enstid} = $start;}
				if ((!defined $t_stop{$enstid}) or ($stop > $t_stop{$enstid})){$t_stop{$enstid} = $stop;}
				
				if ($type eq "start_codon") {
					if ($strand eq "+"){$coding_start{$enstid} = $start;}
					elsif ($strand eq "-"){$coding_stop{$enstid} = $stop;}
					else {warn "unknown strand $strand\n"; next;}
				}
				elsif ($type eq "stop_codon") {
					if ($strand eq "+"){$coding_stop{$enstid} = $stop;}
					elsif ($strand eq "-"){$coding_start{$enstid} = $start;}
					else {warn "unknown strand $strand\n"; next;}
				}
				elsif ($type eq "CDS"){next;}				
				else {
					push @{$allexons{$enstid}}, $exon;
				}
			}
		}
		close $IN;
		
		foreach my $enstid (keys %allexons)
		{
			my $chr = ${$allexons{$enstid}}[0]->get_chr;
			my $strand = ${$allexons{$enstid}}[0]->get_strand;
			
		
			my $ensgid = $ensg{$enstid};
			# Search if the gene has already been defined. If not create it
			my $geneObj = MyBio::Gene->get_by_ensgid($ensgid);
			unless ($geneObj) {
				$geneObj = MyBio::Gene->new({
					ENSGID   => $ensgid,
				});
			}
			
			# Search if the transcript has already been defined. If not create it
			my $transcriptObj = $class->get_by_enstid($ensgid);
			unless ($transcriptObj) {
				$transcriptObj = $class->new({
					ENSTID   => $enstid,
					GENE     => $geneObj,
					CHR      => $chr,
					STRAND   => $strand,
					START    => $t_start{$enstid},
					STOP     => $t_stop{$enstid}
				});
			}
						
			foreach my $exon (@{$allexons{$enstid}})
			{
				$exon->set_extra("from_file");
				$transcriptObj->get_cdna->push_exon($exon);
			}
			
			$transcriptObj->get_cdna->set_chr($transcriptObj->get_chr);
			$transcriptObj->get_cdna->set_strand($transcriptObj->get_strand);
			$transcriptObj->get_cdna->set_start($transcriptObj->get_start);
			$transcriptObj->get_cdna->set_stop($transcriptObj->get_stop);
			
			if ((!exists $coding_start{$enstid}) and (!exists $coding_stop{$enstid})){$transcriptObj->set_biotype("non coding");}
			else 
			{
				if ($transcriptObj->get_strand == 1){
					$transcriptObj->get_utr5->set_start($transcriptObj->get_start);
					$transcriptObj->get_utr5->set_stop($coding_start{$enstid}-1);
					$transcriptObj->get_cds->set_start($coding_start{$enstid});
					$transcriptObj->get_cds->set_stop($coding_stop{$enstid});
					$transcriptObj->get_utr3->set_start($coding_stop{$enstid}+1);
					$transcriptObj->get_utr3->set_stop($transcriptObj->get_stop);
				}
				elsif ($transcriptObj->get_strand == -1){
					$transcriptObj->get_utr5->set_start($coding_stop{$enstid}+1);
					$transcriptObj->get_utr5->set_stop($transcriptObj->get_stop);
					$transcriptObj->get_cds->set_start($coding_start{$enstid});
					$transcriptObj->get_cds->set_stop($coding_stop{$enstid});
					$transcriptObj->get_utr3->set_start($transcriptObj->get_start);
					$transcriptObj->get_utr3->set_stop($coding_start{$enstid}-1);
				}
				
				$transcriptObj->get_utr5->set_chr($transcriptObj->get_chr);
				$transcriptObj->get_utr3->set_chr($transcriptObj->get_chr);
				$transcriptObj->get_cds->set_chr($transcriptObj->get_chr);
				
				$transcriptObj->get_utr5->set_strand($transcriptObj->get_strand);
				$transcriptObj->get_utr3->set_strand($transcriptObj->get_strand);
				$transcriptObj->get_cds->set_strand($transcriptObj->get_strand);
				
				$transcriptObj->set_biotype("coding");
			}
			
		}
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
				my $geneObj = MyBio::Gene->get_by_ensgid($ensgid);
				unless ($geneObj) {
					$geneObj = MyBio::Gene->new({
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
				my $utr5Obj = MyBio::Transcript::UTR5->new({
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
				my $cdsObj = MyBio::Transcript::CDS->new({
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
				my $utr3Obj = MyBio::Transcript::UTR3->new({
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
	my $accessPolicy = MyBio::DBconnector->global_access();
	my $select_all_from_transcripts_where_enstid;
	my $select_all_from_transcripts_where_enstid_Query = qq/SELECT * FROM diana_transcripts WHERE diana_transcripts.enstid=?/;
	
	sub allow_database_access {
		$accessPolicy = 'ALLOW';
	}
	
	sub deny_database_access {
		$accessPolicy = 'DENY';
	}
	
	sub database_access {
		my ($class) = @_;
		
		while (!defined $accessPolicy) {
			print STDERR "Would you like to enable database access to retrieve data for class $class? (y/n) [n]";
			my $userChoice = <>;
			chomp ($userChoice);
			if    ($userChoice eq '')  {$class->deny_database_access;}
			elsif ($userChoice eq 'y') {$class->allow_database_access;}
			elsif ($userChoice eq 'n') {$class->deny_database_access;}
			else {print STDERR 'Choice not recognised. Please specify (y/n)'."\n";}
		}
		
		return $accessPolicy;
	}
	
	sub get_db_connector {
		my ($class) = @_;
		$class = ref($class) || $class;
		
		if (!defined $DBconnector) {
			while (!defined $accessPolicy) {
				print STDERR "Would you like to enable database access to retrieve data for class $class? (y/n) [n]";
				my $userChoice = <>;
				chomp ($userChoice);
				if    ($userChoice eq '')  {$class->deny_database_access;}
				elsif ($userChoice eq 'y') {$class->allow_database_access;}
				elsif ($userChoice eq 'n') {$class->deny_database_access;}
				else {print STDERR 'Choice not recognised. Please specify (y/n)'."\n";}
			}
			if ($accessPolicy eq 'ALLOW') {
				if (MyBio::DBconnector->exists("core")) {
					$DBconnector = MyBio::DBconnector->get_dbconnector("core");
				}
				else {
					print STDERR "\nRequesting database connector for class $class\n";
					$DBconnector = MyBio::DBconnector->get_dbconnector($class);
				}
			}
		}
		return $DBconnector;
	}
	
	sub create_new_transcript_from_database {
		my ($class,$enstid) = @_;
		
		my $DBconnector = $class->get_db_connector();
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