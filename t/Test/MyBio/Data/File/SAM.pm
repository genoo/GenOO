package Test::MyBio::Data::File::SAM;
use strict;

use base qw(Test::MyBio);
use Test::More;

#######################################################################
############################   Accessors   ############################
#######################################################################

sub sample_line {
	return join("\t",(
		'HWI-EAS235_25:1:1:4282:1093','16','chr18','85867636','0','32M','*','0','0',
		'ATTCGGCAGGTGAGTTGTTACACACTCCTTAG','GHHGHHHGHHGGGDGEGHHHFHGG<GG>?BGG','XT:A:R','NM:i:0',
		'X0:i:2','X1:i:0','XM:i:0','XO:i:0','XG:i:0','MD:Z:32','XA:Z:chr9,+110183777,32M,0;'
	));
}

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
	
	$self->{OBJ} = $self->class->new({
		FILE => 't/sample_data/sample.sam.gz'
	});
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj, $self->class, "... and the object";
}

sub file : Test(1) {
	my ($self) = @_;
	
	is $self->obj->file, 't/sample_data/sample.sam.gz', 'file should give t/sample_data/sample.sam.gz';
}

sub filehandle : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj->filehandle, 'FileHandle', 'object returned by filehandle';
}

sub header_cache : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj->header_cache, 'ARRAY', 'object returned by header_cache';
}

sub records_cache : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj->records_cache, 'ARRAY', 'object returned by records_cache';
}

sub next_record : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj->next_record, 'MyBio::Data::File::SAM::Record', 'object returned by next_record';
}

sub next_record_from_file : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj->next_record_from_file, 'MyBio::Data::File::SAM::Record', 'object returned by next_record_from_file';
}

sub next_record_from_cache : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj->next_record_from_cache, 'MyBio::Data::File::SAM::Record', 'object returned by next_record_from_cache';
}

sub parse_record_line : Test(2) {
	my ($self) = @_;
	
	my $record = $self->obj->parse_record_line($self->sample_line);
	isa_ok $record, 'MyBio::Data::File::SAM::Record', 'object returned by parse_record_line';
	local $TODO = "sam record object check currently unimplemented";
# 	is_deeply($record, $record);
}

sub record_cache_not_empty : Test(2) {
	my ($self) = @_;
	
	is $self->obj->record_cache_not_empty, 1, 'record_cache_not_empty should give 1 (not empty)';
	
	$self->obj->next_record;
	is $self->obj->record_cache_not_empty, 0, 'record_cache_not_empty should give 0 (empty)';
}

sub header_cache_not_empty : Test(1) {
	my ($self) = @_;
	
	is $self->obj->header_cache_not_empty, 1, 'header_cache_not_empty should give 1 (not empty)';
}

sub record_cache_is_empty : Test(2) {
	my ($self) = @_;
	
	is $self->obj->record_cache_is_empty, 0, 'record_cache_is_empty should give 0';
	
	$self->obj->next_record;
	is $self->obj->record_cache_is_empty, 1, 'record_cache_is_empty should give 1 (empty)';
}

sub header_cache_is_empty : Test(1) {
	my ($self) = @_;
	
	is $self->obj->header_cache_is_empty, 0, 'header_cache_is_empty should give 0 (not empty)';
}

sub record_cache_size : Test(2) {
	my ($self) = @_;
	
	is $self->obj->record_cache_size, 1, 'record_cache_size should return 1';
	
	$self->obj->next_record;
	is $self->obj->record_cache_size, 0, 'record_cache_size should return 0';
}

sub header_cache_size : Test(1) {
	my ($self) = @_;
	
	is $self->obj->header_cache_size, 22, 'header_cache_size should give 24';
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
