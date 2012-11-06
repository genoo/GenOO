package Test::TestObjects;
use strict;

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
