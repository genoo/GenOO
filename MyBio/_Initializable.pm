package MyBio::_Initializable;

use warnings;
use strict;

our $VERSION = '1.0';

sub new {
	my ($class,$args) = @_;
	my $self = {};
	bless ($self, $class);
	$self->_init($args);
	
	return $self;
};

1;