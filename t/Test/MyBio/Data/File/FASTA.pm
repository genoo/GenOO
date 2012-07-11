package Test::MyBio::Data::File::FASTA;
use strict;

use base qw(Test::MyBio);
use Test::More;


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
	
	$self->{OBJ} = MyBio::Data::File::FASTA->new({
		FILE => 't/sample_data/sample.fa.gz'
	});
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj, $self->class, "... and the object";
}

sub file : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'file';
	is $self->obj->file, 't/sample_data/sample.fa.gz', "... and should return the correct value";
}

sub eof : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'is_eof_reached';
	is $self->obj->is_eof_reached, 0, "... and should return the correct value";
	
	while ($self->obj->next_record) {}
	is $self->obj->is_eof_reached, 1, "... and should return the correct value again";
}

sub filehandle : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'filehandle';
	isa_ok $self->obj->filehandle, 'FileHandle', "... and the returned object";
}

sub record_header_cache : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'record_header_cache';
	is $self->obj->record_header_cache, undef, "... and should be empty";
}

sub record_seq_cache : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'record_seq_cache';
	is $self->obj->record_seq_cache, undef, "... and should be empty";
}

sub records_read_count : Test(5) {
	my ($self) = @_;
	
	can_ok $self->obj, 'records_read_count';
	is $self->obj->records_read_count, 0, "... and should return the correct value";
	
	$self->obj->next_record();
	is $self->obj->records_read_count, 1, "... and should return the correct value again";
	
	$self->obj->next_record();
	is $self->obj->records_read_count, 2, "... and again";
	
	while ($self->obj->next_record()) {}
	is $self->obj->records_read_count, 10, "... and again (when the whole file is read)";
}

sub init_record_header_cache : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'init_record_header_cache';
	
	$self->obj->set_record_header_cache('test');
	$self->obj->init_record_header_cache;
	is $self->obj->record_header_cache, undef, "... and should empty header cache";
}

sub init_seq_cache : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'init_seq_cache';
	
	$self->obj->add_to_seq_cache('test');
	$self->obj->init_seq_cache;
	is $self->obj->record_seq_cache, undef, "... and should empty seq cache";
}

sub init_records_read_count : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'init_records_read_count';
	
	$self->obj->increment_records_read_count;
	$self->obj->init_records_read_count;
	is $self->obj->records_read_count, 0, "... and should return the correct value";
}

sub increment_records_read_count : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'increment_records_read_count';
	
	$self->obj->increment_records_read_count();
	is $self->obj->records_read_count, 1, "... and should result in the correct value";
}

sub set_record_header_cache : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'set_record_header_cache';
	
	$self->obj->set_record_header_cache('test');
	is $self->obj->record_header_cache, 'test', "... and should return the correct value";
}

sub add_to_seq_cache : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'add_to_seq_cache';
	
	$self->obj->add_to_seq_cache('test');
	is $self->obj->record_seq_cache, 'test', "... and should return the correct value";
	$self->obj->add_to_seq_cache('test');
	is $self->obj->record_seq_cache, 'testtest', "... and should return the correct value again";
}

sub next_record : Test(7) {
	my ($self) = @_;
	
	can_ok $self->obj, 'next_record';
	
	my $record = $self->obj->next_record;
	isa_ok $record, 'MyBio::Data::File::FASTA::Record', "... and the returned object";
	is $record->header, 'HWI-asadasASooo_1',  "... and should return the correct value";
	is $record->sequence, 'AAATANNCGTCGAAGATGTAAAGAAAACCGACTTTAATAATGT',  "... and should return the correct value";
	
	$record = $self->obj->next_record;
	isa_ok $record, 'MyBio::Data::File::FASTA::Record', "... and the returned object";
	is $record->header, 'HWI-asadasASooo_2',  "... and should return the correct value";
	is $record->sequence, 'TTTTANNTAAATTTATGCATAGACCGACTTTAATAATGT',  "... and should return the correct value";
}

sub line_looks_like_record_header : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'line_looks_like_record_header';
	
	my $line = '>test';
	is $self->obj->line_looks_like_record_header($line), 1, "... and should return the correct value";

	$line = ' test ';
	is $self->obj->line_looks_like_record_header($line), 0, "... and should return the correct value again";
}

sub line_looks_like_sequence : Test(6) {
	my ($self) = @_;
	
	can_ok $self->obj, 'line_looks_like_sequence';
	
	my $line = 'cctFa';
	is $self->obj->line_looks_like_sequence($line), 1, "... and should return the correct value";
	
	$line = '>test';
	is $self->obj->line_looks_like_sequence($line), 0, "... and should return the correct value again";
	
	$line = '';
	is $self->obj->line_looks_like_sequence($line), 0, "... and should return the correct value again";
	
	$line = "\t\t  \t\n";
	is $self->obj->line_looks_like_sequence($line), 0, "... and should return the correct value again";
	
	$line = "\n";
	is $self->obj->line_looks_like_sequence($line), 0, "... and should return the correct value again";
}

sub record_header_cache_not_empty : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'record_header_cache_not_empty';
	is $self->obj->record_header_cache_not_empty, 0, "... and should return the correct value";
	
	$self->obj->next_record;
	is $self->obj->record_header_cache_not_empty, 1, "... and should return the correct value again";
}

sub record_header_cache_is_empty : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'record_header_cache_is_empty';
	is $self->obj->record_header_cache_is_empty, 1, "... and should return the correct value";
	
	$self->obj->next_record;
	is $self->obj->record_header_cache_is_empty, 0, "... and should return the correct value again";
}

sub is_eof_reached : Test(4) {
	my ($self) = @_;
	
	can_ok $self->obj, 'is_eof_reached';
	
	is $self->obj->is_eof_reached, 0, "... and should return the correct value";
	
	$self->obj->next_record();
	is $self->obj->is_eof_reached, 0, "... and should return the correct value again";
	
	while ($self->obj->next_record()) {}
	is $self->obj->is_eof_reached, 1, "... and again (when the whole file is read)";
}


#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}


1;
