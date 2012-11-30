# POD documentation - main docs before the code

=head1 NAME

GenOO::DBconnector - Connector to database object, with features

=head1 SYNOPSIS

    # This is an object that manages a connection to the database
    # Currently it is designed only for MySQL databases
    
    # To initialize 
    my $dbconn = GenOO::DBconnector->new({
        NAME        => undef,
        HOST        => undef,
        DATABASE    => undef,
        USER        => undef,
        PASSWORD    => undef,
    });

=head1 DESCRIPTION

    Not provided yet

=head1 EXAMPLES

    my $dbConn = DBconnector->new(["core","localhost","database","user","pass"]);
    my $dbh = DBconnector->get_handle_for_dbconnector("core");

=head1 AUTHOR - Manolis Maragkakis

Email maragkakis@fleming.gr

=cut

# Let the code begin...

package GenOO::DBconnector;
use strict;

use DBI;

use base qw( GenOO::_Initializable );

sub _init {
	my ($self,$data) = @_;
	
	$self->{NAME}       = $$data[0];
	$self->{HOST}       = $$data[1];
	$self->{DATABASE}   = $$data[2];
	$self->{USER}       = $$data[3];
	$self->{PASSWORD}   = $$data[4];
	
	$self->_check_init();
	$self->request_username_password();
	$self->connect();
	
	my $class = ref($self) || $self;
	$class->_add_to_all($self);
	
	return $self;
}

sub _check_init {
	my ($self) = @_;
	
	$self->check_name();
	$self->check_host();
	$self->check_database();
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_host      {return $_[0]->{HOST};}
sub get_database  {return $_[0]->{DATABASE};}
sub get_user      {return $_[0]->{USER};}
sub get_password  {return $_[0]->{PASSWORD};}
sub get_name      {return $_[0]->{NAME};}
sub get_handle    {return $_[0]->{HANDLE};}


#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_host     {$_[0]->{HOST} = $_[1] if defined $_[1];}
sub set_database {$_[0]->{DATABASE} = $_[1] if defined $_[1];}
sub set_user     {$_[0]->{USER} = $_[1] if defined $_[1];}
sub set_password {$_[0]->{PASSWORD} = $_[1] if defined $_[1];}
sub set_name     {$_[0]->{NAME} = $_[1] if defined $_[1];}
sub set_handle   {$_[0]->{HANDLE} = $_[1] if defined $_[1];}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub connect() {
	my ($self) = @_;
	
	my $dbh = DBI->connect("DBI:mysql:database=".$self->get_database().";host=".$self->get_host(), $self->get_user, $self->get_password()) or die "Can't connect to mysql database: $DBI::errstr\n";
	$self->set_handle($dbh);
}

sub disconnect() {
	my ($self) = @_;
	
	$self->get_handle->disconnect;
}

sub check_name {
	my ($self) = @_;
	
	unless ($self->get_name()) {
		print STDERR 'Specify a name for the DBconnector [core]';
		my $name = <>;
		chomp($name);
		if ($name) {
			$self->set_name($name);
		}
		else {
			$self->set_name("core");
		}
	}
}

sub check_host {
	my ($self) = @_;
	
	unless ($self->get_host()) {
		print STDERR 'Specify host name for the DBconnector [localhost]';
		my $host = <>;
		chomp($host);
		if ($host) {
			$self->set_host($host);
		}
		else {
			$self->set_host("localhost");
		}
	}
}

sub check_database {
	my ($self) = @_;
	
	unless ($self->get_database()) {
		print STDERR 'Specify a database for the DBconnector [mirna2]';
		my $database = <>;
		chomp($database);
		if ($database) {
			$self->set_database($database);
		}
		else {
			$self->set_database("mirna2");
		}
	}
}

sub request_username_password {
	my ($self) = @_;
	
	unless ($self->get_user() and $self->get_password()) {
		print STDERR "\n".'Specify username and password for DBconnector "'.$self->get_name().'" at '.$self->get_database().'@'.$self->get_host()."\n";
		print STDERR 'username:';
		my $user = <>;
		print STDERR 'password:';
		my $password = <>;
		chomp($user);
		chomp($password);
		$self->set_user($user);
		$self->set_password($password);
	}
}

#######################################################################
##########################   Class Methods   ##########################
#######################################################################
{
	my %dbConnectors;
	my $globalAccessPolicy = 'DENY';
	
=head2 global_access

  Example    : my $accessPolicy = GenOO::DBconnector->global_access();
  Description: Class method that returns whether access to the database is allowed or not
  Returntype : ALLOW / DENY
  Caller     : ?
  Status     : Under development

=cut
	sub global_access {
		my ($class) = @_;
		
		while (!defined $globalAccessPolicy) {
			print STDERR 'Would you like to enable automatic database access to retrieve data? (y/n) [n]';
			my $userChoice = <>;
			chomp ($userChoice);
			if    ($userChoice eq '')  {$class->deny_global_access;}
			elsif ($userChoice eq 'y') {$class->allow_global_access;}
			elsif ($userChoice eq 'n') {$class->deny_global_access;}
			else {print STDERR 'Choice not recognised. Please specify (y/n)'."\n";}
		}
		
		return $globalAccessPolicy;
	}
	
	sub allow_global_access {
		$globalAccessPolicy = 'ALLOW';
	}
	
	sub deny_global_access {
		$globalAccessPolicy = 'DENY';
	}
	
	sub _add_to_all {
		my ($class,$obj) = @_;
		$dbConnectors{$obj->get_name} = $obj;
	}
	
	sub exists {
		my ($class,$connectorName) = @_;
		if (exists $dbConnectors{$connectorName}) {
			return 1;
		}
		else {
			return 0;
		}
	}
	
	sub get_dbconnector {
		my ($class,$connectorName) = @_;
		if (exists $dbConnectors{$connectorName}) {
			return $dbConnectors{$connectorName};
		}
		else {
			my $dbConnector = $class->dbconnector_not_found($connectorName);
			return $dbConnector;
		}
	}
	
	sub get_handle_for_dbconnector {
		my ($class,$connectorName) = @_;
		if (exists $dbConnectors{$connectorName}) {
			return $dbConnectors{$connectorName}->get_handle();
		}
		else {
			my $dbConnector = $class->dbconnector_not_found($connectorName);
			if (defined $dbConnector) {
				return $dbConnector->get_handle();
			}
			else {
				return;
			}
		}
	}
	
	sub dbconnector_not_found {
		my ($class,$connectorName) = @_;
		
		my $dbConnector;
		print STDERR "\nThe requested dbConnector \"$connectorName\" could not be found.\nWould you like to create it now? (y/n) [y]";
		my $userChoice = <>;
		chomp ($userChoice);
		if    ($userChoice eq '')  {$dbConnector = $class->new([$connectorName]);}
		elsif ($userChoice eq 'y') {$dbConnector = $class->new([$connectorName]);}
		elsif ($userChoice eq 'n') {}
		else {}
		
		return $dbConnector;
	}

}

1;
