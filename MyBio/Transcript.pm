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
        START          => undef,
        STOP           => undef,
        GENE           => undef, # MyBio::Gene
        UTR5           => undef, # MyBio::Transcript::UTR5
        CDS            => undef, # MyBio::Transcript::CDS
        UTR3           => undef, # MyBio::Transcript::UTR3
        CDNA           => undef, # MyBio::Transcript::CDNA
        BIOTYPE        => undef,
        INTERNAL_ID    => undef,
        INTERNAL_GID   => undef,
        EXTRA_INFO     => undef,
    });

=head1 DESCRIPTION

    The Transcript class describes a transcript of a gene. It has a backreference back to the gene where it belongs
    and contains functional regions such as 5'UTR, CDS and 3'UTR for protein coding genes. If the gene is not protein
    coding then the CDNA region is set and the above remain undefined. It's up to the user to check if the attributes
    are defined or not. The transcript class inherits the SplicedLocus class so it also describes a genomic region
    where Introns and Exons are defined.

=head1 EXAMPLES

    my %transcripts = MyBio::Transcript->read_region_info_for_transcripts('FILE',"$database/Ensembl_release_54/CDS_and_3UTR_sequences_CLEAN.txt");

=head1 AUTHOR - Manolis Maragkakis, Panagiotis Alexiou

Email em.maragkakis@gmail.com, pan.alexiou@fleming.gr

=cut

# Let the code begin...

package MyBio::Transcript;
use strict;

use Scalar::Util qw/weaken/;
use MyBio::Helper::Locus;
use MyBio::DBconnector;
use MyBio::Gene;
use MyBio::Transcript::CDNA;
use MyBio::Transcript::UTR5;
use MyBio::Transcript::CDS;
use MyBio::Transcript::UTR3;
use MyBio::MySub;

use base qw(MyBio::SplicedLocus);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	$self->set_enstid($$data{ENSTID});
	$self->set_biotype($$data{BIOTYPE});
	$self->set_internalID($$data{INTERNAL_ID});
	$self->set_internalGID($$data{INTERNAL_GID});
	$self->set_coding_start($$data{CODING_START});
	$self->set_coding_stop($$data{CODING_STOP});
	$self->set_gene($$data{GENE}); # MyBio::Gene
	$self->set_cdna($$data{CDNA}); # MyBio::Transcript::CDNA
	$self->set_utr5($$data{UTR5}); # MyBio::Transcript::UTR5
	$self->set_cds($$data{CDS});   # MyBio::Transcript::CDS
	$self->set_utr3($$data{UTR3}); # MyBio::Transcript::UTR3
	
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
sub get_biotype {
	return $_[0]->{BIOTYPE};
}
sub get_internalID {
	return $_[0]->{INTERNAL_ID};
}
sub get_internalGID {
	return $_[0]->{INTERNAL_GID};
}
sub get_coding_start {
	return $_[0]->{CODING_START}
}
sub get_coding_stop {
	return $_[0]->{CODING_STOP}
}
sub get_gene {
	return $_[0]->{GENE};
}
sub get_cdna {
	my ($self) = @_;
	if (defined $self->{CDNA}) {
		return $self->{CDNA};
	}
	else {
		$self->create_cdna();
		return $self->{CDNA};
	}
}
sub get_utr5 {
	my ($self) = @_;
	my $class = ref($self) || $self;
	if (defined $self->{UTR5}) {
		return $self->{UTR5};
	}
	elsif ($self->get_biotype eq 'coding') {
		$self->create_utr5();
		return $self->{UTR5};
	}
	elsif ($class->database_access eq 'ALLOW') {
		$self->set_utr5(MyBio::Transcript::UTR5->create_new_UTR5_from_database($self));
		return $self->{UTR5};
	}
	else {
		return undef;
	}
}
sub get_cds {
	my ($self) = @_;
	my $class = ref($self) || $self;
	if (defined $self->{CDS}) {
		return $self->{CDS};
	}
	elsif ($self->get_biotype eq 'coding') {
		$self->create_cds();
		return $self->{CDS};
	}
	elsif ($class->database_access eq 'ALLOW') {
		$self->set_cds(MyBio::Transcript::CDS->create_new_CDS_from_database($self));
		return $self->{CDS};
	}
	else {
		return undef;
	}
}
sub get_utr3 {
	my ($self) = @_;
	my $class = ref($self) || $self;
	if (defined $self->{UTR3}) {
		return $self->{UTR3};
	}
	elsif ($self->get_biotype eq 'coding') {
		$self->create_utr3();
		return $self->{UTR3};
	}
	elsif ($class->database_access eq 'ALLOW') {
		$self->set_utr3(MyBio::Transcript::UTR3->create_new_UTR3_from_database($self));
		return $self->{UTR3};
	}
	else {
		return undef;
	}
}
#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_enstid {
	my ($self,$value) = @_;
	if (defined $value) {
		$value =~ s/>//;
		$self->{ENSTID} = $value;
		return 0;
	}
	else {
		return 1;
	}
}
sub set_biotype {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{BIOTYPE} = $value;
		return 0;
	}
	else {
		return 1;
	}
}
sub set_internalID {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{INTERNAL_ID} = $value;
		return 0;
	}
	else {
		return 1;
	}
}
sub set_internalGID {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{INTERNAL_GID} = $value;
		return 0;
	}
	else {
		return 1;
	}
}
sub set_coding_start {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{CODING_START} = $value;
		$self->set_biotype('coding');
		return 0;
	}
	else {
		return 1;
	}
}
sub set_coding_stop {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{CODING_STOP} = $value;
		$self->set_biotype('coding');
		return 0;
	}
	else {
		return 1;
	}
}
sub set_gene {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{GENE} = $value;
		weaken($self->{GENE}); # circular reference needs to be weakened to avoid memory leaks
		return 0;
	}
	else {
		return 1;
	}
}
sub set_cdna {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{CDNA} = $value;
		return 0;
	}
	else {
		return 1;
	}
}
sub set_utr5 {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{UTR5} = $value;
		return 0;
	}
	else {
		return 1;
	}
}
sub set_cds {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{CDS} = $value;
		return 0;
	}
	else {
		return 1;
	}
}
sub set_utr3 {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{UTR3} = $value;
		return 0;
	}
	else {
		return 1;
	}
}

#######################################################################
#############################   Methods   #############################
#######################################################################
sub delete {
	my ($self) = @_;
	my $class = ref($self) || $self;
	my $gene_transcripts = $self->get_gene->get_transcripts;
	for (my $i=0;$i<@$gene_transcripts;$i++) {
		if ($self eq $$gene_transcripts[$i]) {
			splice @$gene_transcripts,$i,1;
		}
	}
	$class->_delete_from_all($self);
}
sub is_coding {
	if ($_[0]->get_biotype eq 'coding') {
		return 1;
	}
	else {
		return 0;
	}
}
sub get_exons_split_by_function {
	my ($self) = @_;
	if ($self->is_coding) {
		my @exons;
		if (defined $self->get_utr5) {
			push @exons,@{$self->get_utr5->get_exons};
		}
		if (defined $self->get_cds) {
			push @exons,@{$self->get_cds->get_exons};
		}
		if (defined $self->get_utr3) {
			push @exons,@{$self->get_utr3->get_exons};
		}
		return \@exons;
	}
	else {
		return $self->get_cdna->get_exons;
	} 
}
sub create_cdna {
	my ($self) = @_;
	$self->{CDNA} = MyBio::Transcript::CDNA->new({
		START         => $self->get_start,
		STOP          => $self->get_stop,
		SPLICE_STARTS => $self->get_splice_starts,
		SPLICE_STOPS  => $self->get_splice_stops,
		TRANSCRIPT    => $self
	});
	return 0;
}
sub create_utr5 {
	my ($self) = @_;
	if (defined $self->get_coding_start and defined $self->get_coding_stop) {
		my $utr5_start = ($self->get_strand == 1) ? $self->get_start : $self->get_coding_stop + 1;
		my $utr5_stop = ($self->get_strand == 1) ? $self->get_coding_start - 1 : $self->get_stop;
		$self->{UTR5} = MyBio::Transcript::UTR5->new({
			START      => $utr5_start,
			STOP       => $utr5_stop,
			TRANSCRIPT => $self
		});
		$self->get_utr5->set_splicing_info($self->get_splice_starts,$self->get_splice_stops);
		return 0;
	}
	else {
		return 1;
	}
}
sub create_cds {
	my ($self) = @_;
	if (defined $self->get_coding_start and defined $self->get_coding_stop) {
		$self->{CDS} = MyBio::Transcript::CDS->new({
			START      => $self->get_coding_start,
			STOP       => $self->get_coding_stop,
			TRANSCRIPT => $self
		});
		$self->get_cds->set_splicing_info($self->get_splice_starts,$self->get_splice_stops);
		return 0;
	}
	else {
		return 1;
	}
}
sub create_utr3 {
	my ($self) = @_;
	if (defined $self->get_coding_start and defined $self->get_coding_stop) {
		my $utr3_start = ($self->get_strand == 1) ? $self->get_coding_stop + 1 : $self->get_start;
		my $utr3_stop = ($self->get_strand == 1) ? $self->get_stop : $self->get_coding_start - 1;
		$self->{UTR3} = MyBio::Transcript::UTR3->new({
			START      => $utr3_start,
			STOP       => $utr3_stop,
			TRANSCRIPT => $self
		});
		$self->get_utr3->set_splicing_info($self->get_splice_starts,$self->get_splice_stops);
		return 0;
	}
	else {
		return 1;
	}
}

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
			return undef;
		}
	}
	
	sub read_transcripts {
		my ($class,$method,@attributes) = @_;
		
		if ($method eq "FILE") {
			my $filename = $attributes[0];
			return $class->_read_file_with_transcripts($filename);
		}
		elsif ($method eq "GTF") {
			my $filename = $attributes[0];
			return $class->_read_gtf_with_transcripts($filename);
		}
		elsif ($method eq "EXON_INFO_FILE") {
			my $filename = $attributes[0];
			return $class->_read_exon_info_file($filename);
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
		
		open (my $IN,"<",$file) or die "Cannot open file $file: $!";
		while (my $line=<$IN>){
			chomp($line);
			if (($line !~ /^#/) and ($line ne '') and ($line !~ /^\s*$/)) {
				my ($chr, $genome, $type, $start, $stop, $score, $strand, undef, $nameinfo) = split(/\t/, $line);
				$start = $start-1; #GTF is one based closed => convert to 0-based closed.
				$stop = $stop-1;
				$nameinfo =~ /gene_id\s+\"(.+)\"\;\s+transcript_id\s+\"(.+)\"/;
				my $ensgid = $1;
				my $enstid = $2;
				
				my $geneObj = MyBio::Gene->get_by_ensgid($ensgid);
				unless ($geneObj) {
					$geneObj = MyBio::Gene->new({
						ENSGID   => $ensgid,
					});
				}
				
				my $transcriptObj = $class->get_by_enstid($enstid);
				unless ($transcriptObj) {
					$transcriptObj = $class->new({
						ENSTID   => $enstid,
						GENE     => $geneObj,
						CHR      => $chr,
						STRAND   => $strand,
						BIOTYPE  => 'non coding',
					});
					$geneObj->push_transcript($transcriptObj);
				}
				
				if (!defined $transcriptObj->get_start or ($start < $transcriptObj->get_start)) {
					$transcriptObj->set_start($start);
				}
				if (!defined $transcriptObj->get_stop or ($stop > $transcriptObj->get_stop)) {
					$transcriptObj->set_stop($stop);
				}
				
				if ($type =~ /exon/) {
					$transcriptObj->push_splice_start_stop_pair($start,$stop);
				}
				elsif ($type =~ /codon/) {
					$transcriptObj->set_biotype('coding');
					if ($type eq 'start_codon') {
						if ($strand eq '+') {
							$transcriptObj->set_coding_start($start);
						}
						elsif ($strand eq '-') {
							$transcriptObj->set_coding_stop($stop);
						}
					}
					elsif ($type eq 'stop_codon') {
						if ($strand eq '+') {
							$transcriptObj->set_coding_stop($stop);
						}
						elsif ($strand eq '-') {
							$transcriptObj->set_coding_start($start);
						}
					}
				}
			}
		}
		close $IN;
		return %allTranscripts;
	}
	sub _read_exon_info_file {
		my ($class,$file)=@_;
		
		my %transcripts_for_genename;
		open (my $IN,"<",$file) or die "Cannot open file $file: $!";
		while (my $line=<$IN>){
			chomp($line);
			if (($line !~ /^#/) and ($line ne '') and ($line !~ /^\s*$/)) {
				my ($tid,$genename,$exon_id,$chr,$start,$stop,$id,$score,$strand,$UTR5,$UTR3,$CDS,$coding,$UTR5_CDS_break,$UTR3_CDS_break,$length,$description) = split(/\t/,$line);
				$stop = $stop-1;
				
				my $transcriptObj = $class->get_by_enstid($tid);
				unless ($transcriptObj) {
					$transcriptObj = $class->new({
						ENSTID   => $tid,
						CHR      => $chr,
						STRAND   => $strand,
						BIOTYPE  => 'non coding',
					});
					push @{$transcripts_for_genename{$genename}},$transcriptObj;
					$transcriptObj->{TEMP_DESCRIPTION} = $description;
				}
				
				if (!defined $transcriptObj->get_start or ($start < $transcriptObj->get_start)) {
					$transcriptObj->set_start($start);
				}
				if (!defined $transcriptObj->get_stop or ($stop > $transcriptObj->get_stop)) {
					$transcriptObj->set_stop($stop);
				}
				$transcriptObj->push_splice_start_stop_pair($start,$stop);
				
				if ($coding == 1) {
					$transcriptObj->set_biotype('coding');
				}
				
				if ($CDS == 1) {
					my @breakpoints = ($start);
					if ($UTR5 == 1) {
						if    ($strand eq '+') {push @breakpoints, $UTR5_CDS_break + 1;}
						elsif ($strand eq '-') {push @breakpoints, $UTR5_CDS_break;}
					}
					if ($UTR3 == 1) {
						if    ($strand eq '+') {push @breakpoints, $UTR3_CDS_break;}
						elsif ($strand eq '-') {push @breakpoints, $UTR3_CDS_break + 1;}
					}
					push @breakpoints, $stop+1;
					@breakpoints = sort {$a <=> $b} @breakpoints;
					
					if ($UTR5 == 1) {
						if ($strand eq '+') {
							shift @breakpoints;
						}
						else {
							pop @breakpoints;
						}
					}
					if ($UTR3 == 1) {
						if ($strand eq '+') {
							pop @breakpoints;
						}
						else {
							shift @breakpoints;
						}
					}
					
					my $set_start = $breakpoints[0];
					my $set_stop = $breakpoints[1] - 1;
					
					if (!defined $transcriptObj->get_coding_start or $set_start < $transcriptObj->get_coding_start) {
						$transcriptObj->set_coding_start($set_start);
					}
					
					if (!defined $transcriptObj->get_coding_stop or $set_stop > $transcriptObj->get_coding_stop) {
						$transcriptObj->set_coding_stop($set_stop);
					}
				}
			}
		}
		close $IN;
		
		foreach my $genename (keys %transcripts_for_genename) {
			my ($merged_loci,$included_transcripts) = MyBio::Helper::Locus::merge($transcripts_for_genename{$genename});
			for (my $i=0;$i<@$merged_loci;$i++) {
				my $gene = MyBio::Gene->new($$merged_loci[$i]);
				$gene->set_name($genename);
				foreach my $transcript (@{$$included_transcripts[$i]}) {
					$gene->set_description(delete $transcript->{TEMP_DESCRIPTION});
					$gene->add_transcript($transcript);
					$transcript->set_gene($gene);
				}
			}
		}
		
		return %allTranscripts;
	}
	
	sub set_sequences_from_genome {
		my ($class, $params) = @_;
		
		my $chr_folder = exists $params->{'CHR_FOLDER'} ? $params->{'CHR_FOLDER'} : die "Chromosome folder must be provided";
		
		my %in_chromosomes;
		foreach my $transcipt (values %allTranscripts) {
			push @{$in_chromosomes{$transcipt->get_chr}}, $transcipt;
		}
		
		foreach my $chr (keys %in_chromosomes) {
			my $chr_file = $chr_folder."/chr$chr.fa";
			unless (-e $chr_file) {
				warn "Skipping chromosome. File $chr_file does not exist";
				next;
			}
			my $chr_seq = MyBio::MySub::read_fasta($chr_file,"chr$chr");
			
			unless (defined $chr_seq) {
				die "No Chromosome Sequence chr$chr\n";
			}
			
			foreach my $transcript (@{$in_chromosomes{$chr}}) {
				my $seq = substr($chr_seq,$transcript->get_start,$transcript->get_length);
				if ($transcript->get_strand == -1) {
					$seq = reverse($seq);
					if ($seq =~ /U/i) {
						$seq =~ tr/ATGCUatgcu/UACGAuacga/;
					}
					else {
						$seq =~ tr/ATGCUatgcu/TACGAtacga/;
					}
				}
				$transcript->set_sequence($seq);
			}
		}
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