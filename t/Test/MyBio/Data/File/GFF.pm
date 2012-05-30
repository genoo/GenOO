package Test::MyBio::Data::File::GFF;
use strict;

use base qw(Test::MyBio);
use Test::More;

#######################################################################
############################   Accessors   ############################
#######################################################################
sub gff {
	my ($self) = @_;
	return $self->{GFF};
}

#######################################################################
################   Startup (Runs once in the begining  ################
#######################################################################
sub startup : Test(startup => 3) {
	my ($self) = @_;
	
	use_ok $self->class;
	can_ok $self->class, 'new';
	
	ok $self->{GFF} = MyBio::Data::File::GFF->new({
		FILE => 't/sample_data/sample.gff.gz'
	}), '... and the constructor succeeds';
};

#######################################################################
#################   Setup (Runs before every method)  #################
#######################################################################
sub new_object : Test(setup) {
	my ($self) = @_;
	
	$self->{GFF} = MyBio::Data::File::GFF->new({
		FILE => 't/sample_data/sample.gff.gz'
	});
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->gff, $self->class, "... and the object";
}

sub get_file : Test(2) {
	my ($self) = @_;
	
	can_ok $self->gff, 'get_file';
	is $self->gff->get_file, 't/sample_data/sample.gff.gz', "... and should return the correct value";
}

sub get_eof : Test(3) {
	my ($self) = @_;
	
	can_ok $self->gff, 'get_eof';
	is $self->gff->get_eof, undef, "... and should return the correct value";
	
	while ($self->gff->next_record) {}
	is $self->gff->get_eof, 1, "... and should return the correct value again";
}

sub filehandle : Test(2) {
	my ($self) = @_;
	
	can_ok $self->gff, 'filehandle';
	isa_ok $self->gff->filehandle, 'FileHandle', "... and the returned object";
}

sub header : Test(2) {
	my ($self) = @_;
	
	can_ok $self->gff, 'header';
	isa_ok $self->gff->header, 'HASH', "... and the returned object";
}

sub records_cache : Test(2) {
	my ($self) = @_;
	
	can_ok $self->gff, 'records_cache';
	isa_ok $self->gff->records_cache, 'ARRAY', "... and the returned object";
}

sub records_read_count : Test(4) {
	my ($self) = @_;
	
	can_ok $self->gff, 'records_read_count';
	is $self->gff->records_read_count, 0, "... and should return the correct value";
	
	$self->gff->next_record();
	is $self->gff->records_read_count, 1, "... and should return the correct value again";
	
	$self->gff->next_record();
	is $self->gff->records_read_count, 2, "... and again";
}

sub version : Test(2) {
	my ($self) = @_;
	
	can_ok $self->gff, 'version';
	is $self->gff->version, 2, "... and should return the correct value";
}

sub increment_records_read_count : Test(2) {
	my ($self) = @_;
	
	can_ok $self->gff, 'increment_records_read_count';
	
	$self->gff->increment_records_read_count();
	is $self->gff->records_read_count, 1, "... and should result in the correct value";
}

sub next_record : Test(2) {
	my ($self) = @_;
	
	can_ok $self->gff, 'next_record';
	isa_ok $self->gff->next_record, 'MyBio::Data::File::GFF::Record', "... and the returned object";
}

sub get_next_record_from_file : Test(2) {
	my ($self) = @_;
	
	can_ok $self->gff, 'get_next_record_from_file';
	isa_ok $self->gff->get_next_record_from_file, 'MyBio::Data::File::GFF::Record', "... and the returned object";
}

sub get_next_record_from_cache : Test(2) {
	my ($self) = @_;
	
	can_ok $self->gff, 'get_next_record_from_cache';
	isa_ok $self->gff->get_next_record_from_cache, 'MyBio::Data::File::GFF::Record', "... and the returned object";
}

sub parse_record_line : Test(3) {
	my ($self) = @_;
	
	my $line = join(/\t/,(
		'chr1','MirBase','miRNA','151518272','151518367','0.5','+','.',
		'ACC="MI0003559"; ID="hsa-mir-554"; #Comment'
	));
	
	can_ok $self->gff, 'parse_record_line';
	isa_ok $self->gff->parse_record_line($line), 'MyBio::Data::File::GFF::Record', "... and the returned object";
	local $TODO = "Check for the record returned is currently unimplemented";
}

sub line_looks_like_comment : Test(3) {
	my ($self) = @_;
	
	my $line = '# Genome assembly:  GRCh37';
	can_ok $self->gff, 'line_looks_like_comment';
	is $self->gff->line_looks_like_comment($line), 1, "... and should return the correct value";
	
	$line = '##gff-version 2';
	is $self->gff->line_looks_like_comment($line), 0, "... and should return the correct value again";
}

sub line_looks_like_header : Test(3) {
	my ($self) = @_;
	
	my $line = '##gff-version 2';
	can_ok $self->gff, 'line_looks_like_header';
	is $self->gff->line_looks_like_header($line), 1, "... and should return the correct value";
	
	$line = '# Genome assembly:  GRCh37';
	is $self->gff->line_looks_like_header($line), 0, "... and should return the correct value again";
}

sub line_looks_like_record : Test(3) {
	my ($self) = @_;
	
	my $line = join(/\t/,(
		'chr1','MirBase','miRNA','151518272','151518367','0.5','+','.',
		'ACC="MI0003559"; ID="hsa-mir-554"; #Comment'
	));
	can_ok $self->gff, 'line_looks_like_record';
	is $self->gff->line_looks_like_record($line), 1, "... and should return the correct value";
	
	$line = '# Genome assembly:  GRCh37';
	is $self->gff->line_looks_like_record($line), 0, "... and should return the correct value again";
}

sub line_looks_like_version : Test(3) {
	my ($self) = @_;
	
	my $line = '##gff-version 2';
	can_ok $self->gff, 'line_looks_like_version';
	is $self->gff->line_looks_like_version($line), 1, "... and should return the correct value";
	
	$line = '# Genome assembly:  GRCh37';
	is $self->gff->line_looks_like_version($line), 0, "... and should return the correct value again";
}

sub record_cache_not_empty : Test(3) {
	my ($self) = @_;
	
	can_ok $self->gff, 'record_cache_not_empty';
	is $self->gff->record_cache_not_empty, 1, "... and should return the correct value";
	
	$self->gff->next_record;
	is $self->gff->record_cache_not_empty, 0, "... and should return the correct value again";
}

sub record_cache_is_empty : Test(3) {
	my ($self) = @_;
	
	can_ok $self->gff, 'record_cache_is_empty';
	is $self->gff->record_cache_is_empty, 0, "... and should return the correct value";
	
	$self->gff->next_record;
	is $self->gff->record_cache_is_empty, 1, "... and should return the correct value again";
}

sub record_cache_size : Test(3) {
	my ($self) = @_;
	
	can_ok $self->gff, 'record_cache_size';
	is $self->gff->record_cache_size, 1, "... and should return the correct value";
	
	$self->gff->next_record;
	is $self->gff->record_cache_size, 0, "... and should return the correct value again";
}

1;
