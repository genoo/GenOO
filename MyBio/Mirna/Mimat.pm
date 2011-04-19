package MyBio::Mirna::Mimat;
use strict;

use MyBio::DBconnector;

use base qw( MyBio::_Initializable );

# HOW TO INITIALIZE THIS OBJECT
# my $mimatObj = MyBio::Mirna::Mimat->new({
# 		     NAME         => undef,
# 		     MIMAT        => undef,
# 		     INTERNAL_ID  => undef,
# 		     SEQUENCE     => undef,
# 		     STRAND       => undef,
# 		     CHR          => undef,
# 		     CHR_START    => undef,
# 		     CHR_STOP     => undef,
# 		     EXTRA_INFO   => undef,
# 		     });

sub _init {
	my ($self,$data) = @_;
	
	$self->set_name($$data{NAME});
	$self->set_mimat($$data{MIMAT});
	$self->set_internalID($$data{INTERNAL_ID});
	$self->set_species($$data{SPECIES});
	$self->set_sequence($$data{SEQUENCE});
	$self->set_strand($$data{STRAND});
	$self->set_chr($$data{CHR});
	$self->set_chr_start($$data{CHR_START});
	$self->set_chr_stop($$data{CHR_STOP});
	$self->set_extra($$data{EXTRA_INFO});
	
	my $class = ref($self) || $self;
	$class->_add_to_all($self);
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_name {
	return $_[0]->{NAME};
}
sub get_mimat {
	return $_[0]->{MIMAT};
}
sub get_seq {
	return $_[0]->{SEQUENCE};
}
sub get_sequence {
	return $_[0]->{SEQUENCE};
}
sub get_chr {
	return $_[0]->{CHR};
}
sub get_chr_start {
	return $_[0]->{CHR_START};
}
sub get_chr_stop {
	return $_[0]->{CHR_STOP};
}
sub get_strand {
	return $_[0]->{STRAND};
}
sub get_species {
	return $_[0]->{SPECIES};
}
sub get_extra {
	return $_[0]->{EXTRA_INFO};
}
sub get_internalID {
	return $_[0]->{INTERNAL_ID};
}
sub get_seed {
	unless (defined $_[0]->{SEED}) {
		$_[0]->{SEED} = substr($_[0]->{SEQUENCE},1,6);
	}
	return $_[0]->{SEED};
}
sub get_driver { 
	unless (defined $_[0]->{DRIVER}) {
		$_[0]->{DRIVER} = substr($_[0]->{SEQUENCE},0,9);
	}
	return $_[0]->{DRIVER};
}
sub get_length {
	if (defined $_[0]->{SEQUENCE}) {
		return length($_[0]->{SEQUENCE});
	}
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_extra {
	$_[0]->{EXTRA_INFO} = $_[1] if defined $_[1];
}
sub set_mimat {
	$_[0]->{MIMAT} = $_[1] if defined $_[1];
}
sub set_internalID {
	$_[0]->{INTERNAL_ID} = $_[1] if defined $_[1];
}
sub set_species {
	$_[0]->{SPECIES} = uc($_[1]) if defined $_[1];
}
sub set_name {
	my ($self,$value) = @_;
	if (defined $value) {
		$value =~ s/>//;
		$value =~ s/\*+/-star/g;
		$self->{NAME} = $value;
	}
}
sub set_sequence {
	my ($self,$value) = @_;
	if (defined $value) {
		$value =~ tr/Tt/UU/;
		$value = uc($value);
		$self->{SEQUENCE} = $value;
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
sub set_chr_start {
	$_[0]->{CHR_START} = $_[1] if defined $_[1];
}
sub set_chr_stop {
	$_[0]->{CHR_STOP} = uc($_[1]) if defined $_[1];
}

#######################################################################
##########################   Class Methods   ##########################
#######################################################################
{
	my %allMimats;
	my @allMimatsArray;
	
	sub _add_to_all {
		my ($class,$obj) = @_;
		$allMimats{$obj->get_name()} = $obj;
	}
	
	sub _delete_from_all {
		my ($class,$obj) = @_;
		delete $allMimats{$obj->get_name()};
	}
	
	sub get_all {
		my ($class) = @_;
		return %allMimats;
	}

=head2 get_by_name

  Arg [1]    : string $name
               The name of the mirna.
  Example    : MyBio::Mirna::Mimat->get_by_name;
  Description: Class method that returns the object which corresponds to the provided miRNA name.
               If no object is found, then depending on the database access policy the method either attempts
               to create a new object or returns NULL
  Returntype : MyBio::Mirna::Mimat / NULL
  Caller     : ?
  Status     : Stable

=cut
	sub get_by_name {
		my ($class,$name) = @_;
		if (exists $allMimats{$name}) {
			return $allMimats{$name};
		}
		elsif ($class->database_access eq 'ALLOW') {
			return $class->create_new_mirna_from_database($name);
		}
		else {
			return;
		}
	}
	
	sub read_mirnas {
		my ($class,$method,@attributes) = @_;
		
		if ($method eq "FILE") {
			my $filename = $attributes[0];
			return $class->_read_Mimats_from_fasta_file($filename);
		}
	}
	
	sub _read_Mimats_from_fasta_file {
		
		my ($class,$file)=@_;
		
		my $mirnamatObj;
		my @objectList;
		
		open (FASTA,"<",$file) or die "Cannot open file $file: $!";
		while (my $line=<FASTA>){
			chomp($line);
			$line =~ s/\*+/-star/g;
			if (substr($line,0,1) eq '>') {
				my ($mirnaName,$mimatID,@species) = split(/\s+/,$line);
				pop (@species);
				$mirnamatObj = $class->new({
					                      NAME => $mirnaName,
					                      MIMAT => $mimatID,
					                      SPECIES => join(' ',@species),
				                           });
				push @objectList,$mirnamatObj;
			}
			elsif (substr($line,0,1) ne '#') {
				if ($line =~ /^[ATGCU]*$/i) {
					$mirnamatObj->set_sequence($line);
				}
				else {
					$line =~ /([^ATGCU])/i;
					warn "\n\nWARNING:\nThe nucleotide sequence provided contain the following invalid characters $1\n\n";
				}
			}
		}
		close FASTA;
		
		return %allMimats;
	}
	
	sub read_mimat_internal_IDs {
		my ($class,$method,@attributes) = @_;
		
		if ($method eq "FILE") {
			my $filename = $attributes[0];
			return $class->_read_mimat_internal_IDs_from_file($filename);
		}
	}
	
	sub _read_mimat_internal_IDs_from_file {
		my ($class,$file) = @_;
		
		open (my $IDS,"<",$file) or die "Cannot open file $file: $!";
		while (my $line=<$IDS>){
			chomp($line);
			my ($internalID,$mimatname) = split(/\|/,$line);
			my $mimat = $class->get_by_name($mimatname);
			$mimat->set_internalID($internalID);
		}
		close ($IDS);
	}
	
	sub read_Mimat_from_file {
		my ($class,$miRNAfile) = @_;
		
		#Read miRNA info and create object
		my %miRNAinfo;
		open (INFO,$miRNAfile) or die "Cannot open file $miRNAfile: $!";
		while (my $line=<INFO>){
			chomp($line);
			my @splitline=split(/=/,$line);
			$miRNAinfo{$splitline[0]}=$splitline[1];
		}
		close INFO;
		
		my $mirnaObj = $class->new({
			                    NAME     => $miRNAinfo{'miRNAname'},
			                    SEQUENCE => $miRNAinfo{'miRNAseq'},
			                    SPECIES  => $miRNAinfo{'species'},
			                   });
		
		return $mirnaObj;
	}
	
	########################################## database ##########################################
	my $DBconnector;
	my $accessPolicy = MyBio::DBconnector->global_access();
	my $select_all_from_marure_mirnas_where_name;
	my $select_all_from_marure_mirnas_where_name_Query = qq/SELECT * FROM diana_mature_mirnas WHERE diana_mature_mirnas.name=?/;
	
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
	
	sub create_new_mirna_from_database {
		my ($class,$name) = @_;
		
		$class->get_db_connector();
		if (defined $DBconnector) {
			my $dbh = $DBconnector->get_handle();
			unless (defined $select_all_from_marure_mirnas_where_name) {
				$select_all_from_marure_mirnas_where_name = $dbh->prepare($select_all_from_marure_mirnas_where_name_Query);
			}
			$select_all_from_marure_mirnas_where_name->execute($name);
			my $fetch_hash_ref = $select_all_from_marure_mirnas_where_name->fetchrow_hashref;
			$select_all_from_marure_mirnas_where_name->finish(); # there should be only one result so I have to indicate that fetching is over
			
			if (defined $$fetch_hash_ref{internal_mimat_id}) {
				my $mirnamatObj = $class->new({
							NAME        => $$fetch_hash_ref{name},
							MIMAT       => $$fetch_hash_ref{mimat},
							SPECIES     => $$fetch_hash_ref{species},
							INTERNAL_ID => $$fetch_hash_ref{internal_mimat_id},
							SEQUENCE    => $$fetch_hash_ref{sequence},
						});
				return $mirnamatObj;
			}
			else {
				warn "microRNA \"$name\" could not be found in database. Please check that the miRNA already exists\n";
				return undef;
			}
			
		}
	}
}


1;
