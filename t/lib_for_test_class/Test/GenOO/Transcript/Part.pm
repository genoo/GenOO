package Test::GenOO::Transcript::Part;
use strict;

use base qw(Test::GenOO);
use Test::Most;
use Test::Moose; 

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
#######################   Class Interface Tests   #####################
#######################################################################
sub is_position_within_exon : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'is_position_within_exon';
	is $self->obj(0)->is_position_within_exon(10), 1, "... and returns the correct value";
	is $self->obj(0)->is_position_within_exon(51), 0, "... and returns the correct value";
}

sub is_position_within_intron : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'is_position_within_intron';
	is $self->obj(0)->is_position_within_intron(51), 1, "... and returns the correct value";
	is $self->obj(0)->is_position_within_intron(10), 0, "... and returns the correct value";
}

sub exon_exon_junctions : Test(3) {
	my ($self) = @_;
	can_ok $self->obj(0), 'exon_exon_junctions';
	my $junctions_array = $self->obj(0)->exon_exon_junctions;
	is @{$junctions_array}, 3, "... and returns the correct value";
	isa_ok $$junctions_array[0], 'GenOO::Junction', "... and is the correct type";
}

sub exonic_sequence : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'exonic_sequence';
	is $self->obj(0)->exonic_sequence, 'CAAAAACACCCAGGCTTCCTGGTCTTTAATGTCACACCATGGACACCAACATCCCACTGGTTTGTTACCATATTAGCAGCACTTTATTGTATTGCATTAGGACTAAGCTTTGATTATAACCTTCAAGCTTTCCCACGGATAGTAAATAGCCAAGTGACCTTCAGGACATTGGTTCTTAGTTTAACACTGTTTTTAGAAGAAAAATGACCAACTCATGCTCCCT', "... and returns the correct value";
}

sub exonic_length : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'exonic_length';
	is $self->obj(0)->exonic_length(), 223, "... and returns the correct value";
}

sub intronic_length : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'intronic_length';
	is $self->obj(0)->intronic_length(), 177, "... and returns the correct value";
}

sub relative_exonic_position : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'relative_exonic_position';
	is $self->obj(0)->relative_exonic_position(20), 19, "... and returns the correct value";
	is $self->obj(0)->relative_exonic_position(55), undef, "... and returns the correct value"; #this is in an intron
}


#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	
	my @test_objects;
	
	push @test_objects, $test_class->class->new({
		strand         => -1,
		chromosome     => 'chr11',
		start          => 1,
		stop           => 400,
		splice_starts  => [
					1,
					200,
					100,
					300,
				],
		splice_stops   => [
					50,
					400,
					150,
					220,
				],
		species       => 'mm9',
		sequence      => 'AGTTAAATTATAAATATTTATTTCATTCTATAAAAATATTGTCATTACAATGTTGGTTGTGAAATTGTTAGAAAATACACAAATATAAAAAGACTGAAGTCAAAAACACCCAGGCTTCCTGGTCTTTAATGTCACACCATGGACACCAACATCCCACTGGTTTGTTACCATATTAGCAGCACTTTATTGTATTGCATTAGGGTATGATATTACATCACAGCACAGATTATCTACCAATTCCCTGTTCATTCACATTAGGAAATTTCTTATTTATAACAGTACTAAGCTTTGATTATAACCTGTGTTAAATGACTCTTACAAGCATAAGTATTAAGTCAAAGGAAGCAGTTTCAAGCTTTCCCACGGATAGTAAATAGCCAAGTGACCTTCAGGACATTGGTACTAACACCCCTCCTACCATCAATGTCCAAATGATTCTAATTTATCATCTCTTAGTTTAACACTGTTTTTAGAAGAAAAATGACCAACTCATGCTCCCT'
	});
	
	push @test_objects, $test_class->class->new({
		strand         => 1,
		chromosome     => 'chr10',
		start          => 86086601,
		stop           => 86086630,
		splice_starts  => [86086601],
		splice_stops   => [86086630],
		species        => 'mm9',
	});
	
	return \@test_objects;
}

1;
