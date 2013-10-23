package TestsFor::GenOO::RegionCollection::Factory::DBIC;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Test::Class::Moose;


#######################################################################
############################   Inheritance   ##########################
#######################################################################
with 'MyTCM::Testable';


#######################################################################
#################   Setup (Runs before every method)  #################
#######################################################################
sub test_setup {
	my ( $test, $report ) = @_;
	
	$test->next::method;
	$test->_clear_testable_objects;
}


#######################################################################
###########################   Test methods   ##########################
#######################################################################
sub test_class_type {
	my ($test) = @_;
	
	isa_ok $test->get_testable_object(0), $test->class_name, "1st object";
	isa_ok $test->get_testable_object(1), $test->class_name, "2nd object";
}

sub test_dsn {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'dsn';
	
	my $expected_0 = 'dbi:SQLite:database=t/sample_data/sample.alignments.sqlite.db';
	is $test->get_testable_object(0)->dsn, $expected_0, "dsn should be correct";
	my $expected_1 = 'dbi:mysql:database=sample_db;host=localhost;port=3306';
	is $test->get_testable_object(1)->dsn, $expected_1, "dsn should be created correctly";
}


sub test_read_collection {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(1), 'read_collection';
	
	isa_ok $test->get_testable_object(0)->read_collection, 'GenOO::RegionCollection::Type::DBIC', "returned object";
}

# 
# sub test_next_record {
# 	my ($test) = @_;
# 	
# 	can_ok $test->get_testable_object(0), 'next_record';
# 	isa_ok $test->get_testable_object(0)->next_record, 'GenOOx::Data::File::SAMbwa::Record', "... and the returned object";
# }
# 
# sub test_parse_record_line {
# 	my ($test) = @_;
# 	
# 	can_ok $test->get_testable_object(0), '_parse_record_line';
# 	
# 	my $sample_line = join("\t",('HWI-EAS235_25:1:1:4282:1093', '16', 'chr18', '85867636', '0', '32M', '*', '0', '0', 'ATTCGGCAGGTGAGTTGTTACACACTCCTTAG', 'GHHGHHHGHHGGGDGEGHHHFHGG<GG>?BGG', 'XT:A:R', 'NM:i:0', 'X0:i:2', 'X1:i:0', 'XM:i:0', 'XO:i:0', 'XG:i:0', 'MD:Z:32', 'XA:Z:chr9,+110183777,32M,0;'));
# 	
# 	my $record = $test->get_testable_object(0)->_parse_record_line($sample_line);
# 	isa_ok $record, 'GenOOx::Data::File::SAMbwa::Record', '... and object returned';
# 	is $record->qname, 'HWI-EAS235_25:1:1:4282:1093', '... and should contain correct value';
# 	is $record->flag, '16', '... and should contain correct value again';
# 	is $record->rname, 'chr18', '... and again';
# 	is $record->pos, 85867636, '... and again';
# 	is $record->mapq, '0', '... and again';
# 	is $record->cigar, '32M', '... and again';
# 	is $record->rnext, '*', '... and again';
# 	is $record->pnext, 0, '... and again';
# 	is $record->tlen, 0, '... and again';
# 	is $record->seq, 'ATTCGGCAGGTGAGTTGTTACACACTCCTTAG', '... and again';
# 	is $record->qual, 'GHHGHHHGHHGGGDGEGHHHFHGG<GG>?BGG', '... and again';
# 	is $record->tag('XT:A'), 'R', '... and again';
# 	is $record->tag('NM:i'), '0', '... and again';
# 	is $record->tag('X0:i'), '2', '... and again';
# 	is $record->tag('X1:i'), '0', '... and again';
# 	is $record->tag('XM:i'), '0', '... and again';
# 	is $record->tag('XO:i'), '0', '... and again';
# 	is $record->tag('XG:i'), '0', '... and again';
# 	is $record->tag('MD:Z'), '32', '... and again';
# 	is $record->tag('XA:Z'), 'chr9,+110183777,32M,0;', '... and again';
# }


#######################################################################
#########################   Private Methods   #########################
#######################################################################
sub _init_testable_objects {
	my ($test) = @_;
	
	return [$test->map_data_for_testable_objects(sub {$test->class_name->new($_)})];
}

sub _init_data_for_testable_objects {
	my ($test) = @_;
	
	my @data;
	
	push @data, {
		dsn => 'dbi:SQLite:database=t/sample_data/sample.alignments.sqlite.db',
	};
	
	push @data, {
		driver   => 'mysql',
		database => 'sample_db',
		host     => 'localhost',
		port     => '3306',
	};
	
	return \@data;
}

1;
