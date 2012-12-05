package Test::GenOO::Transcript::CDS;
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

sub get_cds_start_locus : Test(5) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_cds_start_locus';
	is $self->obj(0)->get_cds_start_locus->start, '200', "... and returns the correct value";
	is $self->obj(0)->get_cds_start_locus->chromosome, 'chr11', "... and returns the correct value";
	is $self->obj(0)->get_cds_start_locus->stop, '200', "... and returns the correct value";
	is $self->obj(0)->get_cds_start_locus->strand, '-1', "... and returns the correct value";
}


sub whatami : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'whatami';
	is $self->obj(0)->whatami, 'CDS', "... and returns the correct value";
}

#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	
	my @test_objects;
	
	push @test_objects, $test_class->class->new({
		START            => 100,
		STOP             => 200,
		CHR              => 'chr11',
		STRAND           => -1,
		TRANSCRIPT       => undef,
		SPLICE_STARTS    => undef,
		SPLICE_STOPS     => undef,
		LENGTH           => undef,
		SEQUENCE         => undef,
		ACCESSIBILITY    => undef,
		CONSERVATION     => undef,
		EXTRA_INFO       => undef,
	});
	
	return \@test_objects;
}

1;
 
 
