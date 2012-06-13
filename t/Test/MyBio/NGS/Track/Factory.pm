package Test::MyBio::NGS::Track::Factory;
use strict;

use base qw(Test::MyBio);
use Test::Most;


#######################################################################
################   Startup (Runs once in the begining  ################
#######################################################################
sub _check_loading : Test(startup => 1) {
	my ($self) = @_;
	use_ok $self->class;
}

#######################################################################
###########################   Other Tests   ###########################
#######################################################################
sub constructor : Test(5) {
	my ($self) = @_;
	
	can_ok $self->class, 'new';
	
	$self->new_legitimate_type('GFF');
	
	$self->new_unsupported_type('unsupported');
	$self->new_unsupported_type(undef);
	
}

sub instantiate : Test(5) {
	my ($self) = @_;
	
	can_ok $self->class, 'instantiate';
	
	$self->instantiate_legitimate_type('GFF');
	
	$self->instantiate_unsupported_type('unsupported');
	$self->instantiate_unsupported_type(undef);
	
}


#######################################################################
#############################   Methods   #############################
#######################################################################
sub new_legitimate_type {
	my ($self, $type) = @_;
	
	ok my $obj = $self->class->new({
		TYPE => $type,
	}), '... and the constructor succeeds';
	isa_ok $obj, $self->class."::$type", "... and the instantiated object";
}

sub new_unsupported_type {
	my ($self, $type) = @_;
	
	dies_ok {$self->class->new($type)} '... and the constructor should throw an exception';
}

sub instantiate_legitimate_type {
	my ($self, $type) = @_;
	
	ok my $obj = $self->class->instantiate({
		TYPE => $type,
	}), '... and the constructor succeeds';
	isa_ok $obj, $self->class."::$type", "... and the instantiated object";
}

sub instantiate_unsupported_type {
	my ($self, $type) = @_;
	
	dies_ok {$self->class->instantiate($type)} '... and the constructor should throw an exception';
}

1;
