package Test::GenOO::SplicedLocus;
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
sub get_splice_starts : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_splice_starts';
	is_deeply $self->obj(0)->get_splice_starts, [
					1,
					100,
					200,
					300,
				],, "... and returns the correct value";
}

sub get_splice_stops : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_splice_stops';
	is_deeply $self->obj(0)->get_splice_stops, [
					50,
					150,
					220,
					400,
				], "... and returns the correct value";
}

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

sub get_exon_exon_junctions : Test(3) {
	my ($self) = @_;
	can_ok $self->obj(0), 'get_exon_exon_junctions';
	my @junctions_array = $self->obj(0)->get_exon_exon_junctions;
	is @junctions_array, 3, "... and returns the correct value";
	isa_ok $junctions_array[0], 'GenOO::Junction', "... and is the correct type";
}

sub get_exonic_sequence : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_exonic_sequence';
	is $self->obj(0)->get_exonic_sequence, 'CAAAAACACCCAGGCTTCCTGGTCTTTAATGTCACACCATGGACACCAACATCCCACTGGTTTGTTACCATATTAGCAGCACTTTATTGTATTGCATTAGGACTAAGCTTTGATTATAACCTTCAAGCTTTCCCACGGATAGTAAATAGCCAAGTGACCTTCAGGACATTGGTTCTTAGTTTAACACTGTTTTTAGAAGAAAAATGACCAACTCATGCTCCCT', "... and returns the correct value";
}

sub get_exons : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_exons';
	is @{$self->obj(0)->get_exons}, 4, "... and returns the correct value";
	isa_ok ${$self->obj(0)->get_exons}[0], 'GenOO::Transcript::Exon', "... and is the correct type";
}

sub get_introns : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_introns';
	is @{$self->obj(0)->get_introns}, 3, "... and returns the correct value";
	isa_ok ${$self->obj(0)->get_introns}[0], 'GenOO::Transcript::Intron', "... and is the correct type";
}

sub get_intron_exon_junctions : Test(3) {
	my ($self) = @_;
	can_ok $self->obj(0), 'get_intron_exon_junctions';
	my @junctions_array = $self->obj(0)->get_intron_exon_junctions;
	is @junctions_array, 6, "... and returns the correct value";
	isa_ok $junctions_array[0], 'GenOO::Locus', "... and is the correct type";
}

sub get_exonic_length : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_exonic_length';
	is $self->obj(0)->get_exonic_length(), 223, "... and returns the correct value";
}

sub to_spliced_relative : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'to_spliced_relative';
	is $self->obj(0)->to_spliced_relative(20), 19, "... and returns the correct value";
	is $self->obj(0)->to_spliced_relative(55), undef, "... and returns the correct value"; #this is in an intron
}


#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	
	my @test_objects;
	
	push @test_objects, $test_class->class->new({
		STRAND         => -1,
		CHR            => 'chr11',
		START          => 1,
		STOP           => 400,
		SPLICE_STARTS  => [
					1,
					100,
					300,
					200,
				],
		SPLICE_STOPS   => [
					50,
					400,
					150,
					220,
				],
		SPECIES       => 'mm9',
		SEQUENCE      => 'AGTTAAATTATAAATATTTATTTCATTCTATAAAAATATTGTCATTACAATGTTGGTTGTGAAATTGTTAGAAAATACACAAATATAAAAAGACTGAAGTCAAAAACACCCAGGCTTCCTGGTCTTTAATGTCACACCATGGACACCAACATCCCACTGGTTTGTTACCATATTAGCAGCACTTTATTGTATTGCATTAGGGTATGATATTACATCACAGCACAGATTATCTACCAATTCCCTGTTCATTCACATTAGGAAATTTCTTATTTATAACAGTACTAAGCTTTGATTATAACCTGTGTTAAATGACTCTTACAAGCATAAGTATTAAGTCAAAGGAAGCAGTTTCAAGCTTTCCCACGGATAGTAAATAGCCAAGTGACCTTCAGGACATTGGTACTAACACCCCTCCTACCATCAATGTCCAAATGATTCTAATTTATCATCTCTTAGTTTAACACTGTTTTTAGAAGAAAAATGACCAACTCATGCTCCCT'
	});
	
	push @test_objects, $test_class->class->new({
		STRAND         => 1,
		CHR            => 'chr10',
		START          => 86086601,
		STOP           => 86086630,
		SPLICE_STARTS  => [86086601],
		SPLICE_STOPS   => [86086630],
		SPECIES        => 'mm9',
	});
	
	return \@test_objects;
}

1;
