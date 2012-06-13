package Test::MyBio::LocusCollection::Iterator;
use strict;

use base qw(Test::MyBio);
use Test::Most;

#######################################################################
############################   Accessors   ############################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

#######################################################################
################   Startup (Runs once in the begining  ################
#######################################################################
sub startup : Test(startup => 2) {
	my ($self) = @_;
	
	use_ok $self->class;
	can_ok $self->class, 'new';
};

#######################################################################
#################   Setup (Runs before every method)  #################
#######################################################################
sub new_object : Test(setup => 1) {
	my ($self) = @_;
	
	my $data = 
	{
		'+'  =>  {
			'chr1' => [1,2,3],
			'chr2' => [11,12,13],
		},
		'-'  =>  {
			'chr3' => [21,22,23],
			'chr4' => [31,32,33],
		}
	};
	
	ok $self->{OBJ} = MyBio::LocusCollection::Iterator->new({
		DATA_STRUCTURE => $data
	}), 'The constructor succeeds';
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj, $self->class, "... and the object";
}

sub data_stucture : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'data_stucture';
	isa_ok $self->obj->data_stucture, 'HASH', "... and returned object";
}

sub strand : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'strand';
	is $self->obj->strand, '-', "... and should return the correct value";
}

sub chr : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'chr';
	is $self->obj->chr, 'chr3', "... and should return the correct value";
}

sub strand_idx : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'strand_idx';
	is $self->obj->strand_idx, 0, "... and should return the correct value";
}

sub chr_idx : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'chr_idx';
	is $self->obj->chr_idx, 0, "... and should return the correct value";
}

sub array_idx : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'array_idx';
	is $self->obj->array_idx, -1, "... and should return the correct value";
}

sub strands_ref : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'strands_ref';
	isa_ok $self->obj->strands_ref, 'ARRAY', "... and returned object";
	is_deeply $self->obj->strands_ref, ['-','+'], "... and should contain the correct values";
}

sub chrs_ref : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'chrs_ref';
	isa_ok $self->obj->chrs_ref, 'ARRAY', "... and returned object";
	is_deeply $self->obj->chrs_ref, ['chr3','chr4'], "... and should contain the correct values";
}

sub array_ref : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'array_ref';
	isa_ok $self->obj->array_ref, 'ARRAY', "... and returned object";
	is_deeply $self->obj->array_ref, [21,22,23], "... and should contain the correct values";
}

sub init : Test(5) {
	my ($self) = @_;
	
	can_ok $self->obj, 'init';
	
	$self->obj->init;
	is $self->obj->strand_idx, 0, "... and should result in the correct value";
	is $self->obj->chr_idx, 0, "... and should result in the correct value";
	is $self->obj->array_idx, -1, "... and should result in the correct value";
	is_deeply $self->obj->strands_ref, ['-','+'], "... and should contain the correct values";
}

sub init_strand_idx : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'init_strand_idx';
	
	$self->obj->init_strand_idx;
	is $self->obj->strand_idx, 0, "... and should result in the correct value";
}

sub init_chr_idx : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'init_chr_idx';
	
	$self->obj->init_chr_idx;
	is $self->obj->chr_idx, 0, "... and should result in the correct value";
}

sub init_array_idx : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'init_array_idx';
	
	$self->obj->init_array_idx;
	is $self->obj->array_idx, -1, "... and should result in the correct value";
}

sub init_strands_ref : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'init_strands_ref';
	
	$self->obj->init_strands_ref;
	isa_ok $self->obj->strands_ref, 'ARRAY', "... and returned object";
	is_deeply $self->obj->strands_ref, ['-','+'], "... and should contain the correct values";
}

sub update : Test(1) {
	my ($self) = @_;
	
	can_ok $self->obj, 'update';
}

sub update_strand : Test(1) {
	my ($self) = @_;
	
	can_ok $self->obj, 'update_strand';
}

sub update_chr : Test(1) {
	my ($self) = @_;
	
	can_ok $self->obj, 'update_chr';
}

sub update_chrs_ref : Test(1) {
	my ($self) = @_;
	
	can_ok $self->obj, 'update_chrs_ref';
}

sub update_array_ref : Test(1) {
	my ($self) = @_;
	
	can_ok $self->obj, 'update_array_ref';
}

sub next : Test(15) {
	my ($self) = @_;
	
	can_ok $self->obj, 'next';
	
	is $self->obj->next, 21, "... and should result in the correct value";
	is $self->obj->next, 22, "... and should result in the correct value again";
	is $self->obj->next, 23, "... and again";
	is $self->obj->next, 31, "... and again";
	is $self->obj->next, 32, "... and again";
	is $self->obj->next, 33, "... and again";
	is $self->obj->next, 1, "... and again";
	is $self->obj->next, 2, "... and again";
	is $self->obj->next, 3, "... and again";
	is $self->obj->next, 11, "... and again";
	is $self->obj->next, 12, "... and again";
	is $self->obj->next, 13, "... and again";
	ok !$self->obj->next, "... and should return undef";
	is $self->obj->next, 21, "... and it should restart";
}

sub iterator_closure : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'iterator_closure';
	isa_ok $self->obj->iterator_closure, 'CODE', "... and returned object";
}

sub next_idx_set : Test(1) {
	my ($self) = @_;
	
	can_ok $self->obj, 'next_idx_set';
}

sub reset_strand_idx : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'reset_strand_idx';
	
	$self->obj->reset_strand_idx;
	is $self->obj->strand_idx, 0, "... and should result in the correct value";
}

sub reset_chr_idx : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'reset_chr_idx';
	
	$self->obj->reset_chr_idx;
	is $self->obj->chr_idx, 0, "... and should result in the correct value";
}

sub reset_array_idx : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'reset_array_idx';
	
	$self->obj->reset_array_idx;
	is $self->obj->array_idx, 0, "... and should result in the correct value";
}

sub increment_strand_idx : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'increment_strand_idx';
	
	$self->obj->increment_strand_idx;
	is $self->obj->strand_idx, 1, "... and should result in the correct value";
}

sub increment_chr_idx : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'increment_chr_idx';
	
	$self->obj->increment_chr_idx;
	is $self->obj->chr_idx, 1, "... and should result in the correct value";
}

sub increment_array_idx : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'increment_array_idx';
	
	$self->obj->increment_array_idx;
	is $self->obj->array_idx, 0, "... and should result in the correct value";
}

1;
