package Test::GenOO::Data::File::FASTA;
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
sub file : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'file');
	is $self->obj(0)->file, 't/sample_data/sample.fa.gz', "... and should return the correct value";
}

sub records_read_count : Test(5) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'records_read_count');
	is $self->obj(0)->records_read_count, 0, "... and should return the correct value";
	
	$self->obj(0)->next_record();
	is $self->obj(0)->records_read_count, 1, "... and should return the correct value again";
	
	$self->obj(0)->next_record();
	is $self->obj(0)->records_read_count, 2, "... and again";
	
	while ($self->obj(0)->next_record()) {}
	is $self->obj(0)->records_read_count, 10, "... and again (when the whole file is read)";
}

sub next_record : Test(7) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'next_record';
	
	my $record = $self->obj(0)->next_record;
	isa_ok $record, 'GenOO::Data::File::FASTA::Record', "... and the returned object";
	is $record->header, 'HWI-asadasASooo_1',  "... and should return the correct value";
	is $record->sequence, 'AAATANNCGTCGAAGATGTAAAGAAAACCGACTTTAATAATGT',  "... and should return the correct value";
	
	$record = $self->obj(0)->next_record;
	isa_ok $record, 'GenOO::Data::File::FASTA::Record', "... and the returned object";
	is $record->header, 'HWI-asadasASooo_2',  "... and should return the correct value";
	is $record->sequence, 'TTTTANNTAAATTTATGCATAGACCGACTTTAATAATGT',  "... and should return the correct value";
}

#######################################################################
########################   Class Private Tests   ######################
#######################################################################
sub eof : Test(4) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), '_eof');
	ok(!$self->obj(0)->_reached_eof, "... and should start as false");
	
	$self->obj(0)->next_record;
	ok(!$self->obj(0)->_reached_eof, "... and should remain false");
	
	while ($self->obj(0)->next_record) {}
	ok($self->obj(0)->_reached_eof, "... and should be true after reading the whole file");
}

sub stored_record_header : Test(3) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), '_stored_record_header');
	is $self->obj(0)->_stored_record_header, undef, "... and should be undefined";
	ok(!$self->obj(0)->_has_stored_record_header, "... and should predicate to false");
}

sub stored_record_sequence_parts : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), '_stored_record_sequence_parts');
	is_deeply $self->obj(0)->_stored_record_sequence_parts, [], "... and should be undefined";
}


#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	
	my @test_objects;
	push @test_objects, $test_class->class->new(
		file => 't/sample_data/sample.fa.gz'
	);
	
	return \@test_objects;
}

1;
