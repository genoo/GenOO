# POD documentation - main docs before the code

=head1 NAME

GenOO::Transcript - Transcript object, with features

=head1 SYNOPSIS

    # This is the main transcript object
    # It represents a transcript of a gene
    
    # To initialize 
    my $transcript = GenOO::Transcript->new({
        ENSTID         => undef,
        SPECIES        => undef,
        STRAND         => undef,
        CHR            => undef,
        START          => undef,
        STOP           => undef,
        GENE           => undef, # GenOO::Gene
        UTR5           => undef, # GenOO::Transcript::UTR5
        CDS            => undef, # GenOO::Transcript::CDS
        UTR3           => undef, # GenOO::Transcript::UTR3
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

    my %transcripts = GenOO::Transcript->read_region_info_for_transcripts('FILE',"$database/Ensembl_release_54/CDS_and_3UTR_sequences_CLEAN.txt");

=head1 AUTHOR - Manolis Maragkakis, Panagiotis Alexiou

Email em.maragkakis@gmail.com, pan.alexiou@fleming.gr

=cut

# Let the code begin...

package GenOO::Transcript;

use Moose;
use namespace::autoclean;

use GenOO::Helper::Locus;
use GenOO::Gene;
use GenOO::Transcript::UTR5;
use GenOO::Transcript::CDS;
use GenOO::Transcript::UTR3;

extends 'GenOO::GenomicRegion';

has 'id'           => (is => 'rw', required => 1);
has 'coding_start' => (isa => 'Int', is => 'rw');
has 'coding_stop'  => (isa => 'Int', is => 'rw');

has 'biotype' => (
	isa       => 'Str',
	is        => 'rw',
	builder   => '_find_biotype',
	lazy      => 1,
);

has 'gene' => (
	isa       => 'GenOO::Gene',
	is        => 'rw',
	weak_ref  => 1
);

has 'utr5' => (
	isa       => 'GenOO::Transcript::UTR5',
	is        => 'rw',
	builder   => '_find_or_create_utr5',
	lazy      => 1
);

has 'cds' => (
	isa       => 'GenOO::Transcript::CDS',
	is        => 'rw',
	builder   => '_find_or_create_cds',
	lazy      => 1
);

has 'utr3' => (
	isa       => 'GenOO::Transcript::UTR3',
	is        => 'rw',
	builder   => '_find_or_create_utr3',
	lazy      => 1
);

with 'GenOO::Spliceable';


sub BUILD {
	my $self = shift;
	
	my $class = ref($self) || $self;
	$class->_add_transcript($self);
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
	$class->_delete_transcript($self);
}

sub exons_split_by_function {
	my ($self) = @_;
	
	if ($self->is_coding) {
		my @exons;
		if (defined $self->utr5) {
			push @exons,@{$self->utr5->exons};
		}
		if (defined $self->cds) {
			push @exons,@{$self->cds->exons};
		}
		if (defined $self->utr3) {
			push @exons,@{$self->utr3->exons};
		}
		return \@exons;
	}
	else {
		return $self->exons;
	} 
}

sub is_coding {
	my ($self) = @_;
	
	if ($self->biotype eq 'coding') {
		return 1;
	}
	else {
		return 0;
	}
}

#######################################################################
#########################   Private methods  ##########################
#######################################################################
sub _find_or_create_utr5 {
	my ($self) = @_;
	
	if (defined $self->coding_start and defined $self->coding_stop) {
		my $utr5_start = ($self->strand == 1) ? $self->start : $self->coding_stop + 1;
		my $utr5_stop = ($self->strand == 1) ? $self->coding_start - 1 : $self->stop;
		
		my ($splice_starts, $splice_stops) = _sanitize_splice_coords_within_limits(
			$self->splice_starts,
			$self->splice_stops,
			$utr5_start,
			$utr5_stop
		);
		
		return GenOO::Transcript::UTR5->new({
			start         => $utr5_start,
			stop          => $utr5_stop,
			splice_starts => $splice_starts,
			splice_stops  => $splice_stops,
			transcript    => $self,
			chromosome    => $self->chromosome,
			strand        => $self->strand
			
		});
	}
}

sub _find_or_create_cds {
	my ($self) = @_;
	
	if (defined $self->coding_start and defined $self->coding_stop) {
		my ($splice_starts, $splice_stops) = _sanitize_splice_coords_within_limits(
			$self->splice_starts,
			$self->splice_stops,
			$self->coding_start,
			$self->coding_stop
		);
		
		return GenOO::Transcript::CDS->new({
			start         => $self->coding_start,
			stop          => $self->coding_stop,
			splice_starts => $splice_starts,
			splice_stops  => $splice_stops,
			transcript    => $self,
			chromosome    => $self->chromosome,
			strand        => $self->strand
		});
	}
}

sub _find_or_create_utr3 {
	my ($self) = @_;
	
	if (defined $self->coding_start and defined $self->coding_stop) {
		my $utr3_start = ($self->strand == 1) ? $self->coding_stop + 1 : $self->start;
		my $utr3_stop = ($self->strand == 1) ? $self->stop : $self->coding_start - 1;
		
		my ($splice_starts, $splice_stops) = _sanitize_splice_coords_within_limits(
			$self->splice_starts,
			$self->splice_stops,
			$utr3_start,
			$utr3_stop
		);
		
		return GenOO::Transcript::UTR3->new({
			start         => $utr3_start,
			stop          => $utr3_stop,
			splice_starts => $splice_starts,
			splice_stops  => $splice_stops,
			transcript    => $self,
			chromosome    => $self->chromosome,
			strand        => $self->strand
		});
	}
}

sub _find_biotype {
	my ($self) = @_;
	
	if (defined $self->coding_start) {
		return 'coding';
	}
}

#######################################################################
##########################   Class Methods   ##########################
#######################################################################
{
	my %all_created_transcripts;
	
	sub _add_transcript {
		my ($class, $obj) = @_;
		
		$all_created_transcripts{$obj->id} = $obj;
	}
	
	sub _delete_transcript {
		my ($class, $obj) = @_;
		
		delete $all_created_transcripts{$obj->id};
	}
	
	sub all_transcripts {
		my ($class) = @_;
		
		return values %all_created_transcripts;
	}
	
	sub delete_all_transcripts {
		my ($class) = @_;
		
		%all_created_transcripts = ();
	}

	sub transcript_with_id {
		my ($class, $id) = @_;
		
		return $all_created_transcripts{$id};
	}
	
	sub read_transcripts {
		my ($class, $method, @attributes) = @_;
		
		if ($method eq "GTF") {
			my $filename = $attributes[0];
			return $class->_read_gtf_with_transcripts($filename);
		}
		elsif ($method eq "EXON_INFO_FILE") {
			my $filename = $attributes[0];
			return $class->_read_exon_info_file($filename);
		}
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
				my $id = $2;
				
				my $geneObj = GenOO::Gene->get_by_ensgid($ensgid);
				unless ($geneObj) {
					$geneObj = GenOO::Gene->new({
						ENSGID   => $ensgid,
					});
				}
				
				my $transcriptObj = $class->get_by_enstid($id);
				unless ($transcriptObj) {
					$transcriptObj = $class->new({
						ENSTID   => $id,
						GENE     => $geneObj,
						CHR      => $chr,
						STRAND   => $strand,
						BIOTYPE  => 'non coding',
					});
					$geneObj->add_transcript($transcriptObj);
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
		return %all_created_transcripts;
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
				
				if (!defined $transcriptObj->start or ($start < $transcriptObj->start)) {
					$transcriptObj->set_start($start);
				}
				if (!defined $transcriptObj->stop or ($stop > $transcriptObj->stop)) {
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
			my ($merged_loci,$included_transcripts) = GenOO::Helper::Locus::merge($transcripts_for_genename{$genename});
			for (my $i=0;$i<@$merged_loci;$i++) {
				my $gene = GenOO::Gene->new($$merged_loci[$i]);
				$gene->set_name($genename);
				foreach my $transcript (@{$$included_transcripts[$i]}) {
					$gene->set_description(delete $transcript->{TEMP_DESCRIPTION});
					$gene->add_transcript($transcript);
					$transcript->set_gene($gene);
				}
			}
		}
		
		return %all_created_transcripts;
	}
}

__PACKAGE__->meta->make_immutable;
1;