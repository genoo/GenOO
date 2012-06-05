package Test::MyBio::Data::File::GFF::Tag;
use strict;

use base qw(Test::MyBio);
use Test::More;

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
sub startup : Test(startup => 3) {
	my ($self) = @_;
	
	use_ok $self->class;
	can_ok $self->class, 'new';
	
	ok $self->{OBJ} = MyBio::Data::File::GFF::Tag->new({
	}), '... and the constructor succeeds';
};

#######################################################################
#################   Setup (Runs before every method)  #################
#######################################################################
sub new_object : Test(setup) {
	my ($self) = @_;
	
	my $record_data = {
		SEQNAME     => 'chr1',
		SOURCE      => 'MirBase',
		FEATURE     => 'miRNA',
		START_1     => '151518272',
		STOP_1      => '151518367',
		SCORE       => 0.5,
		STRAND      => '+',
		FRAME       => '.',
		ATTRIBUTES  => ['ACC="MI0003559"','ID="hsa-mir-554"'],
		COMMENT     => 'This is just a test line',
	};
	my $record = MyBio::Data::File::GFF::Record->new($record_data);
	
	$self->{OBJ} = MyBio::Data::File::GFF::Tag->new({
		RECORD => $record,
	});
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj, $self->class, "... and the object";
}

sub get_record : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_record';
	isa_ok $self->obj->get_record, 'MyBio::Data::File::GFF::Record', "... and returned object";
}

sub get_strand : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_strand';
	
	is $self->obj->get_strand, 1, "... and should return the correct value";
}

sub get_chr : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_chr';
	
	is $self->obj->get_chr, 'chr1', "... and should return the correct value";
}

sub get_start : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_start';
	
	is $self->obj->get_start, 151518271, "... and should return the correct value";
}

sub get_stop : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_stop';
	
	is $self->obj->get_stop, 151518366, "... and should return the correct value";
}

sub get_name : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_name';
	
	is $self->obj->get_name, 'miRNA', "... and should return the correct value";
}

sub get_score : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_score';
	
	is $self->obj->get_score, 0.5, "... and should return the correct value";
}

1;
