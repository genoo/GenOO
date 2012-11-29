# POD documentation - main docs before the code

=head1 NAME

MyBio::DB::Connector - Connector to database object, with features

=head1 SYNOPSIS

    # Initializes a connection to a user provided database through perl DBI
    my $dbconn = MyBio::DB::Connector->new({
        driver   => undef,
        host     => undef,
        database => undef,
        user     => undef,
        port     => undef,
    });

=head1 DESCRIPTION

    Not provided yet

=head1 EXAMPLES

    # Get the DBI handle
    my $dbh = $dbconn->handle;
    $dbh->do("CREATE TABLE foo")

=cut

# Let the code begin...

package MyBio::Data::DB::Connector;

use Moose;
use namespace::autoclean;

use DBI;

has 'driver'   => (isa => 'Str', is => 'ro', required => 1);
has 'host'     => (isa => 'Str', is => 'ro', required => 1);
has 'database' => (isa => 'Str', is => 'ro', required => 1);
has 'user'     => (isa => 'Str', is => 'ro');
has 'password' => (isa => 'Str', is => 'ro');
has 'port'     => (isa => 'Int', is => 'ro', builder => '_default_port');
has 'handle'   => (is => 'ro', writer => '_set_handle');
has 'extra'    => (is => 'rw');

sub BUILD {
	my $self = shift;

	my $dbh = DBI->connect(
		'DBI:'.$self->driver.':database='.$self->database.';'.
		'host='.$self->host.';'.
		'port='.$self->port.';',
		$self->user,
		$self->password
	) or die "Can't connect to mysql database: $DBI::errstr\n";
	
	$self->_set_handle($dbh);
}

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub disconnect() {
	my ($self) = @_;
	$self->handle->disconnect;
}

#######################################################################
#########################   Private methods  ##########################
#######################################################################
sub _default_port {
	return '3306';
}

__PACKAGE__->meta->make_immutable;
1;
