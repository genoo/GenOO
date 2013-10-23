package Test::GenOO::Data::Structure::DoubleHashArray;
use strict;

use base qw(Test::GenOO);
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
sub new_object : Test(setup) {
	my ($self) = @_;
	
	$self->{OBJ} = GenOO::Data::Structure::DoubleHashArray->new(
		sorting_code_block => sub {return $_[0] <=> $_[1]}
	);
	$self->obj->add_entry(1, 'chr1', 1);
	$self->obj->add_entry(1, 'chr1', 3);
	$self->obj->add_entry(1, 'chr1', 2);
	$self->obj->add_entry(1, 'chr2', 11);
	$self->obj->add_entry(1, 'chr2', 12);
	$self->obj->add_entry(1, 'chr2', 13);
	$self->obj->add_entry(-1, 'chr3', 21);
	$self->obj->add_entry(-1, 'chr3', 23);
	$self->obj->add_entry(-1, 'chr3', 22);
	$self->obj->add_entry(-1, 'chr4', 31);
	$self->obj->add_entry(-1, 'chr4', 32);
	$self->obj->add_entry(-1, 'chr4', 33);
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj, $self->class, "... and the object";
}

sub structure : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, '_structure';
	isa_ok $self->obj->_structure, 'HASH', "... and returned object";
}

sub entries_count : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'entries_count';
	is $self->obj->entries_count, 12, "... and should return the correct value";
}

sub foreach_entry_do : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'foreach_entry_do';
	
	my $iterations = 0;
	$self->obj->foreach_entry_do(sub{
		my ($arg) = @_;
		$iterations++ if ($arg =~ /^\d+$/);
	});
	is $iterations, $self->obj->entries_count, "... and should do the correct number of iterations";
	
	$iterations = 0;
	$self->obj->foreach_entry_do(sub{
		my ($arg) = @_;
		$iterations++ if ($arg =~ /^\d+$/);
		return 'break_loop' if ($iterations == 3)
	});
	is $iterations, 3, "... and should break when requested";
}

sub foreach_entry_on_secondary_key_do : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'foreach_entry_on_secondary_key_do';
	
	my $iterations = 0;
	$self->obj->foreach_entry_on_secondary_key_do('chr3', sub{
		my ($arg) = @_;
		if ($arg =~ /^\d+$/) {
			$iterations++;
		}
	});
	is $iterations, 3, "... and should do the correct number of iterations";
}

sub add_entry : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'add_entry';
	
	$self->obj->add_entry(-1, 'chr7', 41);
	is $self->obj->entries_count, 13, "... and should result in the correct number of entries";
}

sub inc_entries_count : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, '_inc_entries_count';
	
	$self->obj->_inc_entries_count;
	is $self->obj->entries_count, 13, "... and should result in the correct number of entries";
}

sub primary_keys : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'primary_keys';
	is_deeply [$self->obj->primary_keys], [-1,1], "... and should return the correct value";
}

sub secondary_keys_for_primary_key : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'secondary_keys_for_primary_key';
	is_deeply [$self->obj->secondary_keys_for_primary_key(1)], ['chr1','chr2'], "... and should return the correct value";
	is_deeply [$self->obj->secondary_keys_for_primary_key(-1)], ['chr3','chr4'], "... and should return the correct value";
}

sub secondary_keys_for_all_primary_keys : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'secondary_keys_for_all_primary_keys';
	is_deeply [$self->obj->secondary_keys_for_all_primary_keys], ['chr1','chr2','chr3','chr4'], "... and should return the correct value";
}

sub entries_ref_for_keys : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'entries_ref_for_keys';
	is_deeply $self->obj->entries_ref_for_keys(1,'chr1'), [1,3,2], "... and should return the correct value";
}

sub is_empty : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'is_empty';
	is GenOO::Data::Structure::DoubleHashArray->new->is_empty, 1, "... and should return the correct value";
	is $self->obj->is_empty, 0, "... and should return the correct value";
}

sub is_not_empty : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'is_not_empty';
	is GenOO::Data::Structure::DoubleHashArray->new->is_not_empty, 0, "... and should return the correct value";
	is $self->obj->is_not_empty, 1, "... and should return the correct value";
}

sub sort_entries : Test(5) {
	my ($self) = @_;
	
	can_ok $self->obj, 'sort_entries';
	is $self->obj->is_not_sorted, 1, "... and initially should say that it is unsorted";
	is_deeply $self->obj->entries_ref_for_keys(1,'chr1'), [1,3,2], "... and should be unsorted";
	$self->obj->sort_entries;
	is $self->obj->is_sorted, 1, "... and then it should say that it is sorted";
	is_deeply $self->obj->entries_ref_for_keys(1,'chr1'), [1,2,3], "... and should be sorted";
}


#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
