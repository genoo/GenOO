package Test::GenOO::Transcript;
use strict;

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
sub id : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'id');
	is $self->obj(0)->id, 'uc007hzr.1', "... and returns the correct value";
}

sub biotype : Test(3) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'biotype');
	is $self->obj(0)->biotype, 'coding', "... and returns the correct value";
	is $self->obj(1)->biotype, 'non coding', "... and returns the correct value";
}

sub coding_start : Test(3) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'coding_start');
	is $self->obj(0)->coding_start, 8896852, "... and returns the correct value";
	is $self->obj(1)->coding_start, undef, "... and returns the correct value";
}

sub coding_stop : Test(3) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'coding_stop');
	is $self->obj(0)->coding_stop, 8911112, "... and returns the correct value";
	is $self->obj(1)->coding_stop, undef, "... and returns the correct value";
}

sub gene : Test(1) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'gene');
}

sub utr5 : Test(4) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'utr5');
	isa_ok $self->obj(0)->utr5, 'GenOO::Transcript::UTR5', "... and returns the correct value";
	is $self->obj(0)->utr5->start, 8911113, "... and returns the correct value";
	is $self->obj(0)->utr5->stop, 8911139, "... and returns the correct value";
}

sub cds : Test(4) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'cds');
	isa_ok $self->obj(0)->cds, 'GenOO::Transcript::CDS', "... and returns the correct value";
	is $self->obj(0)->cds->start, 8896852, "... and returns the correct value";
	is $self->obj(0)->cds->stop, 8911112, "... and returns the correct value";
}

sub utr3 : Test(4) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'utr3');
	isa_ok $self->obj(0)->utr3, 'GenOO::Transcript::UTR3', "... and returns the correct value";
	is $self->obj(0)->utr3->start, 8893144, "... and returns the correct value";
	is $self->obj(0)->utr3->stop, 8896851, "... and returns the correct value";
}

sub is_coding : Test(3) {
	my ($self) = @_;
	
	can_ok($self->obj(0), 'is_coding');
	is $self->obj(0)->is_coding, 1, "... and returns the correct value";
	is $self->obj(1)->is_coding, 0, "... and returns the correct value";
}

sub exons_split_by_function : Test(2) {
	my ($self) = @_;
	
	can_ok($self->obj(0), 'exons_split_by_function');
	is @{$self->obj(0)->exons_split_by_function}, 10, "... and returns the correct value";
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self, $index) = @_;
	
	return $self->{TEST_OBJECTS}->[$index];
}

sub objs {
	my ($self) = @_;
	
	return @{$self->{TEST_OBJECTS}};
}


#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	
	my @test_objects;
	
	push @test_objects, $test_class->class->new(
		id             => 'uc007hzr.1',
		strand         => -1,
		chromosome     => 'chr11',
		start          => 8893144,
		stop           => 8911139,
		splice_starts  => [
					8893144,
					8898639,
					8900079,
					8905991,
					8907496,
					8910243,
					8910499,
					8911061
				],
		splice_stops   => [
					8896934,
					8898758,
					8900178,
					8906065,
					8907603,
					8910419,
					8910626,
					8911139
				],
		coding_start   => 8896852,
		coding_stop    => 8911112,
		biotype        => 'coding',
	);
	
	push @test_objects, $test_class->class->new(
		id             => 'uc007gqc.1',
		strand         => 1,
		chromosome     => 'chr10',
		start          => 86086601,
		stop           => 86086630,
		splice_starts  => [86086601],
		splice_stops   => [86086630],
		biotype        => 'non coding',
	);
	
	return \@test_objects;
}

1;
