# POD documentation - main docs before the code

=head1 NAME

GenOO::Gene - Gene object, with features

=head1 SYNOPSIS

    # This is the main gene object
    # It represents a gene (a genomic region and a collection of transcripts)
    
    # To initialize 
    my $transcript = GenOO::Transcript->new({
        INTERNAL_ID    => undef,
        SPECIES        => undef,
        STRAND         => undef,
        CHR            => undef,
        START          => undef,
        STOP           => undef,
        ENSGID         => undef,
        NAME           => undef,
        REFSEQ         => undef,
        TRANSCRIPTS    => undef, # [] reference to array of gene objects
        DESCRIPTION    => undef,
        EXTRA_INFO     => undef,
    });

=head1 DESCRIPTION

    GenOO::Gene describes a gene. A gene is defined as a locus and as a collection of transcript. This means that it has
    genomic location attributes which are set in respect to the start and stop positions of its contained transcripts. 
    Whenever a transcript is added to a gene object the genomic coordinates of the gene are automatically updated. 
    It is not clear if the gene should have attributes like the biotype as it is not definite whether its contained
    transcripts would all have the same biotype or not.
    Whenever a gene object is created a unique id is associated with the object until it gets out of scope.

=head1 EXAMPLES

    my $gene = GenOO::Gene->get_by_ensgid('ENSG00000000143'); # using the class method to get the corresponding object

=head1 AUTHOR - Manolis Maragkakis, Panagiotis Alexiou

Email em.maragkakis@gmail.com, pan.alexiou@fleming.gr

=cut

# Let the code begin...

package GenOO::Gene;
use strict;
use Object::ID;

use GenOO::DBconnector;
use GenOO::Helper::Locus;

use base qw(GenOO::Locus);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	$self->set_internalID($$data{INTERNAL_ID});
	$self->set_ensgid($$data{ENSGID});
	$self->set_refseq($$data{REFSEQ}); # [] reference to array of refseqs
	$self->set_transcripts($$data{TRANSCRIPTS}); # [] reference to array of transcripts
	$self->set_description($$data{DESCRIPTION});
	
	my $class = ref($self) || $self;
	$class->_add_to_all($self);
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_id {
	return $_[0]->object_id;
}
sub get_ensgid {
	return $_[0]->{ENSGID};
}
sub get_description {
	return $_[0]->{DESCRIPTION};
}
sub get_internalID {
	return $_[0]->{INTERNAL_ID};
}
sub get_refseq {
	if (defined $_[0]->{REFSEQ}) {
		if (defined $_[1]) {
			return $_[0]->{REFSEQ}->[$_[1]]; #return the requested item
		}
		else {
			return $_[0]->{REFSEQ};
		}
	}
	else {
		return [];
	}
}
sub get_transcripts {
	if (defined $_[0]->{TRANSCRIPTS}) {
		if (defined $_[1]) {
			return ${$_[0]->{TRANSCRIPTS}}[$_[1]]; #return the requested gene
		}
		else {
			return $_[0]->{TRANSCRIPTS}; # return the reference to the array with the gene objects
		}
	}
	else {
		return [];
	}
}
sub get_coding_transcripts {
	my ($self) = @_;
	
	my @coding_transcripts;
	foreach my $transcript (@{$self->get_transcripts}) {
		if ($transcript->is_coding) {
			push @coding_transcripts,$transcript;
		}
	}
	return \@coding_transcripts;
}
sub get_non_coding_transcripts {
	my ($self) = @_;
	
	my @non_coding_transcripts;
	foreach my $transcript (@{$self->get_transcripts}) {
		if (!$transcript->is_coding) {
			push @non_coding_transcripts,$transcript;
		}
	}
	return \@non_coding_transcripts;
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_ensgid {
	$_[0]->{ENSGID} = $_[1] if defined $_[1];
}
sub set_internalID {
	$_[0]->{INTERNAL_ID} = $_[1] if defined $_[1];
}
sub set_description {
	$_[0]->{DESCRIPTION} = $_[1] if defined $_[1];
}
sub set_transcripts {
	my ($self,$transcripts_ref) = @_;
	foreach my $transcript (@$transcripts_ref) {
		unless ($transcript->isa('GenOO::Transcript')) {
			die 'Object "'.ref($transcript).'" is not GenOO::Transcript.';
		}
		$self->update_info_from_transcript($transcript);
	}
	$self->{TRANSCRIPTS} = $transcripts_ref;
}
sub set_refseq {
	$_[0]->{REFSEQ} = $_[1] if defined $_[1];
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub update_info_from_transcript {
	my ($self,$transcript) = @_;
	
	if (!defined $self->species) {
		$self->set_species($transcript->species);
	}
	elsif ($self->species ne $transcript->species) {
		die "Inconsistency found when trying to update gene info from transcript. Gene species: ".$self->species."\tTranscript species: ".$transcript->species."\n";
	}
	
	if (!defined $self->strand) {
		$self->set_strand($transcript->strand);
	}
	elsif ($self->strand ne $transcript->strand) {
		die "Inconsistency found when trying to update gene info from transcript. Gene strand: ".$self->strand."\tTranscript strand: ".$transcript->strand."\n";
	}
	
	if (!defined $self->chr) {
		$self->set_chr($transcript->chr);
	}
	elsif ($self->chr ne $transcript->chr) {
		die "Inconsistency found when trying to update gene info from transcript. Gene chr: ".$self->chr."\tTranscript chr: ".$transcript->chr."\n";
	}
	
	if (!defined $self->start or $transcript->start < $self->start) {
		$self->set_start($transcript->start);
	}
	
	if (!defined $self->stop or $transcript->stop > $self->stop) {
		$self->set_stop($transcript->stop);
	}
}
sub add_refseq {
	my ($self,$value) = @_;
	push (@{$self->{REFSEQ}},$value) if defined $value;
}
sub add_transcript {
	my ($self,$transcript) = @_;
	if (defined $transcript and ($transcript->isa('GenOO::Transcript'))) {
		$self->update_info_from_transcript($transcript);
		push (@{$self->{TRANSCRIPTS}},$transcript);
	}
	else {
		warn 'Object "'.ref($transcript).'" is not GenOO::Transcript.    skipped';
	}
}
sub push_transcript {
	my ($self,$transcript) = @_;
	warn "Method ".(caller(0))[3]." is deprecated. Consider using method \"add_transcript\" instead.\n";
	$self->add_transcript($transcript);
}
sub annotate_constitutive_exons {
	my ($self) = @_;
	
	my %counts;
	foreach my $transcript (@{$self->get_transcripts}) {
		foreach my $exon (@{$transcript->get_exons}) {
			$counts{$exon->id}++;
		}
	}
	
	foreach my $transcript (@{$self->get_transcripts}) {
		foreach my $exon (@{$transcript->get_exons}) {
			if ($counts{$exon->id} == @{$self->get_transcripts}) {
				$exon->is_constitutive(1);
			}
			else {
				$exon->is_constitutive(0);
			}
		}
	}
}
sub annotate_constitutive_coding_exons {
	my ($self) = @_;
	
	my $coding_transcripts_count = 0;
	my %counts;
	my $coding_transcripts = $self->get_coding_transcripts;
	my $non_coding_transcripts = $self->get_non_coding_transcripts;
	foreach my $transcript (@$coding_transcripts) {
		foreach my $exon (@{$transcript->get_exons}) {
			$counts{$exon->id}++;
		}
	}
	
	foreach my $transcript (@$coding_transcripts) {
		foreach my $exon (@{$transcript->get_exons}) {
			if ($counts{$exon->id} == @$coding_transcripts) {
				$exon->is_constitutive(1);
			}
			else {
				$exon->is_constitutive(0);
			}
		}
	}
	
	foreach my $transcript (@$non_coding_transcripts) {
		foreach my $exon (@{$transcript->get_exons}) {
			$exon->is_constitutive(0);
		}
	}
}
sub get_constitutive_exons {
	my ($self) = @_;
	
	$self->annotate_constitutive_exons();
	
	my @constitutive_exons;
	my %already_found;
	foreach my $transcript (@{$self->get_transcripts}) {
		foreach my $exon (@{$transcript->get_exons}) {
			if ($exon->is_constitutive() and !exists $already_found{$exon->id}) {
				my $new_exon = $exon->clone();
				$new_exon->set_where($self);
				push @constitutive_exons, $new_exon;
				$already_found{$exon->id} = 1;
			}
		}
	}
	return \@constitutive_exons;
}
sub get_constitutive_coding_exons {
	my ($self) = @_;
	
	$self->annotate_constitutive_coding_exons();
	
	my @constitutive_exons;
	my %already_found;
	foreach my $transcript (@{$self->get_transcripts}) {
		foreach my $exon (@{$transcript->get_exons}) {
			if ($exon->is_constitutive() and !exists $already_found{$exon->id}) {
				my $new_exon = $exon->clone();
				$new_exon->set_where($self);
				push @constitutive_exons, $new_exon;
				$already_found{$exon->id} = 1;
			}
		}
	}
	return \@constitutive_exons;
}
sub get_exon_length {
	my ($self) = @_;
	
	my @exons;
	foreach my $transcript (@{$self->get_transcripts}) {
		foreach my $exon (@{$transcript->get_exons}) {
			push @exons, $exon;
		}
	}
	
	my $merged_exons = GenOO::Helper::Locus::merge(\@exons);
	
	my $exon_length = 0;
	foreach my $exon (@$merged_exons) {
		$exon_length += $exon->get_length;
	}
	
	return $exon_length;
}
sub get_merged_exons {
	my ($self) = @_;
	
	my @exons;
	foreach my $transcript (@{$self->get_transcripts}) {
		foreach my $exon (@{$transcript->get_exons}) {
			push @exons, $exon;
		}
	}
	
	return GenOO::Helper::Locus::merge(\@exons);
}
sub has_coding_transcript {
	my ($self) = @_;
	
	my $has_coding_transcript = 0;
	foreach my $transcript (@{$self->get_transcripts}) {
		if ($transcript->is_coding) {
			$has_coding_transcript = 1;
			last;
		}
	}
	
	return $has_coding_transcript;
}

#######################################################################
##########################   Class Methods   ##########################
#######################################################################
{
	my %all_gene_ids;      # unique key for every gene
	my %all_gene_ensgids;  # unique key for every gene
	my %all_gene_names;    # non-unique key for every gene -> value is an array
	
	sub _add_to_all {
		my ($class,$obj) = @_;
		$all_gene_ids{$obj->get_id} = $obj;
		if (defined $obj->get_ensgid) {
			$all_gene_ensgids{$obj->get_ensgid} = $obj;
		}
		if (defined $obj->name) {
			unless (exists $all_gene_names{$obj->name}) {
				$all_gene_names{$obj->name} = [];
			}
			push @{$all_gene_names{$obj->name}}, $obj;
		}
	}
	sub _delete_from_all {
		my ($class,$obj) = @_;
		delete $all_gene_ids{$obj->get_id};
		delete $all_gene_ensgids{$obj->get_ensgid};
		if (exists $all_gene_names{$obj->get_name}) {
			for (my $i=0;$i<@{$all_gene_names{$obj->get_name}};$i++) {
				if ($all_gene_names{$obj->get_name}->[$i]->get_id eq $obj->get_id) {
					splice(@{$all_gene_names{$obj->get_name}},$i,1);
				}
			}
		}
	}
	
	sub get_all {
		my ($class) = @_;
		return values %all_gene_ids;
	}
	
	sub delete_all {
		my ($class) = @_;
		%all_gene_ids = ();
	}

=head2 get_by_id

  Arg [1]    : string $id
               The primary id of the gene.
  Example    : GenOO::Gene->get_by_id;
  Description: Class method that returns the object which corresponds to the provided primary gene id.
               If no object is found returns undef
  Returntype : GenOO::Gene / undef
  Caller     : ?
  Status     : Under development

=cut
	sub get_by_id {
		my ($class,$id) = @_;
		if (exists $all_gene_ids{$id}) {
			return $all_gene_ids{$id};
		}
		else {
			return undef;
		}
	}
	
=head2 get_by_ensgid

  Arg [1]    : string $ensgid
               The Ensembl id of the gene.
  Example    : GenOO::Gene->get_by_ensgid;
  Description: Class method that returns the object which corresponds to the provided Ensembl gene id.
               If no object is found, then depending on the database access policy the method either attempts
               to create a new object or returns undef
  Returntype : GenOO::Gene / undef
  Caller     : ?
  Status     : Stable

=cut
	sub get_by_ensgid {
		my ($class,$ensgid) = @_;
		if (exists $all_gene_ensgids{$ensgid}) {
			return $all_gene_ensgids{$ensgid};
		}
		elsif ($class->database_access eq 'ALLOW') {
			return $class->create_new_gene_from_database($ensgid);
		}
		else {
			return undef;
		}
	}
	
=head2 get_by_name

  Arg [1]    : string $ensgid
               The name of the gene.
  Example    : GenOO::Gene->get_by_name;
  Description: Class method that returns a reference to an array of object which correspond to the provided gene name.
               If no matching object is found a reference to an empty array is returned.
  Returntype : GenOO::Gene / []
  Caller     : ?
  Status     : Stable

=cut
	sub get_by_name {
		my ($class,$name) = @_;
		if (exists $all_gene_names{$name}) {
			return $all_gene_names{$name};
		}
		else {
			return [];
		}
	}
	
	
	sub read_refseqs {
		my ($class,$method,@attributes) = @_;
		
		if ($method eq "FILE") {
			my $filename = $attributes[0];
			return $class->_read_file_with_refseqs($filename);
		}
	}
	
	sub _read_file_with_refseqs {
		my ($class,$file)=@_;
		
		open (my $IN,"<",$file) or die "Cannot open file $file: $!";
		while (my $line = <$IN>){
			chomp($line);
			my ($ensgid,$refseq) = split(/\t/,$line);
			my $geneObj = $class->get_by_ensgid($ensgid);
			unless ($geneObj) {
				$geneObj = $class->new({
							   ENSGID   => $ensgid,
							});
			}
			$geneObj->add_refseq($refseq);
		}
		close $IN;
		
		return %all_gene_ids;
	}
	
	sub read_names {
		my ($class,$method,@attributes) = @_;
		
		if ($method eq "FILE") {
			my $filename = $attributes[0];
			return $class->_read_file_with_names($filename);
		}
	}
	
	sub _read_file_with_names {
		my ($class,$file)=@_;
		
		open (my $IN,"<",$file) or die "Cannot open file $file: $!";
		while (my $line = <$IN>){
			chomp($line);
			my ($ensgid,$commonName) = split(/\t/,$line);
			my $geneObj = $class->get_by_ensgid($ensgid);
			unless ($geneObj) {
				$geneObj = $class->new({
							   ENSGID   => $ensgid,
							});
			}
			$geneObj->set_name($commonName);
		}
		close $IN;
		
		return %all_gene_ids;
	}
	
	sub read_description {
		my ($class,$method,@attributes) = @_;
		
		if ($method eq "FILE") {
			my $filename = $attributes[0];
			return $class->_read_file_with_descriptions($filename);
		}
	}
	
	sub _read_file_with_descriptions {
		my ($class,$file)=@_;
		
		open (my $IN,"<",$file) or die "Cannot open file $file: $!";
		while (my $line = <$IN>){
			chomp($line);
			my ($ensgid,$description) = split(/\t/,$line);
			my $geneObj = $class->get_by_ensgid($ensgid);
			unless ($geneObj) {
				$geneObj = $class->new({
							   ENSGID   => $ensgid,
							});
			}
			$geneObj->set_description($description);
		}
		close $IN;
		
		return %all_gene_ids;
	}
	
	########################################## database ##########################################
	my $DBconnector;
	my $accessPolicy = GenOO::DBconnector->global_access();
	my $select_all_from_genes_where_ensgid;
	my $select_all_from_genes_where_ensgid_Query = qq/SELECT * FROM diana_protein_genes WHERE diana_protein_genes.ensgid=?/;
	
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
				if (GenOO::DBconnector->exists("core")) {
					$DBconnector = GenOO::DBconnector->get_dbconnector("core");
				}
				else {
					print STDERR "\nRequesting database connector for class $class\n";
					$DBconnector = GenOO::DBconnector->get_dbconnector($class);
				}
			}
		}
		return $DBconnector;
	}
	
	sub create_new_gene_from_database {
		my ($class,$ensgid) = @_;
		
		my $DBconnector = $class->get_db_connector();
		if (defined $DBconnector) {
			my $dbh = $DBconnector->get_handle();
			unless (defined $select_all_from_genes_where_ensgid) {
				$select_all_from_genes_where_ensgid = $dbh->prepare($select_all_from_genes_where_ensgid_Query);
			}
			$select_all_from_genes_where_ensgid->execute($ensgid);
			my $fetch_hash_ref = $select_all_from_genes_where_ensgid->fetchrow_hashref;
			$select_all_from_genes_where_ensgid->finish(); # there should be only one result so I have to indicate that fetching is over
			
			if (defined $$fetch_hash_ref{internal_gid}) {
				my $gene = $class->new({
							   INTERNAL_ID      => $$fetch_hash_ref{internal_gid},
							   ENSGID           => $$fetch_hash_ref{ensgid},
							});
				return $gene;
			}
			else {
				warn "Gene \"$ensgid\" could not be found in database. Please check that the gene already exists\n";
				return undef;
			}
			
		}
	}
}

1;