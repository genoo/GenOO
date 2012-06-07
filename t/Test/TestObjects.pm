package Test::TestObjects;
use strict;

use MyBio::JobGraph::Input;
use MyBio::JobGraph::Output;
use MyBio::JobGraph::Description;

	################################################
	################ JobGraph ######################
	################################################
	
sub get_testobject_MyBio_JobGraph_Job_Generic
{
	return [
		{
			#this is a generic object of the class
			INPUT        => [
						MyBio::JobGraph::Input->new({Test::TestObjects->get_testobject_MyBio_JobGraph_Input->[0]}),
						MyBio::JobGraph::Input->new({Test::TestObjects->get_testobject_MyBio_JobGraph_Input->[0]})
					],
			OUTPUT        => [
						MyBio::JobGraph::Output->new({Test::TestObjects->get_testobject_MyBio_JobGraph_Output->[0]}),
						MyBio::JobGraph::Output->new({Test::TestObjects->get_testobject_MyBio_JobGraph_Output->[0]})
					],
			DESCRIPTION  => MyBio::JobGraph::Description->new({
						Test::TestObjects->get_testobject_MyBio_JobGraph_Description->[0]
					}),
			LOG          => 'anything',
			CODE         => 'return "anything";'
		},
	];
}
sub get_testobject_MyBio_JobGraph_IO
{
	return [
		{
			#this is a generic object of the class
			NAME       => 'anything',
			SOURCE     => 'anything',
			TYPE 	   => 'anything',
		},
	];
}
sub get_testobject_MyBio_JobGraph_Input
{
	return [
		{
			#this is a generic object of the class
			NAME       => 'anything',
			SOURCE     => 'anything',
			TYPE 	   => 'anything',
		},
	];
}
sub get_testobject_MyBio_JobGraph_Output {
	return [
		{
			#this is a generic object of the class
			NAME       => 'anything',
			SOURCE     => 'anything',
			TYPE 	   => 'anything',
		},
	];
}

sub get_testobject_MyBio_JobGraph_Description {
return [
		{
			#this is a generic object of the class
			HEADER     => 'anything {{var1}} anything {{var2}}',
			ABSTRACT   => 'anything',
			TEXT 	   => 'anything',
			VARIABLES  => {
					'var1' => 'value for var1',
					'var2' => 'value for var2',
				      },
		},
	];
}

	################################################
	################### Locus ######################
	################################################

sub get_testobject_MyBio_Locus
{
	return [
		{
			#this is a generic object of the class
			SPECIES      => "HUMAN",
			STRAND       => "1",
			CHR          => "chr9",
			START        => "10000",
			STOP         => "10100",
			SEQUENCE     => "CAATACATACGTGTTCCGGCTCTTATCCTGCATCGGAAGCTCAATCATGCATCGCACCAGCGTGTTCGTGTCATCTAGGAGGGGCGCGTAGGATAAATAA",
			NAME         => "test_locus_generic",
			EXTRA_INFO   => undef,
		},
		{
			#this is a generic object of the class (minus strand)
			SPECIES      => "HUMAN",
			STRAND       => "-1",
			CHR          => "chr9",
			START        => "10000",
			STOP         => "10100",
			SEQUENCE     => "CAATACATACGTGTTCCGGCTCTTATCCTGCATCGGAAGCTCAATCATGCATCGCACCAGCGTGTTCGTGTCATCTAGGAGGGGCGCGTAGGATAAATAA",
			NAME         => "test_locus_generic2",
			EXTRA_INFO   => undef,
		},
		{
			#this is a generic object of the class (missing name and strand)
			SPECIES      => "HUMAN",
			STRAND       => undef,
			CHR          => "chr9",
			START        => "10000",
			STOP         => "10100",
			SEQUENCE     => "CAATACATACGTGTTCCGGCTCTTATCCTGCATCGGAAGCTCAATCATGCATCGCACCAGCGTGTTCGTGTCATCTAGGAGGGGCGCGTAGGATAAATAA",
			NAME         => undef,
			EXTRA_INFO   => undef,
		},
	];
}

1;
