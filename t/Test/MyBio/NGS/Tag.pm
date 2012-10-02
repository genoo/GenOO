package Test::MyBio::NGS::Tag;
use strict;

use base qw(Test::MyBio::Locus);
use Test::More;
use Test::TestObjects;

#######################################################################
###########################   Test Data     ###########################
#######################################################################

sub sample_object {
	return Test::TestObjects->get_testobject_MyBio_NGS_Tag;
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
		score => {
			INPUT  => [0.2],
			OUTPUT => [0.2]
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
			OUTPUT => ["chr9\t10000\t10101\ttest_locus_generic\t0.1\t+"]
		},
		to_string_bed => {
			INPUT  => [sample_object->[0],sample_object->[2]],
			OUTPUT => ["chr9\t10000\t10101\ttest_locus_generic\t0.1\t+", "chr9\t10000\t10101\t.\t0\t."]
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
#########################   Attributes Tests   ########################
#######################################################################
sub score : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('score', $self->get_input_for('score')->[0], $self->get_output_for('score')->[0]);
}

1;
