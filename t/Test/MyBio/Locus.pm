package Test::MyBio::Locus;
use strict;

use base qw(Test::MyBio);
use Test::More;
use Test::TestObjects;

#######################################################################
###########################   Test Data     ###########################
#######################################################################

sub sample_object {
	return Test::TestObjects->get_testobject_MyBio_Locus;
}
sub data {
	return {
		species => {
			INPUT  => ['anything'],
			OUTPUT => ['ANYTHING']
		},
		strand => {
			INPUT  => ['+','-','1','-1'],
			OUTPUT => ['1','-1','1','-1']
		},
		'chr' => {
			INPUT  => ['chr9','9','>chrZ'],
			OUTPUT => ['chr9','9','chrZ']
		},
		start => {
			INPUT  => ['10000'],
			OUTPUT => ['10000']
		},
		stop => {
			INPUT  => ['10000'],
			OUTPUT => ['10000']
		},
		sequence => {
			INPUT  => ['CGATGCTACTA'],
			OUTPUT => ['CGATGCTACTA']
		},
		name => {
			INPUT  => ['anything'],
			OUTPUT => ['anything']
		},
		extra => {
			INPUT  => ['anything'],
			OUTPUT => ['anything']
		},
		strand_symbol => {
			INPUT  => ['1','-1','anything_else'],
			OUTPUT => ['+','-',undef]
		},
		get_5p => {
			INPUT  => [sample_object->[0],sample_object->[1],'anything_else'],
			OUTPUT => ['10000','10100',undef]
		},
		get_3p => {
			INPUT  => [sample_object->[0],sample_object->[1],'anything_else'],
			OUTPUT => ['10100','10000',undef]
		},
		id => {
			INPUT  => [sample_object->[0]],
			OUTPUT => ['chr9:10000-10100:1']
		},
		location => {
			INPUT  => [sample_object->[0]],
			OUTPUT => ['chr9:10000-10100:1']
		},
		to_string => {
			INPUT  => [sample_object->[0]],
			OUTPUT => ["chr9\t10000\t10101\ttest_locus_generic\t0\t+"]
		},
		to_string_bed => {
			INPUT  => [sample_object->[0],sample_object->[2]],
			OUTPUT => ["chr9\t10000\t10101\ttest_locus_generic\t0\t+", "chr9\t10000\t10101\t.\t0\t."]
		},
		get_5p_5p_distance_from => {
			INPUT  => [sample_object->[0]],
			OUTPUT => ["-100","100","-100","100"]
		},
		get_5p_3p_distance_from => {
			INPUT  => [sample_object->[0]],
			OUTPUT => ["-100","100","-100","100"]
		},
		get_3p_5p_distance_from => {
			INPUT  => [sample_object->[0]],
			OUTPUT => ["-100","100","-100","100"]
		},
		get_3p_3p_distance_from => {
			INPUT  => [sample_object->[0]],
			OUTPUT => ["-100","100","-100","100"]
		},
		overlaps => {
			INPUT  => [sample_object->[0]],
			OUTPUT => ["0","1","0","1"]
		},
		get_overlap_length => {
			INPUT  => [sample_object->[0]],
			OUTPUT => ["0","90"]
		},
		contains => {
			INPUT  => [sample_object->[0]],
			OUTPUT => ["0","1"]
		},
		contains_position => {
			INPUT  => [sample_object->[0],],
			OUTPUT => ["0","1"]
		},
		get_contained_locuses => {
			INPUT  => [sample_object->[0]],
			OUTPUT => ['ARRAY', 9]
		},
		get_touching_locuses => {
			INPUT  => [sample_object->[0]],
			OUTPUT => ['ARRAY', 9]
		},
	};

}
#######################################################################
###########################   Basic Tests   ###########################
#######################################################################
sub _loading_test : Test(4) {
	my ($self) = @_;
	
	use_ok $self->class;
	can_ok $self->class, 'new';
 	ok my $obj = $self->class->new(sample_object->[0]), '... and the constructor succeeds';
 	isa_ok $obj, $self->class, '... and the object';
}

# #######################################################################
# #########################   Attributes Tests   ########################
# #######################################################################
sub species : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('species', $self->get_input_for('species')->[0], $self->get_output_for('species')->[0]);
}
sub strand : Test(16) {
	my ($self) = @_;
	$self->simple_attribute_test('strand', $self->get_input_for('strand')->[0], $self->get_output_for('strand')->[0]);
	$self->simple_attribute_test('strand', $self->get_input_for('strand')->[1], $self->get_output_for('strand')->[1]);
	$self->simple_attribute_test('strand', $self->get_input_for('strand')->[2], $self->get_output_for('strand')->[2]);
	$self->simple_attribute_test('strand', $self->get_input_for('strand')->[3], $self->get_output_for('strand')->[3]);
}
sub chr : Test(12) {
	my ($self) = @_;
	$self->simple_attribute_test('chr', $self->get_input_for('chr')->[0], $self->get_output_for('chr')->[0]);
	$self->simple_attribute_test('chr', $self->get_input_for('chr')->[1], $self->get_output_for('chr')->[1]);
	$self->simple_attribute_test('chr', $self->get_input_for('chr')->[2], $self->get_output_for('chr')->[2]);
}
sub start : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('start', $self->get_input_for('start')->[0], $self->get_output_for('start')->[0]);
}
sub stop : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('stop', $self->get_input_for('stop')->[0], $self->get_output_for('stop')->[0]);
}
sub sequence : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('sequence', $self->get_input_for('sequence')->[0], $self->get_output_for('sequence')->[0]);
}
sub name : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('name', $self->get_input_for('name')->[0], $self->get_output_for('name')->[0]);
}
sub extra : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('extra', $self->get_input_for('extra')->[0], $self->get_output_for('extra')->[0]);
}

#######################################################################
###########################   Other Tests   ###########################
#######################################################################

sub strand_symbol : Test(4) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'strand_symbol';
	
	$obj->set_strand($self->get_input_for('strand_symbol')->[0]); 
	is $obj->strand_symbol, $self->get_output_for('strand_symbol')->[0], "... and should return the correct value";
	
	$obj->set_strand($self->get_input_for('strand_symbol')->[1]); 
	is $obj->strand_symbol, $self->get_output_for('strand_symbol')->[1], "... and should return the correct value again";
	
	$obj->set_strand($self->get_input_for('strand_symbol')->[2]); 
	is $obj->strand_symbol, $self->get_output_for('strand_symbol')->[2], "... and again";
	
}

sub get_5p : Test(4) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'get_5p';
	
	$obj = $self->class->new($self->get_input_for('get_5p')->[0]); 
	is $obj->get_5p, $self->get_output_for('get_5p')->[0], "... and should return the correct value";
	
	$obj = $self->class->new($self->get_input_for('get_5p')->[1]); 
	is $obj->get_5p, $self->get_output_for('get_5p')->[1], "... and should return the correct value again";
	
	$obj->set_strand($self->get_input_for('get_5p')->[2]); 
	is $obj->get_5p, $self->get_output_for('get_5p')->[2], "... and again";
}

sub get_3p : Test(4) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'get_3p';
	
	$obj = $self->class->new($self->get_input_for('get_3p')->[0]); 
	is $obj->get_3p, $self->get_output_for('get_3p')->[0], "... and should return the correct value";
	
	$obj = $self->class->new($self->get_input_for('get_3p')->[1]); 
	is $obj->get_3p, $self->get_output_for('get_3p')->[1], "... and should return the correct value again";
	
	$obj->set_strand($self->get_input_for('get_3p')->[2]); 
	is $obj->get_3p, $self->get_output_for('get_3p')->[2], "... and again";
}

sub id : Test(2) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'id';
	
	$obj = $self->class->new($self->get_input_for('id')->[0]); 
	is $obj->id, $self->get_output_for('id')->[0], "... and should return the correct value";
}

sub location : Test(2) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'location';
	
	$obj = $self->class->new($self->get_input_for('location')->[0]); 
	is $obj->location, $self->get_output_for('location')->[0], "... and should return the correct value";
}

sub to_string : Test(3) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'to_string';
	
	$obj = $self->class->new($self->get_input_for('to_string')->[0]);
	is $obj->to_string({'METHOD'=>'BED'}), $self->get_output_for('to_string')->[0], "... and should return the correct value";
	
	eval {$obj->to_string()};
	ok($@, "... and should die");
	
	
}
sub to_string_bed : Test(3) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'to_string_bed';
	
	$obj = $self->class->new($self->get_input_for('to_string_bed')->[0]);
	is $obj->to_string_bed(), $self->get_output_for('to_string_bed')->[0], "... and should return the correct value";
	
	$obj = $self->class->new($self->get_input_for('to_string_bed')->[1]);
	is $obj->to_string_bed(), $self->get_output_for('to_string_bed')->[1], "... and should return the correct value";
	
}
sub get_5p_5p_distance_from : Test(5) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'get_5p_5p_distance_from';
	
	$obj = $self->class->new($self->get_input_for('get_5p_5p_distance_from')->[0]);
	my $obj2 = $self->class->new($self->get_input_for('get_5p_5p_distance_from')->[0]);
	$obj2->set_start($obj->start+100);
	is $obj->get_5p_5p_distance_from($obj2), $self->get_output_for('get_5p_5p_distance_from')->[0], "... and should return the correct value";

	$obj2->set_start($obj->start-100);
	is $obj->get_5p_5p_distance_from($obj2), $self->get_output_for('get_5p_5p_distance_from')->[1], "... and should return the correct value";

	$obj2->set_stop($obj->start+100);
	$obj2->set_strand(-1);
	is $obj->get_5p_5p_distance_from($obj2), $self->get_output_for('get_5p_5p_distance_from')->[2], "... and should return the correct value";

	$obj2->set_stop($obj->start-100);
	$obj2->set_strand(-1);
	is $obj->get_5p_5p_distance_from($obj2), $self->get_output_for('get_5p_5p_distance_from')->[3], "... and should return the correct value";
}

sub get_5p_3p_distance_from : Test(5) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'get_5p_3p_distance_from';
	
	$obj = $self->class->new($self->get_input_for('get_5p_3p_distance_from')->[0]);
	my $obj2 = $self->class->new($self->get_input_for('get_5p_3p_distance_from')->[0]);
	$obj2->set_stop($obj->start+100);
	is $obj->get_5p_3p_distance_from($obj2), $self->get_output_for('get_5p_3p_distance_from')->[0], "... and should return the correct value";
	
	$obj2->set_stop($obj->start-100);
	is $obj->get_5p_3p_distance_from($obj2), $self->get_output_for('get_5p_3p_distance_from')->[1], "... and should return the correct value";
	
	$obj2->set_start($obj->start+100);
	$obj2->set_strand(-1);
	is $obj->get_5p_3p_distance_from($obj2), $self->get_output_for('get_5p_3p_distance_from')->[2], "... and should return the correct value";
	
	$obj2->set_start($obj->start-100);
	$obj2->set_strand(-1);
	is $obj->get_5p_3p_distance_from($obj2), $self->get_output_for('get_5p_3p_distance_from')->[3], "... and should return the correct value";
}

sub get_3p_5p_distance_from : Test(5) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'get_3p_5p_distance_from';
	
	$obj = $self->class->new($self->get_input_for('get_3p_5p_distance_from')->[0]);
	my $obj2 = $self->class->new($self->get_input_for('get_3p_5p_distance_from')->[0]);
	$obj2->set_start($obj->stop+100);
	is $obj->get_3p_5p_distance_from($obj2), $self->get_output_for('get_3p_5p_distance_from')->[0], "... and should return the correct value";
	
	$obj2->set_start($obj->stop-100);
	is $obj->get_3p_5p_distance_from($obj2), $self->get_output_for('get_3p_5p_distance_from')->[1], "... and should return the correct value";
	
	$obj2->set_stop($obj->stop+100);
	$obj2->set_strand(-1);
	is $obj->get_3p_5p_distance_from($obj2), $self->get_output_for('get_3p_5p_distance_from')->[2], "... and should return the correct value";
	
	$obj2->set_stop($obj->stop-100);
	$obj2->set_strand(-1);
	is $obj->get_3p_5p_distance_from($obj2), $self->get_output_for('get_3p_5p_distance_from')->[3], "... and should return the correct value";
}

sub get_3p_3p_distance_from : Test(5) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'get_3p_3p_distance_from';
	
	$obj = $self->class->new($self->get_input_for('get_3p_3p_distance_from')->[0]);
	my $obj2 = $self->class->new($self->get_input_for('get_3p_3p_distance_from')->[0]);
	$obj2->set_stop($obj->stop+100);
	is $obj->get_3p_3p_distance_from($obj2), $self->get_output_for('get_3p_3p_distance_from')->[0], "... and should return the correct value";
	
	$obj2->set_stop($obj->stop-100);
	is $obj->get_3p_3p_distance_from($obj2), $self->get_output_for('get_3p_3p_distance_from')->[1], "... and should return the correct value";
	
	$obj2->set_start($obj->stop+100);
	$obj2->set_strand(-1);
	is $obj->get_3p_3p_distance_from($obj2), $self->get_output_for('get_3p_3p_distance_from')->[2], "... and should return the correct value";
	
	$obj2->set_start($obj->stop-100);
	$obj2->set_strand(-1);
	is $obj->get_3p_3p_distance_from($obj2), $self->get_output_for('get_3p_3p_distance_from')->[3], "... and should return the correct value";
}

sub overlaps : Test(6) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'overlaps';
	
	$obj = $self->class->new($self->get_input_for('overlaps')->[0]);
	my $obj2 = $self->class->new($self->get_input_for('overlaps')->[0]);

	$obj2->set_start($obj->stop+100);
	$obj2->set_stop($obj2->start+100);
	$obj2->set_strand($obj->strand * -1); #opposite strand
	
	my $params = ({OFFSET => 0, USE_STRAND => 1}); #no overlap
	is $obj->overlaps($obj2,$params), $self->get_output_for('overlaps')->[0], "... and should return the correct value";
	$params = ({OFFSET => 150, USE_STRAND => 0}); #overlaps
	is $obj->overlaps($obj2,$params), $self->get_output_for('overlaps')->[1],"... and should return the correct value again";
	$params = ({OFFSET => 0, USE_STRAND => 0}); #no overlap
	is $obj->overlaps($obj2,$params), $self->get_output_for('overlaps')->[2], "... and should return the correct value again";
	
	$obj2->set_start($obj->start-100);
	$obj2->set_stop($obj->start+100);
	$obj2->set_strand($obj->strand); #same strand
	$params = ({OFFSET => 0, USE_STRAND => 1}); #overlaps
	is $obj->overlaps($obj2), $self->get_output_for('overlaps')->[3], "... and should return the correct value again";
	
	eval {$obj->overlaps($obj2,'anything')};
	ok($@, "... and should die");
}
sub get_overlap_length : Test(3) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'get_overlap_length';
	
	$obj = $self->class->new($self->get_input_for('get_overlap_length')->[0]);
	my $obj2 = $self->class->new($self->get_input_for('get_overlap_length')->[0]);

	$obj2->set_start($obj->start-10);
	$obj2->set_stop($obj->start-10);
	is $obj->get_overlap_length($obj2), $self->get_output_for('get_overlap_length')->[0], "... and should return the correct value";
	
	$obj2->set_start($obj->start-10);
	$obj2->set_stop($obj->start+10);
	is $obj->get_overlap_length($obj2), $self->get_output_for('get_overlap_length')->[1], "... and should return the correct value again";
}
sub contains : Test(3) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'contains';
	
	$obj = $self->class->new($self->get_input_for('contains')->[0]);
	my $obj2 = $self->class->new($self->get_input_for('contains')->[0]);

	$obj2->set_start($obj->start-10);
	$obj2->set_stop($obj->start-10);
	is $obj->contains($obj2), $self->get_output_for('contains')->[0], "... and should return the correct value";
	
	$obj2->set_start($obj->start+1);
	$obj2->set_stop($obj->stop-1);
	is $obj->contains($obj2), $self->get_output_for('contains')->[1], "... and should return the correct value again";
}
sub contains_position : Test(3) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'contains_position';
	
	$obj = $self->class->new($self->get_input_for('contains_position')->[0]);
	my $position = $obj->start - 1;
	is $obj->contains_position($position), $self->get_output_for('contains_position')->[0], "... and should return the correct value";
	
	$position = $obj->start + 1;
	is $obj->contains_position($position), $self->get_output_for('contains_position')->[1], "... and should return the correct value again";	
}
sub get_contained_locuses : Test(3) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'get_contained_locuses';
	
	$obj = $self->class->new($self->get_input_for('get_contained_locuses')->[0]);
	my @objarray;
	for (my $i = -10; $i < 10; $i++)
	{
		my $obj2 = $self->class->new($self->get_input_for('get_contained_locuses')->[0]);
		$obj2->set_start($obj->start - 10);
		$obj2->set_stop($obj->start + $i - 1);
		push (@objarray, $obj2)
	}

	my $returned_array = $obj->get_contained_locuses(\@objarray);
	
	is UNIVERSAL::isa( $returned_array, $self->get_output_for('get_contained_locuses')->[0] ), 1, "... and should be an array";
	is @{$returned_array}, $self->get_output_for('get_contained_locuses')->[1] , "... and should have the right length";
}
sub get_touching_locuses : Test(3) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'get_touching_locuses';
	
	$obj = $self->class->new($self->get_input_for('get_touching_locuses')->[0]);
	my @objarray;
	for (my $i = -10; $i < 10; $i++)
	{
		my $obj2 = $self->class->new($self->get_input_for('get_touching_locuses')->[0]);
		$obj2->set_start($obj->start - 10);
		$obj2->set_stop($obj->start + $i - 1);
		push (@objarray, $obj2)
	}

	my $returned_array = $obj->get_touching_locuses(\@objarray);
	
	is UNIVERSAL::isa( $returned_array, $self->get_output_for('get_touching_locuses')->[0] ), 1, "... and should be an array";
	is @{$returned_array}, $self->get_output_for('get_touching_locuses')->[1] , "... and should have the right length";
}

#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	
	my @test_objects;
	
	push @test_objects, $test_class->class->new({STRAND => '+', CHR => 'chr1', START => 3, STOP => 10});
	push @test_objects, $test_class->class->new({STRAND => '+', CHR => 'chr1', START => 2, STOP => 10});
	push @test_objects, $test_class->class->new({STRAND => '+', CHR => 'chr1', START => 1, STOP => 10});
	push @test_objects, $test_class->class->new({STRAND => '+', CHR => 'chr2', START => 11, STOP => 20});
	push @test_objects, $test_class->class->new({STRAND => '+', CHR => 'chr2', START => 12, STOP => 20});
	push @test_objects, $test_class->class->new({STRAND => '+', CHR => 'chr2', START => 13, STOP => 20});
	push @test_objects, $test_class->class->new({STRAND => '-', CHR => 'chr3', START => 21, STOP => 30});
	push @test_objects, $test_class->class->new({STRAND => '-', CHR => 'chr3', START => 22, STOP => 30});
	push @test_objects, $test_class->class->new({STRAND => '-', CHR => 'chr3', START => 23, STOP => 30});
	push @test_objects, $test_class->class->new({STRAND => '-', CHR => 'chr4', START => 31, STOP => 35});
	push @test_objects, $test_class->class->new({STRAND => '-', CHR => 'chr4', START => 33, STOP => 40});
	push @test_objects, $test_class->class->new({STRAND => '-', CHR => 'chr4', START => 32, STOP => 40});
	
	
	return \@test_objects;
}

1;
