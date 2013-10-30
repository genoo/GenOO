package Test::GenOO::Transcript::UTR5;
use strict;

use Test::GenOO::Transcript::Part;

use base qw(Test::GenOO);
use Test::Moose;
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

#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	
	my @test_objects;
	my @test_parts = @{Test::GenOO::Transcript::Part->test_objects()};
	my $test_part = $test_parts[0];
	push @test_objects, $test_class->class->new({
		strand         => $test_part->strand,
		chromosome     => $test_part->chromosome,
		start          => $test_part->start,
		stop           => $test_part->stop,
		splice_starts  => $test_part->splice_starts,
		splice_stops   => $test_part->splice_stops,
		species        => $test_part->species,
	});
	
	return \@test_objects;
}

1;
 
 
