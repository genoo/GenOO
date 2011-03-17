package Gene;

use warnings;
use strict;

use Switch;
use _Initializable;

our $VERSION = '2.0';

our @ISA = qw( _Initializable );

# HOW TO INITIALIZE THIS OBJECT
# my $geneObj = Gene->new({
# 		     ENSGID           => undef,
# 		     COMMON_NAME      => undef,
# 		     REFSEQ           => undef,
# 		     TRANSCRIPTS      => undef, # [] reference to array of gene objects
# 		     EXTRA_INFO       => undef,
# 		     });

sub _init {
	my ($self,$data) = @_;
	
	$self->set_internalID($$data{INTERNAL_ID});
	$self->{ENSGID}        = $$data{ENSGID};
	$self->{COMMON_NAME}   = $$data{COMMON_NAME}; # [] reference to array of names
	$self->{REFSEQ}        = $$data{REFSEQ}; # [] reference to array of refseqs
	$self->{TRANSCRIPTS}   = $$data{TRANSCRIPTS}; # [] reference to array of gene objects
	$self->{DESCRIPTION}   = $$data{DESCRIPTION};
	$self->{EXTRA_INFO}    = $$data{EXTRA_INFO};
	
	my $class = ref($self) || $self;
	$class->_add_to_all($self);
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_ensgid                 {return $_[0]->{ENSGID};}
sub get_extra                  {return $_[0]->{EXTRA_INFO};}
sub get_description            {return $_[0]->{DESCRIPTION};}
sub get_internalID {
	return $_[0]->{INTERNAL_ID};
}
sub get_refseq {
	if (defined $_[0]->{REFSEQ}) {
		if (defined $_[1]) {
			return ${$_[0]->{REFSEQ}}[$_[1]]; #return the requested gene
		}
		else {
			return $_[0]->{REFSEQ}; # return the reference to the array with the gene objects
		}
	}
	else {
		return [];
	}
}
sub get_common_name {
	if (defined $_[0]->{COMMON_NAME}) {
		if (defined $_[1]) {
			return ${$_[0]->{COMMON_NAME}}[$_[1]]; #return the requested gene
		}
		else {
			return $_[0]->{COMMON_NAME}; # return the reference to the array with the gene objects
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
sub set_extra {$_[0]->{EXTRA_INFO} = $_[1] if defined $_[1];}
sub set_internalID {
	$_[0]->{INTERNAL_ID} = $_[1] if defined $_[1];
}
sub set_description {$_[0]->{DESCRIPTION} = $_[1] if (defined $_[1] && $_[1] ne '');}
sub set_common_name {$_[0]->{COMMON_NAME} = $_[1] if (defined $_[1] && $_[1] ne '');}

sub add_refseq {
	push (@{$_[0]->{REFSEQ}},$_[1]) if (defined $_[1] && $_[1] ne '');
}
#add_common_name deleted!!!

#######################################################################
#########################   General Methods   #########################
#######################################################################

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
	
	sub get_by_ensgid {
		my ($class,$ensgid) = @_;
		if (exists $allGenes{$ensgid}) {
			return $allGenes{$ensgid};
		}
		else {
			return $class->create_new_gene_from_database($ensgid);
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
	my $allowDatabaseAccess;
	my $select_all_from_genes_where_ensgid;
	my $select_all_from_genes_where_ensgid_Query = qq/SELECT * FROM diana_protein_genes WHERE diana_protein_genes.ensgid=?/;
	
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
				print STDERR 'Would you like to enable database access to retrieve Gene data? (y/n) [y]';
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
					print STDERR "\nRequesting database connector with name \"gene\"\n";
					$DBconnector = DBconnector->get_dbconnector("gene");
				}
			}
		}
		return $DBconnector;
	}
	
	sub create_new_gene_from_database {
		my ($class,$ensgid) = @_;
		
		my $DBconnector = $class->get_global_DBconnector();
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