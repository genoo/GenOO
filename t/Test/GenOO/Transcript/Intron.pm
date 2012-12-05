package Test::GenOO::Transcript::Intron;
use strict;

use base qw(Test::GenOO);
use Test::Most;

#######################################################################
################   Startup (Runs once in the begining  ################
#######################################################################
sub _check_loading : Test(startup => 1) {
	my ($self) = @_;
	use_ok $self->class;
};

#######################################################################
#################   Setup (Runs before every method)  #################
#######################################################################
sub create_new_test_objects : Test(setup) {
	my ($self) = @_;
	
	my $test_class = ref($self) || $self;
	$self->{TEST_OBJECTS} = $test_class->test_objects();
};

#######################################################################
##########################   Initial Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	isa_ok $self->obj(0), $self->class, "... and the object";
}

#######################################################################
#######################   Class Interface Tests   #####################
#######################################################################
sub whatami : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'whatami';
	is $self->obj(0)->whatami, 'Intron', "... and returns the correct value";
}

#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	
	my @test_objects;
	
	push @test_objects, $test_class->class->new({
		SPECIES      => undef,
		STRAND       => undef,
		CHR          => undef,
		START        => undef,
		STOP         => undef,
		SEQUENCE     => undef,
		WHERE     => undef,
		EXTRA_INFO   => undef,
	});
	
	return \@test_objects;
}

1;
 
 
 
