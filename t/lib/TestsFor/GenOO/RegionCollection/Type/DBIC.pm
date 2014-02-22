package TestsFor::GenOO::RegionCollection::Type::DBIC;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Test::Class::Moose;
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
}

sub test_dsn {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'dsn';
	
	my $expected_0 = 'dbi:SQLite:database=t/sample_data/sample.alignments.sqlite.db';
	is $test->get_testable_object(0)->dsn, $expected_0, "dsn should be correct";
}

sub test_schema {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'schema';
	
	ok $test->get_testable_object(0)->schema, "connection succeeds";
}

sub test_resultset {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'resultset';
	
	ok $test->get_testable_object(0)->resultset, "connection succeeds";
}

sub test_longest_record {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'longest_record';
	
	is $test->get_testable_object(0)->longest_record->length, 34679, "finds longest record correctly";
}

sub test_foreach_record_do {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'foreach_record_do';
	
	my $counter = 0;
	$test->get_testable_object(0)->foreach_record_do(sub{$counter++;});
	is $counter, 976, "loops the correct number of times";
}

sub test_foreach_record_on_rname_do {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'foreach_record_on_rname_do';
	
	my $counter = 0;
	$test->get_testable_object(0)->foreach_record_on_rname_do('chr1', sub{$counter++; return 0;});
	is $counter, 57, "loops the correct number of times";
}

sub test_records_count {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'records_count';
	
	is $test->get_testable_object(0)->records_count, 976, "counts records correclty";
}

sub test_strands {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'strands';
	
	is $test->get_testable_object(0)->strands, 2, "returns correct number of strands";
}

sub test_rnames_for_strand {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'rnames_for_strand';
	
	is $test->get_testable_object(0)->rnames_for_strand(1), 21, "returns correct number of rnames";
}

sub test_rnames_for_all_strands {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'rnames_for_all_strands';
	
	is $test->get_testable_object(0)->rnames_for_all_strands, 22, "returns correct number of rnames";
}

sub test_emptiness {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'is_empty';
	can_ok $test->get_testable_object(0), 'is_not_empty';
	
	is $test->get_testable_object(0)->is_empty, 0, "returns false";
	is $test->get_testable_object(0)->is_not_empty, 1, "returns true";
}

sub test_foreach_contained_record_do {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'foreach_contained_record_do';
	
	my $counter = 0;
	$test->get_testable_object(0)->foreach_contained_record_do(
		'1',
		'chr1',
		101687273,
		162968261,
		sub{$counter++; return 0;}
	);
	is $counter, 5, "finds correct contained records";
}

sub test_records_contained_in_region {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'records_contained_in_region';
	
	is $test->get_testable_object(0)->records_contained_in_region(
		'1',
		'chr1',
		101687273,
		162968261
	), 5, "finds correct contained records";
}

sub test_total_copy_number_for_records_contained_in_region {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'total_copy_number_for_records_contained_in_region';
	
	is $test->get_testable_object(0)->total_copy_number_for_records_contained_in_region(
		'1',
		'chr1',
		101687273,
		162968261
	), 5, "finds correct contained records";
}

sub test_total_copy_number {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'total_copy_number';
	
	is $test->get_testable_object(0)->total_copy_number, 977, "finds correct contained records";
}

sub test_filter_by_length {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'filter_by_length';
	
	$test->get_testable_object(0)->filter_by_length(35,45);
	is $test->get_testable_object(0)->records_count, 5, "filters correctly by size";
}

sub test_filter_by_min_length {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'filter_by_min_length';
	
	$test->get_testable_object(0)->filter_by_min_length(35);
	is $test->get_testable_object(0)->records_count, 107, "filters correctly by size";
}

sub test_filter_by_max_length {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'filter_by_max_length';
	
	$test->get_testable_object(0)->filter_by_max_length(45);
	is $test->get_testable_object(0)->records_count, 874, "filters correctly by size";
}

sub test_simple_filter {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'simple_filter';
	
	$test->get_testable_object(0)->simple_filter('alignment_length', '>=35');
	is $test->get_testable_object(0)->records_count, 107, "filters correctly by size";
	$test->get_testable_object(0)->simple_filter('alignment_length', '<=45');
	is $test->get_testable_object(0)->records_count, 5, "filters correctly by size";
	$test->get_testable_object(0)->simple_filter('rname', '==chr13');
	is $test->get_testable_object(0)->records_count, 2, "filters correctly by size";
}

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
		dsn           => 'dbi:SQLite:database=t/sample_data/sample.alignments.sqlite.db',
		table         => 'sample',
		name          => 'Test 0',
		species       => 'mouse',
		description   => 'Just a test',
		records_class => 'GenOO::Data::DB::DBIC::Species::Schema::SampleResultBase::v2',
	};
	
	return \@data;
}

1;
