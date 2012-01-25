package MyBio::Gene;
use strict;

use MyBio::DBconnector;

use base qw( MyBio::_Initializable );

# HOW TO INITIALIZE THIS OBJECT
# my $geneObj = MyBio::Gene->new({
# 		     INTERNAL_ID      => undef,
# 		     ENSGID           => undef,
# 		     COMMON_NAME      => undef,
# 		     REFSEQ           => undef,
# 		     TRANSCRIPTS      => undef, # [] reference to array of gene objects
# 		     DESCRIPTION      => undef,
# 		     EXTRA_INFO       => undef,
# 		     });

sub _init {
	my ($self,$data) = @_;
	
	$self->set_internalID($$data{INTERNAL_ID});
	
	$self->set_ensgid($$data{ENSGID});
	$self->set_common_name($$data{COMMON_NAME});
	$self->set_refseq($$data{REFSEQ}); # [] reference to array of refseqs
	$self->set_transcripts($$data{TRANSCRIPTS}); # [] reference to array of transcripts
	$self->set_description($$data{DESCRIPTION});
	$self->set_extra($$data{EXTRA_INFO});
	
	my $class = ref($self) || $self;
	$class->_add_to_all($self);
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_ensgid {
	return $_[0]->{ENSGID};
}
sub get_extra {
	return $_[0]->{EXTRA_INFO};
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
sub get_common_name {
	if (defined $_[0]->{COMMON_NAME}) {
		if (defined $_[1]) {
			return ${$_[0]->{COMMON_NAME}}[$_[1]]; #return the requested item
		}
		else {
			return $_[0]->{COMMON_NAME};
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

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_extra {
	$_[0]->{EXTRA_INFO} = $_[1] if defined $_[1];
}
sub set_ensgid {
	$_[0]->{ENSGID} = $_[1] if defined $_[1];
}
sub set_internalID {
	$_[0]->{INTERNAL_ID} = $_[1] if defined $_[1];
}
sub set_description {
	$_[0]->{DESCRIPTION} = $_[1] if (defined $_[1] && $_[1] ne '');
}
sub set_common_name {
	$_[0]->{COMMON_NAME} = $_[1] if (defined $_[1] && $_[1] ne '');
}
sub set_transcripts {
	$_[0]->{TRANSCRIPTS} = $_[1] if defined $_[1];
}
sub set_refseq {
	$_[0]->{REFSEQ} = $_[1] if defined $_[1];
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub add_refseq {
	push (@{$_[0]->{REFSEQ}},$_[1]) if (defined $_[1] && $_[1] ne '');
}
sub push_transcript {
	push (@{$_[0]->{TRANSCRIPTS}},$_[1]) if (defined $_[1] && $_[1] ne '');
}
sub annotate_constitutive_exons {
	my ($self) = @_;
	
	my %counts;
	foreach my $transcript (@{$self->get_transcripts}) {
		foreach my $exon (@{$transcript->get_exons}) {
			$counts{$exon->get_id}++;
		}
	}
	
	foreach my $transcript (@{$self->get_transcripts}) {
		foreach my $exon (@{$transcript->get_exons}) {
			if ($counts{$exon->get_id} == @{$self->get_transcripts}) {
				$exon->is_constitutive(1);
			}
			else {
				$exon->is_constitutive(0);
			}
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
			if ($exon->is_constitutive() and !exists $already_found{$exon->get_id}) {
				my $new_exon = $exon->clone();
				$new_exon->set_where($self);
				push @constitutive_exons, $new_exon;
				$already_found{$exon->get_id} = 1;
			}
		}
	}
	return \@constitutive_exons;
}

#######################################################################
##########################   Class Methods   ##########################
#######################################################################
{
	my %allGenes;
	
	sub _add_to_all {
		my ($class,$obj) = @_;
		$allGenes{$obj->get_ensgid} = $obj;
	}
	
	sub _delete_from_all {
		my ($class,$obj) = @_;
		delete $allGenes{$obj->get_ensgid};
	}
	
	sub get_all {
		my ($class) = @_;
		return %allGenes;
	}
	
	sub delete_all {
		my ($class) = @_;
		%allGenes = ();
	}
	
=head2 get_by_ensgid

  Arg [1]    : string $ensgid
               The primary id of the gene.
  Example    : MyBio::Gene->get_by_ensgid;
  Description: Class method that returns the object which corresponds to the provided primary gene id.
               If no object is found, then depending on the database access policy the method either attempts
               to create a new object or returns NULL
  Returntype : MyBio::Gene / NULL
  Caller     : ?
  Status     : Stable

=cut
	sub get_by_ensgid {
		my ($class,$ensgid) = @_;
		if (exists $allGenes{$ensgid}) {
			return $allGenes{$ensgid};
		}
		elsif ($class->database_access eq 'ALLOW') {
			return $class->create_new_gene_from_database($ensgid);
		}
		else {
			return;
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
		
		return %allGenes;
	}
	
	sub read_common_names {
		my ($class,$method,@attributes) = @_;
		
		if ($method eq "FILE") {
			my $filename = $attributes[0];
			return $class->_read_file_with_common_names($filename);
		}
	}
	
	sub _read_file_with_common_names {
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
			$geneObj->set_common_name($commonName);
		}
		close $IN;
		
		return %allGenes;
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
		
		return %allGenes;
	}
	
	########################################## database ##########################################
	my $DBconnector;
	my $accessPolicy = MyBio::DBconnector->global_access();
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