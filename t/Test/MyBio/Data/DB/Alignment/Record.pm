package Test::MyBio::Data::DB::Alignment::Record;
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
sub rname : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'rname', "... test object has the 'rname' attribute");
	is $self->obj(0)->rname, 'chr18', "... and returns the correct value";
}

sub cigar : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'cigar', "... test object has the 'cigar' attribute");
	is $self->obj(0)->cigar, '32M', "... and returns the correct value";
}

sub sequence : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'sequence', "... test object has the 'sequence' attribute");
	is $self->obj(0)->sequence, 'ATTCGGCAGGTGAGTTGTTACACACTCCTTAG', "... and returns the correct value";
}

sub start : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'start', "... test object has the 'start' attribute");
	is $self->obj(0)->start, 85867635, "... and returns the correct value";
}

sub stop : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'stop', "... test object has the 'stop' attribute");	
	is $self->obj(0)->stop, 85867666, "... and returns the correct value";
}

sub strand : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'strand', "... test object has the 'strand' attribute");	
	is $self->obj(0)->strand, 1, "... and returns the correct value";
}

sub location : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'location';
	is $self->obj(0)->location, 'chr18:85867635-85867666:1', "... and returns the correct value";
}

sub length : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'length';
	is $self->obj(0)->length, 32, "... and returns the correct value";
}

sub strand_symbol : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'strand_symbol';
	is $self->obj(0)->strand_symbol, '+', "... and returns the correct value";
}

sub head_position : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'head_position';
	is $self->obj(0)->head_position, 85867635, "... and returns the correct value";
}

sub tail_position : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'tail_position';
	is $self->obj(0)->tail_position, 85867666, "... and returns the correct value";
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
		strand      => 1,
		rname       => 'chr18',
		start       => '85867635',
		stop        => '85867666',
		copy_number => 12,
		cigar       => '32M',
		sequence    => 'ATTCGGCAGGTGAGTTGTTACACACTCCTTAG',
		mdz         => 32
	);
	
	return \@test_objects;
}

1;
