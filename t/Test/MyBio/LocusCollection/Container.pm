package Test::MyBio::LocusCollection::Container;
use strict;

use base qw(Test::MyBio::Data::Structure::DoubleHashArray);
use Test::Most;
use MyBio::Locus;


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
sub new_object : Test(setup) {
	my ($self) = @_;
	
	$self->{OBJ} = MyBio::LocusCollection::Container->new();
	$self->obj->add_entry(MyBio::Locus->new({STRAND => '+', CHR => 'chr1', START => 3, STOP => 10}));
	$self->obj->add_entry(MyBio::Locus->new({STRAND => '+', CHR => 'chr1', START => 2, STOP => 10}));
	$self->obj->add_entry(MyBio::Locus->new({STRAND => '+', CHR => 'chr1', START => 1, STOP => 10}));
	$self->obj->add_entry(MyBio::Locus->new({STRAND => '+', CHR => 'chr2', START => 11, STOP => 20}));
	$self->obj->add_entry(MyBio::Locus->new({STRAND => '+', CHR => 'chr2', START => 12, STOP => 20}));
	$self->obj->add_entry(MyBio::Locus->new({STRAND => '+', CHR => 'chr2', START => 13, STOP => 20}));
	$self->obj->add_entry(MyBio::Locus->new({STRAND => '-', CHR => 'chr3', START => 21, STOP => 30}));
	$self->obj->add_entry(MyBio::Locus->new({STRAND => '-', CHR => 'chr3', START => 22, STOP => 30}));
	$self->obj->add_entry(MyBio::Locus->new({STRAND => '-', CHR => 'chr3', START => 23, STOP => 30}));
	$self->obj->add_entry(MyBio::Locus->new({STRAND => '-', CHR => 'chr4', START => 31, STOP => 35}));
	$self->obj->add_entry(MyBio::Locus->new({STRAND => '-', CHR => 'chr4', START => 33, STOP => 40}));
	$self->obj->add_entry(MyBio::Locus->new({STRAND => '-', CHR => 'chr4', START => 32, STOP => 40}));
};

#######################################################################
##########################   Override Tests   #########################
#######################################################################
sub reset : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'reset';
	
	$self->obj->reset;
	is $self->obj->sorted, undef, "... and sort flag should be unset";
	is $self->obj->{LONGEST_ENTRY_LENGTH}, undef, "... and longest entry length should be unset";
}

sub foreach_entry_do : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'foreach_entry_do';
	
	my $iterations = 0;
	$self->obj->foreach_entry_do(sub{
		my ($arg) = @_;
		if ($arg->isa('MyBio::Locus')) {
			$iterations++;
		}
	});
	is $iterations, $self->obj->entries_count, "... and should do the correct number of iterations";
}

sub add_entry : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'add_entry';
	
	$self->obj->add_entry(MyBio::Locus->new({STRAND => '-', CHR => 'chr7'}));
	is $self->obj->entries_count, 13, "... and should result in the correct number of entries";
	is $self->obj->sorted, undef, "... and sort flag should be unset";
}

sub get_or_find_longest_entry_length : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_or_find_longest_entry_length';
	is $self->obj->get_or_find_longest_entry_length, 10, "... and should return the correct value";
}

sub entries_ref_for_keys : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'entries_ref_for_keys';
	is @{$self->obj->entries_ref_for_keys(1,'chr1')}, 3, "... and should return the correct value";
}

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub strands : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'strands';
	is_deeply [$self->obj->strands], [1,-1], "... and should return the correct value";
}

sub chromosomes_for_strand : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'chromosomes_for_strand';
	
	is $self->obj->chromosomes_for_strand(1), 2, "... and should return the correct value";
	is $self->obj->chromosomes_for_strand(-1), 2, "... and should return the correct value";
}

sub chromosomes_for_all_strands : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'chromosomes_for_all_strands';
	is_deeply [$self->obj->chromosomes_for_all_strands], ['chr3','chr1','chr4','chr2'], "... and should return the correct value";
}

sub entries_ref_for_strand_and_chromosome : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'entries_ref_for_strand_and_chromosome';
	is @{$self->obj->entries_ref_for_strand_and_chromosome(1,'chr1')}, 3, "... and should return the correct value";
}

sub sort_entries : Test(7) {
	my ($self) = @_;
	
	can_ok $self->obj, 'sort_entries';
	
	is $self->obj->sorted, undef, "... and sort flag should be unset";
	
	$self->obj->sort_entries;
	my @test_array_1 = @{$self->obj->entries_ref_for_strand_and_chromosome(1,'chr1')};
	my @test_array_2 = @{$self->obj->entries_ref_for_strand_and_chromosome(1,'chr2')};
	my @test_array_3 = @{$self->obj->entries_ref_for_strand_and_chromosome(-1,'chr3')};
	my @test_array_4 = @{$self->obj->entries_ref_for_strand_and_chromosome(-1,'chr4')};
	is_deeply [map{$_->start} @test_array_1], [1,2,3], "... and sorting should result in correct order";
	is_deeply [map{$_->start} @test_array_2], [11,12,13], "... and sorting should result in correct order";
	is_deeply [map{$_->start} @test_array_3], [21,22,23], "... and sorting should result in correct order";
	is_deeply [map{$_->start} @test_array_4], [31,32,33], "... and sorting should result in correct order";
	
	is $self->obj->sorted, 1, "... and sort flag should be set";
}

sub entries_overlapping_region  : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'entries_overlapping_region';
	
	my @result = map{$_->id} $self->obj->entries_overlapping_region(1,'chr1', 2, 5);
	is_deeply [@result], ['chr1:1-10:1','chr1:2-10:1','chr1:3-10:1'], "... and should return the correct entries";
	
	@result = map{$_->id} $self->obj->entries_overlapping_region(-1,'chr4', 36, 40);
	is_deeply [@result], ['chr4:32-40:-1','chr4:33-40:-1'], "... and should return the correct entries";
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
