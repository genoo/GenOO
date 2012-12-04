package Test::GenOO::Gene;
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
sub get_ensgid : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_ensgid';
	is $self->obj(0)->get_ensgid, 'ENSMUSG00000043421', "... and returns the correct value";
}

sub get_description : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_description';
	is $self->obj(0)->get_description, 'hypoxia-inducible gene 2 protein isoform 2', "... and returns the correct value";
}

sub get_internalID : Test(1) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_internalID';
}

sub get_transcripts : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_transcripts';
	
	my $transcripts_arrayref = $self->obj(0)->get_transcripts;
	is @{$transcripts_arrayref}, 2, "... and returns the correct value";
	isa_ok $transcripts_arrayref->[0], 'GenOO::Transcript', "... and returns the correct value";
}

sub get_coding_transcripts : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_coding_transcripts';
	
	my $transcripts_arrayref = $self->obj(0)->get_coding_transcripts;
	is @{$transcripts_arrayref}, 2, "... and returns the correct value";
	isa_ok $transcripts_arrayref->[0], 'GenOO::Transcript', "... and returns the correct value";
}

sub get_non_coding_transcripts : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_non_coding_transcripts';
	
	my $transcripts_arrayref = $self->obj(0)->get_non_coding_transcripts;
	is @{$transcripts_arrayref}, 0, "... and returns the correct value";
}

sub get_constitutive_exons : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_constitutive_exons';
	
	my $exons_arrayref = $self->obj(0)->get_constitutive_exons;
	is @{$exons_arrayref}, 1, "... and returns the correct value";
	isa_ok $exons_arrayref->[0], 'GenOO::Transcript::Exon', "... and returns the correct value";
}

sub get_constitutive_coding_exons : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_constitutive_coding_exons';
	
	my $exons_arrayref = $self->obj(0)->get_constitutive_coding_exons;
	is @{$exons_arrayref}, 1, "... and returns the correct value";
	isa_ok $exons_arrayref->[0], 'GenOO::Transcript::Exon', "... and returns the correct value";
}

sub get_exon_length : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_exon_length';
	is $self->obj(0)->get_exon_length, 1106, "... and returns the correct value";
}

sub get_merged_exons : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_merged_exons';
	
	my $exons_arrayref = $self->obj(0)->get_merged_exons;
	is @{$exons_arrayref}, 3, "... and returns the correct value";
}

sub has_coding_transcript : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'has_coding_transcript';
	is $self->obj(0)->has_coding_transcript, 1, "... and returns the correct value";
}

#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	eval "require GenOO::Transcript";
	
	my @test_objects;
	
	push @test_objects, $test_class->class->new({
		ENSGID      => 'ENSMUSG00000043421',
		STRAND      => '1',
		NAME        => '2310016C08Rik',
		START       => '29222487',
		STOP        => 29225448,
		DESCRIPTION => 'hypoxia-inducible gene 2 protein isoform 2',
		CHR         => 'chr6',
		TRANSCRIPTS => [
				GenOO::Transcript->new({
					'CODING_START' => 29222571,
					'SPLICE_STARTS' => [
								29222487,
								29224649
								],
					'STRAND' => '1',
					'ENSTID' => 'uc012eiw.1',
					'CODING_STOP' => 29224899,
					'CHR' => 'chr6',
					'SPLICE_STOPS' => [
								29222607,
								29225448
							],
					'START' => '29222487',
					'STOP' => 29225448,
					'BIOTYPE' => 'coding'
				}),
				GenOO::Transcript->new({
					'CODING_START' => 29224705,
					'SPLICE_STARTS' => [
								29222625,
								29224649
								],
					'STRAND' => '1',
					'ENSTID' => 'uc009bdd.2',
					'CODING_STOP' => 29224899,
					'CHR' => 'chr6',
					'SPLICE_STOPS' => [
								29222809,
								29225448
							],
					'START' => '29222625',
					'STOP' => 29225448,
					'BIOTYPE' => 'coding'
				})
			]
	});
	
	return \@test_objects;
}

	


1;
