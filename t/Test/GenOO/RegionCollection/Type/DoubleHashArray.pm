package Test::GenOO::RegionCollection::Type::DoubleHashArray;
use strict;

use GenOO::GenomicRegion;
use Test::GenOO::GenomicRegion;

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
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	isa_ok $self->obj(0), $self->class, "... and the object";
}

sub _role_check : Test(1) {
	my ($self) = @_;
	does_ok($self->obj(0), 'GenOO::RegionCollection', '... does the GenOO::RegionCollection role');
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

sub longest_record : Test(3) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'longest_record', "... test object has the 'longest_record' attribute");
	is $self->obj(0)->longest_record->length, 10, "... and returns the correct value";
	
	$self->obj(0)->add_record(
		GenOO::GenomicRegion->new(
			strand => 1,
			chromosome => 'chr2',
			start => 11,
			stop => 100
		)
	);
	is $self->obj(0)->longest_record->length, 90, "... and returns the correct value again";
}

sub add_record : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'add_record';
	
	$self->obj(0)->add_record(
		GenOO::GenomicRegion->new(
			strand => -1,
			chromosome => 'chr7',
			start => 100,
			stop => 150
		)
	);
	is $self->obj(0)->records_count, 13, "... and should result in the correct number of records";
}

sub all_records : Test(4) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'all_records';
	
	my @records = $self->obj(0)->all_records;
	is @records, 12, "... and in list context returns array with correct number of records";
	
	isa_ok $self->obj(0)->all_records, 'ARRAY', "... and in scalar context returned object ";
	is @{$self->obj(0)->all_records}, 12, "... with the correct number of records";
}

sub foreach_record_do : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'foreach_record_do';
	
	my $iterations = 0;
	$self->obj(0)->foreach_record_do(
		sub {
			$iterations++;
		}
	);
	is $iterations, $self->obj(0)->records_count, "... and should do the correct number of iterations";
}

sub foreach_record_on_rname_do : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'foreach_record_on_rname_do';
	
	my $iterations = 0;
	$self->obj(0)->foreach_record_on_rname_do('chr1', sub {
		$iterations++;
	});
	is $iterations, 3, "... and should do the correct number of iterations";
}

sub records_count : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'records_count';
	is $self->obj(0)->records_count, 12, "... and should result in the correct number of records";
}

sub strands : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'strands';
	is_deeply [$self->obj(0)->strands], [-1,1], "... and should return the correct value";
}

sub rnames_for_strand : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'rnames_for_strand';
	
	my @rnames_for_strand = $self->obj(0)->rnames_for_strand(1);
	is @rnames_for_strand, 2, "... and should return the correct value";
	@rnames_for_strand = $self->obj(0)->rnames_for_strand(-1);
	is @rnames_for_strand, 2, "... and should return the correct value";
}

sub rnames_for_all_strands : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'rnames_for_all_strands';
	is_deeply [$self->obj(0)->rnames_for_all_strands], ['chr1','chr2','chr3','chr4'], "... and should return the correct value";
}

sub longest_record_length : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'longest_record_length';
	is $self->obj(0)->longest_record_length, 10, "... and should return the correct value";
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

sub foreach_overlapping_record_do  : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'foreach_overlapping_record_do';
	
	my $count = 0;
	$self->obj(0)->foreach_overlapping_record_do(1,'chr1', 2, 5, 
		sub {
			$count++;
		}
	);
	
	is $count, 3, "... and should return the correct number of records";
}

sub records_overlapping_region  : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'records_overlapping_region';
	
	my @result = map{$_->id} $self->obj(0)->records_overlapping_region(1,'chr1', 2, 5);
	is_deeply [@result], ['chr1:1-10:1','chr1:2-10:1','chr1:3-10:1'], "... and should return the correct records";
	
	@result = map{$_->id} $self->obj(0)->records_overlapping_region(-1,'chr4', 36, 40);
	is_deeply [@result], ['chr4:32-40:-1','chr4:33-40:-1'], "... and should return the correct records";
}

sub records_ref_for_strand_and_rname : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), '_records_ref_for_strand_and_rname';
	is @{$self->obj(0)->_records_ref_for_strand_and_rname(1,'chr1')}, 3, "... and should return the correct value";
}

sub total_copy_number : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'total_copy_number';
	is $self->obj(0)->total_copy_number, 18, "... and should return the correct value";
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
	
	my @test_locuses = @{Test::GenOO::GenomicRegion->test_objects()};
	
	my $test_object_1 = $test_class->class->new({
		name        => 'test_object_1',
		species     => 'human',
		description => 'just a test object'
	});
	$test_object_1->add_record($test_locuses[$_]) for (0..11);
	
	return [$test_object_1];
}

1;