package Test::MyBio::GenomicRegion;
use strict;

use base qw(Test::MyBio);
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
	does_ok($self->obj(0), 'MyBio::Region', '... does the MyBio::Region role');
}

#######################################################################
#######################   Class Interface Tests   #####################
#######################################################################
sub name : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'name', "... test object has the 'name' attribute");
	is $self->obj(0)->name, 'test_object_0', "... and returns the correct value";
}

sub species : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'species', "... test object has the 'species' attribute");
	is $self->obj(0)->species, 'human', "... and returns the correct value";
}

sub strand : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'strand', "... test object has the 'strand' attribute");	
	is $self->obj(0)->strand, 1, "... and returns the correct value";
}

sub chromosome : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'chromosome', "... test object has the 'chromosome' attribute");	
	is $self->obj(0)->chromosome, 'chr1', "... and returns the correct value";
}

sub start : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'start', "... test object has the 'start' attribute");
	is $self->obj(0)->start, 3, "... and returns the correct value";
}

sub stop : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'stop', "... test object has the 'stop' attribute");	
	is $self->obj(0)->stop, 10, "... and returns the correct value";
}

sub copy_number : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'copy_number', "... test object has the 'copy_number' attribute");
	is $self->obj(0)->copy_number, 7, "... and returns the correct value";
}

sub sequence : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'sequence', "... test object has the 'sequence' attribute");
	is $self->obj(0)->sequence, 'AGCTAGCU', "... and returns the correct value";
}

sub rname : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'rname';
	is $self->obj(0)->rname, 'chr1', "... and returns the correct value";
}

sub id : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'id';
	is $self->obj(0)->id, 'chr1:3-10:1', "... and returns the correct value";
}

#######################################################################
#######################   Role Interface Tests   ######################
#######################################################################
sub length : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'length', "... test object has the 'length' attribute");
	is $self->obj(0)->length, 8, "... and returns the correct value";
}

sub location : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'location';
	is $self->obj(0)->location, 'chr1:3-10:1', "... and returns the correct value";
}

sub strand_symbol : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'strand_symbol';
	is $self->obj(0)->strand_symbol, '+', "... and returns the correct value";
}

sub head_position : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'head_position';
	is $self->obj(0)->head_position, 3, "... and returns the correct value";
	is $self->obj(6)->head_position, 30, "... and returns the correct value";
}

sub tail_position : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'tail_position';
	is $self->obj(0)->tail_position, 10, "... and returns the correct value";
	is $self->obj(6)->tail_position, 21, "... and returns the correct value";
}

sub head_head_distance_from : Test(5) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'head_head_distance_from';
	is $self->obj(1)->head_head_distance_from($self->obj(0)), -1, "... and returns the correct value";
	is $self->obj(0)->head_head_distance_from($self->obj(1)), 1, "... and returns the correct value";
	is $self->obj(6)->head_head_distance_from($self->obj(9)), 5, "... and returns the correct value";
	is $self->obj(9)->head_head_distance_from($self->obj(6)), -5, "... and returns the correct value";
}

sub head_tail_distance_from : Test(5) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'head_tail_distance_from';
	is $self->obj(1)->head_tail_distance_from($self->obj(0)), -8, "... and returns the correct value";
	is $self->obj(0)->head_tail_distance_from($self->obj(1)), -7, "... and returns the correct value";
	is $self->obj(6)->head_tail_distance_from($self->obj(7)), -8, "... and returns the correct value";
	is $self->obj(9)->head_tail_distance_from($self->obj(6)), -14, "... and returns the correct value";
}

sub tail_head_distance_from : Test(5) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'tail_head_distance_from';
	is $self->obj(0)->tail_head_distance_from($self->obj(3)), -1, "... and returns the correct value";
	is $self->obj(3)->tail_head_distance_from($self->obj(0)), 17, "... and returns the correct value";
	is $self->obj(6)->tail_head_distance_from($self->obj(7)), 9, "... and returns the correct value";
	is $self->obj(7)->tail_head_distance_from($self->obj(6)), 8, "... and returns the correct value";
}

sub tail_tail_distance_from : Test(5) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'tail_tail_distance_from';
	is $self->obj(0)->tail_tail_distance_from($self->obj(3)), -10, "... and returns the correct value";
	is $self->obj(3)->tail_tail_distance_from($self->obj(0)), 10, "... and returns the correct value";
	is $self->obj(6)->tail_tail_distance_from($self->obj(7)), 1, "... and returns the correct value";
	is $self->obj(7)->tail_tail_distance_from($self->obj(6)), -1, "... and returns the correct value";
}

sub to_string : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'to_string';
	is $self->obj(0)->to_string, 'chr1:3-10:1', "... and returns the correct value";
}

sub overlaps : Test(4) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'overlaps';
	is $self->obj(0)->overlaps($self->obj(1)), 1, "... and returns the correct value";
	is $self->obj(0)->overlaps($self->obj(6)), 0, "... and returns the correct value";
	is $self->obj(6)->overlaps($self->obj(7)), 1, "... and returns the correct value";
}

sub overlap_length : Test(4) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'overlap_length';
	is $self->obj(0)->overlap_length($self->obj(1)), 8, "... and returns the correct value";
	is $self->obj(0)->overlap_length($self->obj(6)), 0, "... and returns the correct value";
	is $self->obj(6)->overlap_length($self->obj(7)), 9, "... and returns the correct value";
}

sub contains : Test(6) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'contains';
	is $self->obj(0)->contains($self->obj(1)), 0, "... and returns the correct value";
	is $self->obj(1)->contains($self->obj(0)), 1, "... and returns the correct value";
	is $self->obj(0)->contains($self->obj(6)), 0, "... and returns the correct value";
	is $self->obj(6)->contains($self->obj(7)), 1, "... and returns the correct value";
	is $self->obj(7)->contains($self->obj(6)), 0, "... and returns the correct value";
}

sub contains_position : Test(6) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'contains_position';
	is $self->obj(0)->contains_position(5), 1, "... and returns the correct value";
	is $self->obj(0)->contains_position(1), 0, "... and returns the correct value";
	is $self->obj(6)->contains_position(22), 1, "... and returns the correct value";
	is $self->obj(6)->contains_position(20), 0, "... and returns the correct value";
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
		name        => 'test_object_0',
		species     => 'human',
		strand      => '+',
		chromosome  => 'chr1',
		start       => 3,
		stop        => 10,
		copy_number => 7,
		sequence    => 'AGCTAGCU'
	);
	push @test_objects, $test_class->class->new(strand => '+', chromosome => 'chr1', start => 2, stop => 10);
	push @test_objects, $test_class->class->new(strand => '+', chromosome => 'chr1', start => 1, stop => 10);
	push @test_objects, $test_class->class->new(strand => '+', chromosome => 'chr2', start => 11, stop => 20);
	push @test_objects, $test_class->class->new(strand => '+', chromosome => 'chr2', start => 12, stop => 20);
	push @test_objects, $test_class->class->new(strand => '+', chromosome => 'chr2', start => 13, stop => 20);
	push @test_objects, $test_class->class->new(strand => '-', chromosome => 'chr3', start => 21, stop => 30);
	push @test_objects, $test_class->class->new(strand => '-', chromosome => 'chr3', start => 22, stop => 30);
	push @test_objects, $test_class->class->new(strand => '-', chromosome => 'chr3', start => 23, stop => 30);
	push @test_objects, $test_class->class->new(strand => '-', chromosome => 'chr4', start => 31, stop => 35);
	push @test_objects, $test_class->class->new(strand => '-', chromosome => 'chr4', start => 33, stop => 40);
	push @test_objects, $test_class->class->new(strand => '-', chromosome => 'chr4', start => 32, stop => 40);
	
	
	return \@test_objects;
}

1;
