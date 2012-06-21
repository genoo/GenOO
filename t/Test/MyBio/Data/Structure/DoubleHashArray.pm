package Test::MyBio::Data::Structure::DoubleHashArray;
use strict;

use base qw(Test::MyBio);
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
	
	$self->{OBJ} = MyBio::Data::Structure::DoubleHashArray->new();
	$self->obj->add_entry(1, 'chr1', 1);
	$self->obj->add_entry(1, 'chr1', 2);
	$self->obj->add_entry(1, 'chr1', 3);
	$self->obj->add_entry(1, 'chr2', 11);
	$self->obj->add_entry(1, 'chr2', 12);
	$self->obj->add_entry(1, 'chr2', 13);
	$self->obj->add_entry(-1, 'chr3', 21);
	$self->obj->add_entry(-1, 'chr3', 22);
	$self->obj->add_entry(-1, 'chr3', 23);
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
	
	can_ok $self->obj, 'structure';
	isa_ok $self->obj->structure, 'HASH', "... and returned object";
}

sub entries_count : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'entries_count';
	is $self->obj->entries_count, 12, "... and should return the correct value";
}

sub init : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'init';
	
	$self->obj->init;
	is scalar($self->obj->primary_keys), 0, "... and should be empty";
}

sub foreach_entry_do : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'foreach_entry_do';
	
	my $iterations = 0;
	$self->obj->foreach_entry_do(sub{
		my ($arg) = @_;
		if ($arg =~ /^\d+$/) {
			$iterations++;
		}
	});
	is $iterations, $self->obj->entries_count, "... and should do the correct number of iterations";
}

sub add_entry : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'add_entry';
	
	$self->obj->add_entry(-1, 'chr7', 41);
	is $self->obj->entries_count, 13, "... and should result in the correct number of entries";
}

sub increment_entries_count : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'increment_entries_count';
	
	$self->obj->increment_entries_count;
	is $self->obj->entries_count, 13, "... and should result in the correct number of entries";
}

sub primary_keys : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'primary_keys';
	is_deeply [$self->obj->primary_keys], [1,-1], "... and should return the correct value";
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
	is_deeply [$self->obj->secondary_keys_for_all_primary_keys], ['chr3','chr1','chr4','chr2'], "... and should return the correct value";
}

sub entries_ref_for_keys : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'entries_ref_for_keys';
	is_deeply $self->obj->entries_ref_for_keys(1,'chr1'), [1,2,3], "... and should return the correct value";
}

sub is_empty : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'is_empty';
	is MyBio::Data::Structure::DoubleHashArray->new->is_empty, 1, "... and should return the correct value";
	is $self->obj->is_empty, 0, "... and should return the correct value";
}

sub is_not_empty : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'is_not_empty';
	is MyBio::Data::Structure::DoubleHashArray->new->is_not_empty, 0, "... and should return the correct value";
	is $self->obj->is_not_empty, 1, "... and should return the correct value";
}


#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
