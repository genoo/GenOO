package Test::MyBio::LocusCollection::Type::DoubleHashArray;
use strict;

use Test::MyBio::Locus;

use base qw(Test::MyBio);
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
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	isa_ok $self->obj(0), $self->class, "... and the object";
}

sub _role_check : Test(1) {
	my ($self) = @_;
	does_ok($self->obj(0), 'MyBio::LocusCollection', '... does the MyBio::LocusCollection role');
}

sub name : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'name', "... test object has the 'name' attribute");
	is $self->obj(0)->name, 'test_object_1', "... and returns the correct value";
}

sub species : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'species', "... test object has the 'species' attribute");
	is $self->obj(0)->species, 'human', "... and returns the correct value";
}

sub description : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'description', "... test object has the 'description' attribute");
	is $self->obj(0)->description, 'just a test object', "... and returns the correct value";
}

sub longest_entry : Test(3) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'longest_entry', "... test object has the 'longest_entry' attribute");
	is $self->obj(0)->longest_entry->length, 10, "... and returns the correct value";
	
	$self->obj(0)->add_entry(MyBio::Locus->new({STRAND => '+', CHR => 'chr2', START => 11, STOP => 100}));
	is $self->obj(0)->longest_entry->length, 90, "... and returns the correct value again";
}

sub add_entry : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'add_entry';
	
	$self->obj(0)->add_entry(MyBio::Locus->new({STRAND => '-', CHR => 'chr7'}));
	is $self->obj(0)->entries_count, 13, "... and should result in the correct number of entries";
}

sub foreach_entry_do : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'foreach_entry_do';
	
	my $iterations = 0;
	$self->obj(0)->foreach_entry_do(sub{
		my ($arg) = @_;
		if ($arg->isa('MyBio::Locus')) {
			$iterations++;
		}
	});
	is $iterations, $self->obj(0)->entries_count, "... and should do the correct number of iterations";
}

sub entries_count : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'entries_count';
	is $self->obj(0)->entries_count, 12, "... and should result in the correct number of entries";
}

sub strands : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'strands';
	is_deeply [$self->obj(0)->strands], [1,-1], "... and should return the correct value";
}

sub chromosomes_for_strand : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'chromosomes_for_strand';
	
	is $self->obj(0)->chromosomes_for_strand(1), 2, "... and should return the correct value";
	is $self->obj(0)->chromosomes_for_strand(-1), 2, "... and should return the correct value";
}

sub chromosomes_for_all_strands : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'chromosomes_for_all_strands';
	is_deeply [$self->obj(0)->chromosomes_for_all_strands], ['chr3','chr1','chr4','chr2'], "... and should return the correct value";
}

sub longest_entry_length : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'longest_entry_length';
	is $self->obj(0)->longest_entry_length, 10, "... and should return the correct value";
}

sub is_empty : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'is_empty';
	is $self->obj(0)->is_empty, 0, "... and should return the correct value";
}

sub is_not_empty : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'is_not_empty';
	is $self->obj(0)->is_not_empty, 1, "... and should return the correct value";
}

sub entries_overlapping_region  : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'entries_overlapping_region';
	
	my @result = map{$_->id} $self->obj(0)->entries_overlapping_region(1,'chr1', 2, 5);
	is_deeply [@result], ['chr1:1-10:1','chr1:2-10:1','chr1:3-10:1'], "... and should return the correct entries";
	
	@result = map{$_->id} $self->obj(0)->entries_overlapping_region(-1,'chr4', 36, 40);
	is_deeply [@result], ['chr4:32-40:-1','chr4:33-40:-1'], "... and should return the correct entries";
}

sub entries_ref_for_strand_and_chromosome : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), '_entries_ref_for_strand_and_chromosome';
	is @{$self->obj(0)->_entries_ref_for_strand_and_chromosome(1,'chr1')}, 3, "... and should return the correct value";
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
	
	my @test_locuses = @{Test::MyBio::Locus->test_objects()};
	
	my $test_object_1 = $test_class->class->new({
		name        => 'test_object_1',
		species     => 'human',
		description => 'just a test object'
	});
	$test_object_1->add_entry($test_locuses[$_]) for (0..11);
	
	return [$test_object_1];
}

1;