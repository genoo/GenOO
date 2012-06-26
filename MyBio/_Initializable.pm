package MyBio::_Initializable;

use strict;

our $VERSION = '1.0';

sub new {
	my ($class,$args) = @_;
	my $self = {};
	bless ($self, $class);
	$self->_init($args);
	
	return $self;
};

sub set_extra {
	$_[0]->{EXTRA_INFO} = $_[1] if defined $_[1];
}

sub extra {
	return $_[0]->{EXTRA_INFO};
}

sub get_extra {
	return $_[0]->extra;
}

1;