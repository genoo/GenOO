package MyBio::Mirna::Hairpin;

use warnings;
use strict;
use Switch;

use _Initializable;
use MyBio::Mirna::Mimat;

our $VERSION = '2.0';

our @ISA = qw(_Initializable);

# HOW TO INITIALIZE THIS OBJECT
# my $hairpinObj = Mirna::Hairpin->new({
# 		     SPECIES     => undef,
# 		     CHR         => undef,
# 		     START       => undef,
# 		     STOP        => undef,
# 		     STRAND      => undef,
# 		     MIMA        => undef,
# 		     INTERNAL_ID => undef,
# 		     SEQUENCE    => undef,
# 		     EXTRA       => undef,
# 		     });

sub _init {
	my ($self,$data) = @_;
	
	$self->set_name($$data{NAME});
	$self->set_mima($$data{MIMA});
	$self->set_strand($$data{STRAND});
	$self->set_chr($$data{CHR});
	$self->set_start($$data{START});
	$self->set_stop($$data{STOP});
	$self->set_species($$data{SPECIES});
	$self->set_sequence($$data{SEQUENCE});
	$self->set_internalID($$data{INTERNAL_ID});
	$self->set_matures($$data{MATURES});
	$self->set_extra($$data{EXTRA});
	
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
sub get_mima {
	return $_[0]->{MIMA};
}
sub get_strand {
	return $_[0]->{STRAND};
}
sub get_chr {
	return $_[0]->{CHR};
}
sub get_start {
	return $_[0]->{START};
}
sub get_stop {
	return $_[0]->{STOP};
}
sub get_internalID {
	return $_[0]->{INTERNAL_ID};
}
sub get_sequence {
	return $_[0]->{SEQUENCE};
}
sub get_species {
	return $_[0]->{SPECIES};
}
sub get_extra {
	return $_[0]->{EXTRA};
}
sub get_length {
	return $_[0]->{STOP}-$_[0]->{START}+1
}
sub get_matures {
	if (defined $_[0]->{MATURES}) {
		if (defined $_[1]) {
			return ${$_[0]->{MATURES}}[$_[1]]; #return the requested mature
		}
		else {
			return $_[0]->{MATURES}; # return the array reference
		}
	}
	else {
		return [];
	}
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_name {
	$_[0]->{NAME} = $_[1] if defined $_[1];
}
sub set_mima {
	$_[0]->{MIMA} = $_[1] if defined $_[1];
}
sub set_start {
	$_[0]->{START} = $_[1] if defined $_[1];
}
sub set_stop {
	$_[0]->{STOP} = $_[1] if defined $_[1];
}
sub set_internalID {
	$_[0]->{INTERNAL_ID} = $_[1] if defined $_[1];
}
sub set_extra {
	$_[0]->{EXTRA} = $_[1] if defined $_[1];
}
sub set_species {
	$_[0]->{SPECIES} = uc($_[1]) if defined $_[1];
}
sub set_matures {
	$_[0]->{MATURES} = $_[1] if defined $_[1];
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
sub set_sequence {
	my ($self,$value) = @_;
	if (defined $value) {
		unless ($value =~ /^[ATGCU]*$/i) {
			$value =~ /([^ATGCU])/i;
			warn "The nucleotide sequence provided for ".$self->get_name()." contains the following invalid characters $1 in $self\n";
		}
		unless ($self->{SEQUENCE}) {$self->{SEQUENCE} = '';}
		$self->{SEQUENCE} .= $value;
	}
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub push_mature {
	push (@{$_[0]->{MATURES}},$_[1]) if defined $_[1];
}

#######################################################################
##########################   Class Methods   ##########################
#######################################################################
{
	my %allHairpins; #2D hash containing all instances of the class (the first key defines the accessor key NAME, INTERNAL_ID etc)
	
	sub _add_to_all {
		my ($class,$obj) = @_;
		$allHairpins{NAME}{$obj->get_name} = $obj;
		$allHairpins{INTERNAL_ID}{$obj->get_internalID} = $obj;
	}
	
	sub _delete_from_all {
		my ($class,$obj) = @_;
		delete $allHairpins{NAME}{$obj->get_name};
		delete $allHairpins{INTERNAL_ID}{$obj->get_internalID};
	}
	
	sub get_all {
		my ($class,$primary_key_class) = @_;
		if ((!defined $primary_key_class) or ($primary_key_class eq 'NAME')) {
			return %{$allHairpins{NAME}};
		}
		elsif ($primary_key_class eq 'INTERNAL_ID') {
			return %{$allHairpins{INTERNAL_ID}};
		}
		else {
			warn "$class does not have an accessor with the primary key \"$primary_key_class\"\n";
		}
		
	}
	
	sub delete_all {
		my ($class) = @_;
		%allHairpins = ();
	}
	
	sub get_by_name {
		my ($class,$name) = @_;
		if (exists $allHairpins{NAME}{$name}) {
			return $allHairpins{NAME}{$name};
		}
		else {
			return $class->create_new_hairpin_from_database($name);
		}
	}
	
	sub read_hairpins {
		my ($class,$method,@attributes) = @_;
		
		if ($method eq "BEDFILE") {
			my $filename = $attributes[0];
			return $class->_read_bedfile_with_hairpins($filename);
		}
		elsif ($method eq "FASTA") {
			my $filename = $attributes[0];
			return $class->_read_fasta_with_hairpins($filename);
		}
		elsif ($method eq "GENBANK") {
			my $filename = $attributes[0];
			return $class->_read_genbank_with_hairpins($filename);
		}
	}
	
	sub _read_bedfile_with_hairpins {
		my ($class,$file)=@_;
		
		my $hairpin;
		open (my $BED,"<",$file) or die "Cannot open file $file: $!";
		while (my $line=<$BED>){
			chomp($line);
			if (substr($line,0,1) ne '#') {
				my ($chr,$start,$stop,$name,$score,$strand) = split(/\t/,$line);
				
				if (!exists $allHairpins{NAME}{$name}) {
					$hairpin = $class->new({
								NAME             => $name,
								STRAND           => $strand,
								CHR              => $chr,
								START            => $start,
								STOP             => $stop,
								EXTRA            => $score,
								});
				}
				else {
					$allHairpins{NAME}{$name}->set_strand($strand);
					$allHairpins{NAME}{$name}->set_chr($chr);
					$allHairpins{NAME}{$name}->set_start($start);
					$allHairpins{NAME}{$name}->set_stop($stop);
					$allHairpins{NAME}{$name}->set_extra($score);
				}
			}
		}
		close $BED;
		
		return %allHairpins;
	}
	
	sub _read_fasta_with_hairpins {
		
		my ($class,$file)=@_;
		
		my $hairpinObj;
		
		open (my $FASTA,"<",$file) or die "Cannot open file $file: $!";
		while (my $line=<$FASTA>){
			chomp($line);
			$line =~ s/\*+/-star/g;
			if (substr($line,0,1) eq '>') {
				$line = substr($line,1);
				my ($name,$mima,$speciesFamily,$speciesSpecies,@junk) = split(/\s+/,$line);
				my $species = uc($speciesFamily." ".$speciesSpecies);
				
				if (!exists $allHairpins{NAME}{$name}) {
					$hairpinObj = $class->new({
								NAME             => $name,
								MIMA             => $mima,
								SPECIES          => $species,
								});
				}
				else {
					$allHairpins{NAME}{$name}->set_mima($mima);
					$allHairpins{NAME}{$name}->set_species($species);
					$hairpinObj = $allHairpins{NAME}{$name};
				}
			}
			elsif (substr($line,0,1) ne '#') {
				$hairpinObj->set_sequence($line);
			}
		}
		close $FASTA;
		
		return %allHairpins;
	}
	
	sub _read_genbank_with_hairpins {
		my ($class,$file)=@_;
		
		my $hairpin;
		open (my $GENBANK,"<",$file) or die "Cannot open file $file: $!";
		while (my $line=<$GENBANK>){
			chomp($line);
			my $line_indicator = substr($line,0,2);
			
			if ($line_indicator eq "ID") {
				my $name = (split(/\s+/,$line))[1];
				if (!exists $allHairpins{NAME}{$name}) {
					$hairpin = $class->new({
								NAME             => $name,
								});
				}
				else {
					$hairpin = $allHairpins{NAME}{$name};
				}
			}
			elsif ($line_indicator eq "AC") {
				my $mima = (split(/\s+/,$line))[1];
				$mima =~ s/\W//gi;
				$hairpin->set_mima($mima);
			}
			elsif ($line_indicator eq "DE") {
				my ($speciesFamily,$speciesSpecies) = (split(/\s+/,$line))[1,2];
				my $species = uc($speciesFamily." ".$speciesSpecies);
				$hairpin->set_species($species);
			}
			elsif ($line_indicator eq "FT") {
				if ($line =~ /\/product="(.+)"/) {
					my $mimat_name = $1;
					$mimat_name =~ s/\*+/-star/g;
					my $mimatObj = Mirna::Mimat->get_by_name($mimat_name);
					if ($mimatObj) {
						$hairpin->push_mature($mimatObj);
					}
				}
			}
		}
		close $GENBANK;
		
		return %allHairpins;
	}
	
	########################################## database ##########################################
	my $DBconnector;
	my $allowDatabaseAccess;
	my $select_all_from_hairpins_where_name;
	my $select_all_from_hairpins_where_name_Query = qq/SELECT * FROM diana_hairpin_mirnas WHERE diana_hairpin_mirnas.name=?/;
	
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
				print STDERR 'Would you like to enable database access to retrieve mirna hairpin data? (y/n) [y]';
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
					print STDERR "\nRequesting database connector with name \"hairpin\"\n";
					$DBconnector = DBconnector->get_dbconnector("hairpin");
				}
			}
		}
		return $DBconnector;
	}
	
	sub create_new_hairpin_from_database {
		my ($class,$name) = @_;
		
		my $DBconnector = $class->get_global_DBconnector();
		if (defined $DBconnector) {
			my $dbh = $DBconnector->get_handle();
			unless (defined $select_all_from_hairpins_where_name) {
				$select_all_from_hairpins_where_name = $dbh->prepare($select_all_from_hairpins_where_name_Query);
			}
			$select_all_from_hairpins_where_name->execute($name);
			my $fetch_hash_ref = $select_all_from_hairpins_where_name->fetchrow_hashref;
			$select_all_from_hairpins_where_name->finish(); # there should be only one result so I have to indicate that fetching is over
			
			if (defined $$fetch_hash_ref{internal_hairpin_id}) {
				my $hairpin = $class->new({
							   INTERNAL_ID      => $$fetch_hash_ref{internal_hairpin_id},
							   NAME             => $$fetch_hash_ref{name},
							   MIMA             => $$fetch_hash_ref{mima_id},
							   SPECIES          => $$fetch_hash_ref{species},
							   STRAND           => $$fetch_hash_ref{strand},
							   CHR              => $$fetch_hash_ref{chromosome},
							   START            => $$fetch_hash_ref{start},
							   STOP             => $$fetch_hash_ref{stop},
							   SEQUENCE         => $$fetch_hash_ref{sequence},
							});
				return $hairpin;
			}
			else {
				warn "Hairpin \"$name\" could not be found in database. Please check that the hairpin already exists\n";
				return undef;
			}
			
		}
	}
	
}







1;
