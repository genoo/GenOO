package Test::GenOO::Gene;
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
##########################   Initial Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	isa_ok $self->obj(0), $self->class, "... and the object";
}

#######################################################################
#######################   Class Interface Tests   #####################
#######################################################################
sub name : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'name', "... test object has the 'name' attribute");
	is $self->obj(0)->name, '2310016C08Rik', "... and returns the correct value";
}

sub description : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'description', "... test object has the 'description' attribute");
	is $self->obj(0)->description, 'hypoxia-inducible gene 2 protein isoform 2', "... and returns the correct value";
}

sub strand : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'strand', "... test object has the 'strand' attribute");
	is $self->obj(0)->strand, 1, "... and returns the correct value";
}

sub chromosome : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'chromosome', "... test object has the 'chromosome' attribute");
	is $self->obj(0)->chromosome, 'chr6', "... and returns the correct value";
}

sub start : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'start', "... test object has the 'start' attribute");
	is $self->obj(0)->start, 29222487, "... and returns the correct value";
}

sub stop : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'stop', "... test object has the 'stop' attribute");
	is $self->obj(0)->stop, 29225448, "... and returns the correct value";
}

sub transcripts : Test(3) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'transcripts', "... test object has the 'transcripts' attribute");
	
	my $transcripts_arrayref = $self->obj(0)->transcripts;
	is @{$transcripts_arrayref}, 2, "... and returns the correct value";
	isa_ok $transcripts_arrayref->[0], 'GenOO::Transcript', "... and returns the correct value";
}

sub coding_transcripts : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'coding_transcripts';
	
	my $transcripts_arrayref = $self->obj(0)->coding_transcripts;
	is @{$transcripts_arrayref}, 2, "... and returns the correct value";
	isa_ok $transcripts_arrayref->[0], 'GenOO::Transcript', "... and returns the correct value";
}

sub non_coding_transcripts : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'non_coding_transcripts';
	
	my $transcripts_arrayref = $self->obj(0)->non_coding_transcripts;
	is @{$transcripts_arrayref}, 0, "... and returns the correct value";
}

sub add_transcript : Test(5) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'add_transcript';
	
	$self->obj(1)->add_transcript($self->obj(0)->transcripts->[1]);
	$self->obj(1)->add_transcript($self->obj(0)->transcripts->[0]);
	
	is $self->obj(1)->strand, 1, "... and returns the correct value";
	is $self->obj(1)->chromosome, 'chr6', "... and returns the correct value";
	is $self->obj(1)->start, 29222487, "... and returns the correct value";
	is $self->obj(1)->stop, 29225448, "... and returns the correct value";
}

sub constitutive_exonic_regions : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'constitutive_exonic_regions';
	
	my $exons_arrayref = $self->obj(0)->constitutive_exonic_regions;
	is @{$exons_arrayref}, 1, "... and returns the correct value";
	isa_ok $exons_arrayref->[0], 'GenOO::GenomicRegion', "... and returns the correct value";
}

sub constitutive_coding_exonic_regions : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'constitutive_coding_exonic_regions';
	
	my $exons_arrayref = $self->obj(0)->constitutive_coding_exonic_regions;
	is @{$exons_arrayref}, 1, "... and returns the correct value";
	isa_ok $exons_arrayref->[0], 'GenOO::GenomicRegion', "... and returns the correct value";
}

sub has_coding_transcript : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'has_coding_transcript';
	is $self->obj(0)->has_coding_transcript, 1, "... and returns the correct value";
}

sub exonic_regions : Test(8) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'exonic_regions';
	
	my @exonic_regions = @{$self->obj(0)->exonic_regions};
	is @exonic_regions, 3, "... and returns the correct value";
	is $exonic_regions[0]->start, 29222487, "... and returns the correct value";
	is $exonic_regions[0]->stop, 29222607, "... and returns the correct value";
	is $exonic_regions[1]->start, 29222625, "... and returns the correct value";
	is $exonic_regions[1]->stop, 29222809, "... and returns the correct value";
	is $exonic_regions[2]->start, 29224649, "... and returns the correct value";
	is $exonic_regions[2]->stop, 29225448, "... and returns the correct value";
}

sub exonic_length : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'exonic_length';
	is $self->obj(0)->exonic_length, 1106, "... and returns the correct value";
}

#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	eval "require GenOO::Transcript";
	
	my @test_objects;
	
	push @test_objects, $test_class->class->new(
		name        => '2310016C08Rik',
		strand      => '1',
		chromosome  => 'chr6',
		start       => 29222487,
		stop        => 29225448,
		description => 'hypoxia-inducible gene 2 protein isoform 2',
		transcripts => [
				GenOO::Transcript->new(
					id            => 'uc012eiw.1',
					strand        => 1,
					chromosome    => 'chr6',
					start         => 29222487,
					stop          => 29225448,
					coding_start  => 29222571,
					coding_stop   => 29224899,
					biotype       => 'coding',
					splice_starts => [29222487,29224649],
					splice_stops  => [29222607,29225448]
				),
				GenOO::Transcript->new(
					id            => 'uc009bdd.2',
					strand        => 1,
					chromosome    => 'chr6',
					start         => 29222625,
					stop          => 29225448,
					coding_start  => 29224705,
					coding_stop   => 29224899,
					biotype       => 'coding',
					splice_starts => [29222625,29224649],
					splice_stops  => [29222809,29225448]
				)
			]
	);
	
	push @test_objects, $test_class->class->new(
		name        => '2310016C08Rik',
		description => 'hypoxia-inducible gene 2 protein isoform 2',
	);
	
	return \@test_objects;
}

	


1;
