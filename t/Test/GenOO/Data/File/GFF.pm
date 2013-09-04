package Test::GenOO::Data::File::GFF;
use strict;

use base qw(Test::GenOO);
use Test::Moose;
use Test::Most;
use Test::Exception;


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
	
	ok $self->{OBJ} = GenOO::Data::File::GFF->new(
		file => 't/sample_data/sample.gff.gz'
	);
};

#######################################################################
##########################   Initial Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj, $self->class, "... and the object";
}

#######################################################################
##########################   Interface Tests   ########################
#######################################################################
sub file : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj, 'file', "... test object has the 'file' attribute");
	is $self->obj->file, 't/sample_data/sample.gff.gz', "... and should return the correct value";
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
	is $self->obj->records_read_count, 93, "... and again (when the whole file is read)";
}

sub version : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'version';
	is $self->obj->version, 2, "... and should return the correct value";
}

sub next_record : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'next_record';
	isa_ok $self->obj->next_record, 'GenOO::Data::File::GFF::Record', "... and the returned object";
}

#######################################################################
###########################   Private Tests   #########################
#######################################################################
sub eof : Test(3) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj, '_eof_reached', "... test object has the '_eof_reached' attribute");
	is $self->obj->_eof_reached, 0, "... and should return the correct value";
	
	while ($self->obj->next_record) {}
	is $self->obj->_eof_reached, 1, "... and should return the correct value again";
}

sub header : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj, '_header', "... test object has the '_header' attribute");
	isa_ok $self->obj->_header, 'HASH', "... and the returned object";
}

sub cached_records : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj, '_cached_records', "... test object has the '_cached_records' attribute");
	isa_ok $self->obj->_cached_records, 'ARRAY', "... and the returned object";
}

sub next_record_from_file : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, '_next_record_from_file';
	isa_ok $self->obj->_next_record_from_file, 'GenOO::Data::File::GFF::Record', "... and the returned object";
}

sub shift_cached_record : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, '_shift_cached_record';
	isa_ok $self->obj->_shift_cached_record, 'GenOO::Data::File::GFF::Record', "... and the returned object";
}

sub parse_record_line : Test(12) {
	my ($self) = @_;
	
	can_ok $self->obj, '_parse_record_line';
	
	my $line = qq{chr1\tsource\tfeature\t15\t16\t7\t+\t.\tACC="MI02"; ID="mi02";#Comment};
	my $record =  $self->obj->_parse_record_line($line);
	isa_ok $record, 'GenOO::Data::File::GFF::Record', "... and the returned object";
	is $record->seqname, 'chr1', "... and should have the correct value";
	is $record->source, 'source', "... and again";
	is $record->feature, 'feature', "... and again";
	is $record->start, '14', "... and again";
	is $record->stop, '15', "... and again";
	is $record->score, 7, "... and again";
	is $record->strand, 1, "... and again";
	is $record->frame, '.', "... and again";
	is $record->attribute('ACC'), 'MI02', "... and again";
	is $record->attribute('ID'), 'mi02', "... and again";
}

sub line_looks_like_header : Test(3) {
	my ($self) = @_;
	
	my $line = '##gff-version 2';
	can_ok $self->obj, '_line_looks_like_header';
	is $self->obj->_line_looks_like_header($line), 1, "... and should return the correct value";
	
	$line = '# Genome assembly:  GRCh37';
	is $self->obj->_line_looks_like_header($line), 0, "... and should return the correct value again";
}

sub line_looks_like_record : Test(3) {
	my ($self) = @_;
	
	my $line = join("\t",(
		'chr1','MirBase','miRNA','151518272','151518367','0.5','+','.',
		'ACC="MI0003559"; ID="hsa-mir-554"; #Comment'
	));
	can_ok $self->obj, '_line_looks_like_record';
	is $self->obj->_line_looks_like_record($line), 1, "... and should return the correct value";
	
	$line = '# Genome assembly:  GRCh37';
	is $self->obj->_line_looks_like_record($line), 0, "... and should return the correct value again";
}

sub line_looks_like_version : Test(3) {
	my ($self) = @_;
	
	my $line = '##gff-version 2';
	can_ok $self->obj, '_line_looks_like_version';
	is $self->obj->_line_looks_like_version($line), 1, "... and should return the correct value";
	
	$line = '# Genome assembly:  GRCh37';
	is $self->obj->_line_looks_like_version($line), 0, "... and should return the correct value again";
}

sub has_cached_records : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, '_has_cached_records';
	is $self->obj->_has_cached_records, 1, "... and should return the correct value";
	
	$self->obj->next_record;
	is $self->obj->_has_cached_records, 0, "... and should return the correct value again";
}

sub has_no_cached_records : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, '_has_no_cached_records';
	is $self->obj->_has_no_cached_records, 0, "... and should return the correct value";
	
	$self->obj->next_record;
	is $self->obj->_has_no_cached_records, 1, "... and should return the correct value again";
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
