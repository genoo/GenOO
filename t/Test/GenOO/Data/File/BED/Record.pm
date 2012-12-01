package Test::GenOO::Data::File::BED::Record;
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

sub _role_check : Test(1) {
	my ($self) = @_;
	does_ok($self->obj(0), 'GenOO::Region', '... does the GenOO::Region role');
}

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub rname : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'rname', "... test object has the 'rname' attribute");
	is $self->obj(0)->rname, 'chr7', "... and returns the correct value";
}

sub start : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'start', "... test object has the 'start' attribute");
	is $self->obj(0)->start, 127471196, "... and returns the correct value";
}

sub stop : Test(3) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'stop', "... test object has the 'stop' attribute");	
	is $self->obj(0)->stop, 127472362, "... and returns the correct value";
	is $self->obj(1)->stop, 150, "... and returns the correct value";
}

sub name : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'name', "... test object has the 'name' attribute");
	is $self->obj(0)->name, 'Pos1', "... and returns the correct value";
}

sub score : Test(3) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'score', "... test object has the 'score' attribute");
	is $self->obj(0)->score, 10, "... and returns the correct value";
	is $self->obj(1)->score, 0.5, "... and returns the correct value";
}

sub strand : Test(3) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'strand', "... test object has the 'strand' attribute");	
	is $self->obj(0)->strand, 1, "... and returns the correct value";
	is $self->obj(1)->strand, -1, "... and returns the correct value";
}

sub thick_start : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'thick_start', "... test object has the 'thick_start' attribute");	
	is $self->obj(0)->thick_start, 127471196, "... and returns the correct value";
}

sub thick_stop_1based : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'thick_stop_1based', "... test object has the 'thick_stop_1based' attribute");	
	is $self->obj(0)->thick_stop_1based, 127472363, "... and returns the correct value";
}

sub rgb : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'rgb', "... test object has the 'rgb' attribute");	
	is $self->obj(0)->rgb, '255,0,0', "... and returns the correct value";
}

sub block_count : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'block_count', "... test object has the 'block_count' attribute");	
	is $self->obj(0)->block_count, 2, "... and returns the correct value";
}

sub block_sizes : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'block_sizes', "... test object has the 'block_sizes' attribute");	
	is_deeply $self->obj(0)->block_sizes, [100,200], "... and returns the correct value";
}

sub block_starts : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'block_starts', "... test object has the 'block_starts' attribute");	
	is_deeply $self->obj(0)->block_starts, [0, 900], "... and returns the correct value";
}

sub copy_number : Test(3) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'copy_number', "... test object has the 'copy_number' attribute");
	is $self->obj(0)->copy_number, 1, "... and returns the correct value";
	is $self->obj(1)->copy_number, 100, "... and returns the correct value";
}

sub stop_1based : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'stop_1based';
	is $self->obj(0)->stop_1based, 127472363, "... and returns the correct value";
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
	
	push @test_objects, $test_class->class->new({
		rname             => 'chr7',
		start             => 127471196,
		stop_1based       => 127472363,
		name              => 'Pos1',
		score             => 10,
		strand_symbol     => '+',
		thick_start       => 127471196,
		thick_stop_1based => 127472363,
		rgb               => '255,0,0',
		block_count       => 2,
		block_sizes       => [100,200],
		block_starts      => [0, 900],
	});
	
	push @test_objects, $test_class->class->new({
		rname             => 'chr10',
		start             => 127,
		stop              => 150,
		name              => 'Pos2',
		score             => 0.5,
		strand            => -1,
		thick_start       => 127471196,
		thick_stop_1based => 127472363,
		rgb               => '255,0,0',
		block_count       => 1,
		block_sizes       => [24],
		block_starts      => [0],
		copy_number       => 100,
	});
	
	return \@test_objects;
}

1;
