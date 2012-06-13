package Test::MyBio::Data::File::BED;
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
sub new_object : Test(setup => 1) {
	my ($self) = @_;
	
	ok $self->{OBJ} = MyBio::Data::File::BED->new({
		FILE => 't/sample_data/sample.bed.gz'
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
	is $self->obj->file, 't/sample_data/sample.bed.gz', "... and should return the correct value";
}

sub eof : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'is_eof_reached';
	is $self->obj->is_eof_reached, undef, "... and should return the correct value";
	
	while ($self->obj->next_record) {}
	is $self->obj->is_eof_reached, 1, "... and should return the correct value again";
}

sub filehandle : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'filehandle';
	isa_ok $self->obj->filehandle, 'FileHandle', "... and the returned object";
}

sub header : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'header';
	isa_ok $self->obj->header, 'HASH', "... and the returned object";
}

sub records_cache : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'records_cache';
	isa_ok $self->obj->records_cache, 'ARRAY', "... and the returned object";
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
	is $self->obj->records_read_count, 9, "... and again (when the whole file is read)";
}

sub increment_records_read_count : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'increment_records_read_count';
	
	$self->obj->increment_records_read_count();
	is $self->obj->records_read_count, 1, "... and should result in the correct value";
}

sub next_record : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'next_record';
	isa_ok $self->obj->next_record, 'MyBio::Data::File::BED::Record', "... and the returned object";
}

sub next_record_from_file : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'next_record_from_file';
	isa_ok $self->obj->next_record_from_file, 'MyBio::Data::File::BED::Record', "... and the returned object";
}

sub next_record_from_cache : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'next_record_from_cache';
	isa_ok $self->obj->next_record_from_cache, 'MyBio::Data::File::BED::Record', "... and the returned object";
}

sub parse_record_line : Test(14) {
	my ($self) = @_;
	
	my $line = join("\t",
		'chr7','127471196','127472363','Pos1','0','+','127471196','127472363',
		'255,0,0','2','100,200','0,900'
	);
	
	can_ok $self->obj, 'parse_record_line';
	
	my $record =  $self->obj->parse_record_line($line);
	isa_ok $record, 'MyBio::Data::File::BED::Record', "... and the returned object";
	
	is $record->chr, 'chr7', "... and should have the correct value";
	is $record->start, 127471196, "... and again";
	is $record->stop, 127472362, "... and again";
	is $record->name, 'Pos1', "... and again";
	is $record->score, 0, "... and again";
	is $record->strand, 1, "... and again";
	is $record->thick_start, 127471196, "... and again";
	is $record->thick_stop, 127472362, "... and again";
	is $record->rgb, '255,0,0', "... and again";
	is $record->block_count, 2, "... and again";
	is_deeply $record->block_sizes, [100,200], "... and again";
	is_deeply $record->block_starts, [0,900], "... and again";
}

sub line_looks_like_comment : Test(2) {
	my ($self) = @_;
	
	my $line = '# whatever';
	can_ok $self->obj, 'line_looks_like_comment';
	is $self->obj->line_looks_like_comment($line), 1, "... and should return the correct value";
}

sub line_looks_like_header : Test(4) {
	my ($self) = @_;
	
	my $line = 'browser position chr7:127471196-127495720';
	can_ok $self->obj, 'line_looks_like_header';
	is $self->obj->line_looks_like_header($line), 1, "... and should return the correct value";
	
	$line = 'track name="ItemRGBDemo"';
	is $self->obj->line_looks_like_header($line), 1, "... and should return the correct value again";
	
	$line = join("\t",('chr7','127471196','127472363'));
	is $self->obj->line_looks_like_header($line), 0, "... and should return the correct value again";
}

sub line_looks_like_record : Test(5) {
	my ($self) = @_;
	
	my $line = join("\t",('chr7','127471196','127472363'));
	can_ok $self->obj, 'line_looks_like_record';
	is $self->obj->line_looks_like_record($line), 1, "... and should return the correct value";
	
	$line = join("\t",('scaf1','127477031','127478198'));
	is $self->obj->line_looks_like_record($line), 1, "... and should return the correct value again";
	
	$line = 'track name="ItemRGBDemo"';
	is $self->obj->line_looks_like_record($line), 0, "... and should return the correct value again";
	
	$line = 'browser position chr7:127471196-127495720';
	is $self->obj->line_looks_like_record($line), 0, "... and should return the correct value again";
}

sub record_cache_not_empty : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'record_cache_not_empty';
	is $self->obj->record_cache_not_empty, 1, "... and should return the correct value";
	
	$self->obj->next_record;
	is $self->obj->record_cache_not_empty, 0, "... and should return the correct value again";
}

sub record_cache_is_empty : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'record_cache_is_empty';
	is $self->obj->record_cache_is_empty, 0, "... and should return the correct value";
	
	$self->obj->next_record;
	is $self->obj->record_cache_is_empty, 1, "... and should return the correct value again";
}

sub record_cache_size : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'record_cache_size';
	is $self->obj->record_cache_size, 1, "... and should return the correct value";
	
	$self->obj->next_record;
	is $self->obj->record_cache_size, 0, "... and should return the correct value again";
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}


1;
