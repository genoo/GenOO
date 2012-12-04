package Test::GenOO::Transcript;
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
sub get_enstid : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_enstid';
	is $self->obj(0)->get_enstid, 'uc007hzr.1', "... and returns the correct value";
}

sub get_biotype : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_biotype';
	is $self->obj(0)->get_biotype, 'coding', "... and returns the correct value";
	is $self->obj(1)->get_biotype, 'non coding', "... and returns the correct value";
}

sub get_internalID : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_internalID';
	is $self->obj(0)->get_internalID, undef, "... and returns the correct value";
}

sub get_internalGID : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_internalGID';
	is $self->obj(0)->get_internalGID, undef, "... and returns the correct value";
}

sub get_coding_start : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_coding_start';
	is $self->obj(0)->get_coding_start, 8896852, "... and returns the correct value";
	is $self->obj(1)->get_coding_start, undef, "... and returns the correct value";
}

sub get_coding_stop : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_coding_stop';
	is $self->obj(0)->get_coding_stop, 8911112, "... and returns the correct value";
	is $self->obj(1)->get_coding_stop, undef, "... and returns the correct value";
}

sub get_gene : Test(1) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_gene';
}

sub get_cdna : Test(6) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_cdna';
	
	isa_ok $self->obj(0)->get_cdna, 'GenOO::Transcript::CDNA', "... and returns the correct value";
	is $self->obj(0)->get_cdna->start, 8893144, "... and returns the correct value";
	is $self->obj(0)->get_cdna->stop, 8911139, "... and returns the correct value";
	
	is $self->obj(1)->get_cdna->start, 86086601, "... and returns the correct value";
	is $self->obj(1)->get_cdna->stop, 86086630, "... and returns the correct value";
}

sub get_utr5 : Test(4) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_utr5';
	isa_ok $self->obj(0)->get_utr5, 'GenOO::Transcript::UTR5', "... and returns the correct value";
	is $self->obj(0)->get_utr5->start, 8911113, "... and returns the correct value";
	is $self->obj(0)->get_utr5->stop, 8911139, "... and returns the correct value";
}

sub get_cds : Test(4) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_cds';
	isa_ok $self->obj(0)->get_cds, 'GenOO::Transcript::CDS', "... and returns the correct value";
	is $self->obj(0)->get_cds->start, 8896852, "... and returns the correct value";
	is $self->obj(0)->get_cds->stop, 8911112, "... and returns the correct value";
}

sub get_utr3 : Test(4) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_utr3';
	isa_ok $self->obj(0)->get_utr3, 'GenOO::Transcript::UTR3', "... and returns the correct value";
	is $self->obj(0)->get_utr3->start, 8893144, "... and returns the correct value";
	is $self->obj(0)->get_utr3->stop, 8896851, "... and returns the correct value";
}

sub is_coding : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'is_coding';
	is $self->obj(0)->is_coding, 1, "... and returns the correct value";
	is $self->obj(1)->is_coding, 0, "... and returns the correct value";
}

sub get_exons_split_by_function : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_exons_split_by_function';
	is @{$self->obj(0)->get_exons_split_by_function}, 10, "... and returns the correct value";
}


#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	
	my @test_objects;
	
	push @test_objects, $test_class->class->new({
		ENSTID         => 'uc007hzr.1',
		STRAND         => -1,
		CHR            => 'chr11',
		START          => 8893144,
		STOP           => 8911139,
		SPLICE_STARTS  => [
					8893144,
					8898639,
					8900079,
					8905991,
					8907496,
					8910243,
					8910499,
					8911061
				],
		SPLICE_STOPS   => [
					8896934,
					8898758,
					8900178,
					8906065,
					8907603,
					8910419,
					8910626,
					8911139
				],
		CODING_START   => 8896852,
		CODING_STOP    => 8911112,
		BIOTYPE        => 'coding',
	});
	
	push @test_objects, $test_class->class->new({
		ENSTID         => 'uc007gqc.1',
		STRAND         => 1,
		CHR            => 'chr10',
		START          => 86086601,
		STOP           => 86086630,
		SPLICE_STARTS  => [86086601],
		SPLICE_STOPS   => [86086630],
		BIOTYPE        => 'non coding',
	});
	
	return \@test_objects;
}

1;
