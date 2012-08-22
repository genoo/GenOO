package Test::TestObjects;
use strict;

use MyBio::JobGraph::Job::Input;
use MyBio::JobGraph::Job::Output;
use MyBio::JobGraph::Job::Description;

################################################
################ JobGraph ######################
################################################
sub get_testobject_MyBio_JobGraph_Job_Generic {
	return [
		{
			INPUT => [
				MyBio::JobGraph::Job::Input->new({Test::TestObjects->get_testobject_MyBio_JobGraph_Input->[0]}),
				MyBio::JobGraph::Job::Input->new({Test::TestObjects->get_testobject_MyBio_JobGraph_Input->[0]})
			],
			
			OUTPUT => [
				MyBio::JobGraph::Job::Output->new({Test::TestObjects->get_testobject_MyBio_JobGraph_Output->[0]}),
				MyBio::JobGraph::Job::Output->new({Test::TestObjects->get_testobject_MyBio_JobGraph_Output->[0]})
			],
			
			DESCRIPTION => MyBio::JobGraph::Job::Description->new({
				Test::TestObjects->get_testobject_MyBio_JobGraph_Description->[0]
			}),
			
			LOG => 'anything',
			
			CODE => sub {
				return 'anything';
			}
		},
	];
}

sub get_testobject_MyBio_JobGraph_IO {
	return [
		{
			NAME         => 'anything',
			SOURCE       => 'anything',
		},
	];
}

sub get_testobject_MyBio_JobGraph_Input {
	return [
		{
			NAME         => 'anything',
			SOURCE       => 'anything',
		},
	];
}

sub get_testobject_MyBio_JobGraph_Output {
	return [
		{
			NAME         => 'anything',
			SOURCE       => 'anything',
		},
	];
}

sub get_testobject_MyBio_JobGraph_Description {
	return [
		{
			HEADER     => 'anything {{var1}} anything {{var2}}',
			ABSTRACT   => 'anything',
			TEXT       => 'anything',
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
sub get_testobject_MyBio_Locus {
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

################################################
############## MyBio::NGS::Tag #################
################################################
sub get_testobject_MyBio_NGS_Tag {
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
			SCORE        => 0.1,
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
			SCORE        => 1,
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
			SCORE        => 0,
			EXTRA_INFO   => undef,
		},
	];
}

1;
