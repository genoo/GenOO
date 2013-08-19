package Test::GenOO::Data::File::GFF::Record;
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

sub seqname : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'seqname', "... test object has the 'seqname' attribute");
	is $self->obj(0)->seqname, 'chr1', "... and returns the correct value";
}

sub source : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'source', "... test object has the 'source' attribute");
	is $self->obj(0)->source, 'MirBase', "... and returns the correct value";
}

sub feature : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'feature', "... test object has the 'feature' attribute");
	is $self->obj(0)->feature, 'miRNA', "... and returns the correct value";
}

sub start : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'start', "... test object has the 'start' attribute");
	is $self->obj(0)->start, 151518271, "... and returns the correct value";
}

sub stop : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'stop', "... test object has the 'stop' attribute");
	is $self->obj(0)->stop, 151518366, "... and returns the correct value";
}

sub strand : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'strand', "... test object has the 'strand' attribute");
	is $self->obj(0)->strand, 1, "... and returns the correct value";
}

sub frame : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'frame', "... test object has the 'frame' attribute");
	is $self->obj(0)->frame, '.', "... and returns the correct value";
}

sub attributes : Test(3) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'attributes', "... test object has the 'attributes' attribute");
	is $self->obj(0)->attribute('ACC'), 'MI0003559', "... and returns the correct value";
	is $self->obj(0)->attribute('ID'), 'hsa-mir-554', "... and returns the correct value";
}

sub comment : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'comment', "... test object has the 'comment' attribute");
	is $self->obj(0)->comment, 'Test comment', "... and returns the correct value";
}


sub length : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'length';
	is $self->obj(0)->length, 96, "... and should return the correct value";
}

sub strand_symbol : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'strand_symbol';
	is $self->obj(0)->strand_symbol, '+', "... and should return the correct value again";
}

#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	
	my @test_objects;
	
	push @test_objects, $test_class->class->new(
		seqname     => 'chr1',
		source      => 'MirBase',
		feature     => 'miRNA',
		start_1_based     => '151518272',
		stop_1_based      => '151518367',
		score       => '0.5',
		strand      => '+',
		frame       => '.',
		attributes  => {
			'ACC' => 'MI0003559',
			'ID'  => 'hsa-mir-554'
		},
		comment     => 'Test comment',
	);
	
	return \@test_objects;
}



1;
