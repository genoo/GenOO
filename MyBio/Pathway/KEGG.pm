package Pathway::KEGG;

# This object describes a KEGG pathway.

use strict;
use Scalar::Util qw/weaken/;

use MyBio::_Initializable;
use MyBio::DBconnector;

our @ISA = qw( MyBio::_Initializable);

# HOW TO INITIALIZE THIS OBJECT
# my $kegg_pathway = Pathway::KEGG->new({
# 		     KEGG_ID       => undef,
# 		     DESCRIPTION   => undef,
# 		     GENES         => undef,
# 		     URL           => undef,
# 		     INTERNAL_ID   => undef,
# 		     SPECIES       => undef,
# 		     EXTRA_INFO    => undef,
# 		     });

sub _init {
	my ($self,$data) = @_;
	
	$self->set_keggid($$data{KEGG_ID});
	$self->set_description($$data{DESCRIPTION});
	$self->set_genes($$data{GENES});
	$self->set_url($$data{URL});
	$self->set_internalID($$data{INTERNAL_ID});
	$self->set_species($$data{SPECIES});
	$self->set_extra($$data{EXTRA_INFO});
	
	my $class = ref($self) || $self;
	$class->_add_to_all($self);
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_keggid {
	return $_[0]->{KEGG_ID};
}
sub get_name {
# Till a pathway name is explicitely defined in KEGG the description is being used
	return $_[0]->{DESCRIPTION};
}
sub get_description {
	return $_[0]->{DESCRIPTION};
}
sub get_genes {
	if (defined $_[1]) {
		return ${$_[0]->{GENES}}[$_[1]]; #return the requested element
	}
	else {
		return $_[0]->{GENES}; #return the reference to the array
	}
}
sub get_url {
	return $_[0]->{URL};
}
sub get_internalID {
	return $_[0]->{INTERNAL_ID};
}
sub get_species {
	return $_[0]->{SPECIES};
}
sub get_extra {
	return $_[0]->{EXTRA_INFO};
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_keggid {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{KEGG_ID} = $value;
	}
}
sub set_description {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{DESCRIPTION} = $value;
	}
}
sub set_genes {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{GENES} = $value;
	}
}
sub set_url {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{URL} = $value;
	}
}
sub set_internalID {
	$_[0]->{INTERNAL_ID} = $_[1] if defined $_[1];
}
sub set_species {
	$_[0]->{SPECIES} = uc($_[1]) if defined $_[1];
}
sub set_extra {
	$_[0]->{EXTRA_INFO} = $_[1] if defined $_[1];
}

#######################################################################
#########################   General Methods   #########################
#######################################################################

#######################################################################
##########################   Class Methods   ##########################
#######################################################################
{
	my %allKeggPathways;
	
	sub _add_to_all {
		my ($class,$obj) = @_;
		$allKeggPathways{$obj->get_keggid} = $obj;
	}
	
	sub _delete_from_all {
		my ($class,$obj) = @_;
		delete $allKeggPathways{$obj->get_keggid};
	}
	
	sub get_all {
		my ($class) = @_;
		return %allKeggPathways;
	}
	
	sub delete_all {
		my ($class) = @_;
		%allKeggPathways = ();
	}
	
	sub get_by_keggid {
		my ($class,$keggid) = @_;
		if (exists $allKeggPathways{$keggid}) {
			return $allKeggPathways{$keggid};
		}
		else {
			return $class->create_new_kegg_pathway_from_database($keggid);
		}
	}
	
	sub read_kegg_pathways {
		my ($class,$method,@attributes) = @_;
		
		if ($method eq "FILE") {
			my $filekeggid = $attributes[0];
			return $class->_read_file_with_kegg_pathways($filekeggid);
		}
	}
	
	sub _read_file_with_kegg_pathways {
		my ($class,$file)=@_;
		
		warn "The method \"_read_file_with_kegg_pathways\" has not been implemented in $class\n";
		
		return %allKeggPathways;
	}
	
	########################################## database ##########################################
	my $DBconnector;
	my $accessPolicy = MyBio::DBconnector->global_access();
	my $select_all_from_kegg_pathways_where_keggid;
	my $select_all_from_kegg_pathways_where_keggid_Query = qq/SELECT * FROM diana_keggs WHERE diana_keggs.kegg_id=?/;
	
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
	
	sub create_new_kegg_pathway_from_database {
		my ($class,$keggid) = @_;
		
		my $DBconnector = $class->get_db_connector();
		if (defined $DBconnector) {
			my $dbh = $DBconnector->get_handle();
			unless (defined $select_all_from_kegg_pathways_where_keggid) {
				$select_all_from_kegg_pathways_where_keggid = $dbh->prepare($select_all_from_kegg_pathways_where_keggid_Query);
			}
			$select_all_from_kegg_pathways_where_keggid->execute($keggid);
			my $fetch_hash_ref = $select_all_from_kegg_pathways_where_keggid->fetchrow_hashref;
			$select_all_from_kegg_pathways_where_keggid->finish(); # there should be only one result so I have to indicate that fetching is over
			
			if (defined $$fetch_hash_ref{internal_kegg_tid}) {
				my $kegg_pathway = $class->new({
							   INTERNAL_ID      => $$fetch_hash_ref{internal_kegg_tid},
							   KEGG_ID          => $$fetch_hash_ref{kegg_id},
							   DESCRIPTION      => $$fetch_hash_ref{enstid},
							   URL              => $$fetch_hash_ref{species},
							});
				return $kegg_pathway;
			}
			else {
				warn "KEGG pathway \"$keggid\" could not be found in database. Please check that the KEGG pathway already exists\n";
				return undef;
			}
			
		}
	}
	
}

1;