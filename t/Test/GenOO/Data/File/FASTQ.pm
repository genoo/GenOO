package Test::GenOO::Data::File::FASTQ;
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
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj(0), $self->class, "... and the object";
}

sub file : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'file';
	is $self->obj(0)->file, 't/sample_data/sample.fastq.gz', "... and should return the correct value";
}

sub next_record : Test(9) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'next_record';
	
	my $record = $self->obj(0)->next_record;
	isa_ok $record, 'GenOO::Data::File::FASTQ::Record', "... and the returned object";
	is $record->name, 'HWUSI-EAS366_6:1:4:555#0/1',  "... and should return the correct value";
	is $record->sequence, 'AGTTTTTTNGGACCGATTCAATGCGATC',  "... and should return the correct value";
	is $record->quality, '?ABBBCC=%<BBBBB>BBBB>BBBBAB=',  "... and should return the correct value";
	
	$record = $self->obj(0)->next_record;
	isa_ok $record, 'GenOO::Data::File::FASTQ::Record', "... and the returned object";
	is $record->name, 'HWUSI-EAS366_6:1:4:836#0/1',  "... and should return the correct value";
	is $record->sequence, 'TAATTCGTNAACTGGGGAAGATAATAATN',  "... and should return the correct value";
	is $record->quality, 'BB?CCBB:%<BBCB<B=0@BBBCBCBA<%',  "... and should return the correct value";
}

sub records_read_count : Test(5) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'records_read_count';
	is $self->obj(0)->records_read_count, 0, "... and should return the correct value";
	
	$self->obj(0)->next_record();
	is $self->obj(0)->records_read_count, 1, "... and should return the correct value again";
	
	$self->obj(0)->next_record();
	is $self->obj(0)->records_read_count, 2, "... and again";
	
	while ($self->obj(0)->next_record()) {}
	is $self->obj(0)->records_read_count, 40, "... and again (when the whole file is read)";
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
		file => 't/sample_data/sample.fastq.gz'
	);

	return \@test_objects;
}

1;

