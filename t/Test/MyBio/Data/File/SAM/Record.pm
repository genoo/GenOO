package Test::MyBio::Data::File::SAM::Record;
use strict;

use Test::Moose;
use Test::Most;
use base qw(Test::MyBio);


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
sub create_new_test_objects : Test(setup) {
	my ($self) = @_;
	
	my $test_class = ref($self) || $self;
	$self->{TEST_OBJECTS} = $test_class->test_objects();
};


#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	isa_ok $self->obj(0), $self->class, "... and the object";
}

sub qname : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'qname', "... test object has the 'qname' attribute");
	is $self->obj(0)->qname, 'HWI-EAS235_25:1:1:4282:1093', "... and returns the correct value";
}

sub flag : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'flag', "... test object has the 'flag' attribute");
	is $self->obj(0)->flag, 16, "... and returns the correct value";
}

sub rname : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'rname', "... test object has the 'rname' attribute");
	is $self->obj(0)->rname, 'chr18', "... and returns the correct value";
}

sub pos : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'pos', "... test object has the 'pos' attribute");
	is $self->obj(0)->pos, 85867636, "... and returns the correct value";
}

sub mapq : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'mapq', "... test object has the 'mapq' attribute");
	is $self->obj(0)->mapq, 0, "... and returns the correct value";
}

sub cigar : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'cigar', "... test object has the 'cigar' attribute");
	is $self->obj(0)->cigar, '32M', "... and returns the correct value";
}

sub rnext : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'rnext', "... test object has the 'rnext' attribute");
	is $self->obj(0)->rnext, '*', "... and returns the correct value";
}

sub pnext : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'pnext', "... test object has the 'pnext' attribute");
	is $self->obj(0)->pnext, 0, "... and returns the correct value";
}

sub tlen : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'tlen', "... test object has the 'tlen' attribute");
	is $self->obj(0)->tlen, 0, "... and returns the correct value";
}

sub seq : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'seq', "... test object has the 'seq' attribute");
	is $self->obj(0)->seq, 'ATTCGGCAGGTGAGTTGTTACACACTCCTTAG', "... and returns the correct value";
}

sub qual : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'qual', "... test object has the 'qual' attribute");
	is $self->obj(0)->qual, 'GHHGHHHGHHGGGDGEGHHHFHGG<GG>?BGG', "... and returns the correct value";
}

sub tags : Test(11) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'tags', "... test object has the 'tags' attribute");
	is $self->obj(0)->tag('XT:A'), 'R', "... and returns the correct value";
	is $self->obj(0)->tag('NM:i'), 0, "... and returns the correct value";
	is $self->obj(0)->tag('X0:i'), 2, "... and returns the correct value";
	is $self->obj(0)->tag('X1:i'), 0, "... and returns the correct value";
	is $self->obj(0)->tag('XM:i'), 0, "... and returns the correct value";
	is $self->obj(0)->tag('XO:i'), 0, "... and returns the correct value";
	is $self->obj(0)->tag('XG:i'), 0, "... and returns the correct value";
	is $self->obj(0)->tag('MD:Z'), 32, "... and returns the correct value";
	is $self->obj(0)->tag('XA:Z'), 'chr9,+110183777,32M,0;chr8,+110183756,30M1I,0;',  "... and returns the correct value";
	
	is $self->obj(3)->tag('XT:A'), 'U',  "... and returns the correct value";
}

sub alignment_length : Test(5) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'alignment_length', "... test object has the 'alignment_length' attribute");
	is $self->obj(0)->alignment_length, 32, "... and returns the correct value";
	is $self->obj(1)->alignment_length, 102, "... and returns the correct value";
	is $self->obj(2)->alignment_length, 102, "... and returns the correct value";
	is $self->obj(3)->alignment_length, 102, "... and returns the correct value";
}

sub start : Test(5) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'start', "... test object has the 'start' attribute");
	is $self->obj(0)->start, 85867635, "... and returns the correct value";
	is $self->obj(1)->start, 22051062, "... and returns the correct value";
	is $self->obj(2)->start, 187239349, "... and returns the correct value";
	is $self->obj(3)->start, 22985443, "... and returns the correct value";
}

sub stop : Test(5) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'stop', "... test object has the 'stop' attribute");	
	is $self->obj(0)->stop, 85867666, "... and returns the correct value";
	is $self->obj(1)->stop, 22051163, "... and returns the correct value";
	is $self->obj(2)->stop, 187239450, "... and returns the correct value";
	is $self->obj(3)->stop, 22985544, "... and returns the correct value";
}

sub strand : Test(6) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'strand', "... test object has the 'strand' attribute");	
	is $self->obj(0)->strand, -1, "... and returns the correct value";
	is $self->obj(1)->strand, -1, "... and returns the correct value";
	is $self->obj(2)->strand, 1, "... and returns the correct value";
	is $self->obj(3)->strand, 1, "... and returns the correct value";
	is $self->obj(4)->strand, undef, "... and returns the correct value";
}

sub strand_symbol : Test(6) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'strand_symbol';
	
	is $self->obj(0)->strand_symbol, '-', "... and returns the correct value";
	is $self->obj(1)->strand_symbol, '-', "... and returns the correct value";
	is $self->obj(2)->strand_symbol, '+', "... and returns the correct value";
	is $self->obj(3)->strand_symbol, '+', "... and returns the correct value";
	is $self->obj(4)->strand_symbol, undef, "... and returns the correct value";
}

sub query_seq : Test(6) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'query_seq';
	
	is $self->obj(0)->query_seq, 'CTAAGGAGTGTGTAACAACTCACCTGCCGAAT', "... and returns the correct value";
	is $self->obj(1)->query_seq, 'TGAAGCACAAAAGGACTTGGCCACTGTGAATACCAATCNATTTGATGAACCTGATGTAACAGAATTAAATCCATTTGGAGATCCTGACTCAGAAGAACCAA', "... and returns the correct value";
	is $self->obj(2)->query_seq, 'AGGAGCAGGAGAAAGGGCAACAGTGGAGGAGAGCAGCCTAGGCATGAGCTCTGGGAAGTCTAGCACACAGTTACTCCTGAAAGGGGCTTCCCGGAGCAGGA', "... and returns the correct value";
	is $self->obj(3)->query_seq, 'CAACACGTAAAGATCTATTTCAACGCTTCTTGCTTGTTTCTATATTGCTGAATACTAAGTAAGCCACATTGAAAAAGTAAAAGCAAGATTGCTTAGCTCTC', "... and returns the correct value";
	is $self->obj(4)->query_seq, 'TNNNNNNNNCCAAGTGAAAG', "... and returns the correct value";
}

sub query_length : Test(6) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'query_length';
	
	is $self->obj(0)->query_length, 32, "... and returns the correct value";
	is $self->obj(1)->query_length, 101, "... and returns the correct value";
	is $self->obj(2)->query_length, 101, "... and returns the correct value";
	is $self->obj(3)->query_length, 101, "... and returns the correct value";
	is $self->obj(4)->query_length, 20, "... and returns the correct value";
}

sub tag : Test(4) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'tag';
	
	is $self->obj(0)->tag('XT:A'), 'R', "... and returns the correct value";
	is $self->obj(0)->tag('NM:i'), 0, "... and returns the correct value";
	is $self->obj(3)->tag('XT:A'), 'U',  "... and returns the correct value";
}

sub number_of_best_hits : Test(6) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'number_of_best_hits';
	
	is $self->obj(0)->number_of_best_hits, 2, "... and returns the correct value";
	is $self->obj(1)->number_of_best_hits, 1, "... and returns the correct value";
	is $self->obj(2)->number_of_best_hits, 1, "... and returns the correct value";
	is $self->obj(3)->number_of_best_hits, 1, "... and returns the correct value";
	is $self->obj(4)->number_of_best_hits, undef, "... and returns the correct value";
}

sub number_of_suboptimal_hits : Test(6) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'number_of_suboptimal_hits';
	
	is $self->obj(0)->number_of_suboptimal_hits, 0, "... and returns the correct value";
	is $self->obj(1)->number_of_suboptimal_hits, 0, "... and returns the correct value";
	is $self->obj(2)->number_of_suboptimal_hits, 0, "... and returns the correct value";
	is $self->obj(3)->number_of_suboptimal_hits, 0, "... and returns the correct value";
	is $self->obj(4)->number_of_suboptimal_hits, undef, "... and returns the correct value";
}

sub alternative_mappings : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'alternative_mappings';
	
	my @values = $self->obj(0)->alternative_mappings;
	is $values[0], 'chr9,+110183777,32M,0', "... and should return the correct value";
	is $values[1], 'chr8,+110183756,30M1I,0', "... and again";
}

sub insertion_count : Test(6) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'insertion_count';
	
	is $self->obj(0)->insertion_count, 0, "... and returns the correct value";
	is $self->obj(1)->insertion_count, 1, "... and returns the correct value";
	is $self->obj(2)->insertion_count, 1, "... and returns the correct value";
	is $self->obj(3)->insertion_count, 0, "... and returns the correct value";
	
	$self->obj(0)->cigar('14M1I5M2I5M');
	is $self->obj(0)->insertion_count, 3, "... and should return the correct value again";
}

sub deletion_count : Test(6) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'deletion_count';
	
	is $self->obj(0)->deletion_count, 0, "... and returns the correct value";
	is $self->obj(1)->deletion_count, 2, "... and returns the correct value";
	is $self->obj(2)->deletion_count, 2, "... and returns the correct value";
	is $self->obj(3)->deletion_count, 1, "... and returns the correct value";
	
	$self->obj(0)->cigar('14M1D5M2D5M');
	is $self->obj(0)->deletion_count, 3, "... and should return the correct value again";
}

sub deletion_positions_on_query : Test(5) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'deletion_positions_on_query';
	
	is_deeply [$self->obj(0)->deletion_positions_on_query], [], "... and returns the correct value";
	is_deeply [$self->obj(1)->deletion_positions_on_query], [95], "... and returns the correct value";
	is_deeply [$self->obj(2)->deletion_positions_on_query], [36], "... and returns the correct value";
	is_deeply [$self->obj(3)->deletion_positions_on_query], [56], "... and returns the correct value";
}

sub deletion_positions_on_reference : Test(5) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'deletion_positions_on_reference';
	
	is_deeply [$self->obj(0)->deletion_positions_on_reference], [], "... and returns the correct value";
	is_deeply [$self->obj(1)->deletion_positions_on_reference], [22051067,22051068], "... and returns the correct value";
	is_deeply [$self->obj(2)->deletion_positions_on_reference], [187239385,187239386], "... and returns the correct value";
	is_deeply [$self->obj(3)->deletion_positions_on_reference], [22985499], "... and returns the correct value";
}

sub mismatch_positions_on_reference : Test(5) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'mismatch_positions_on_reference';
	
	is_deeply [$self->obj(0)->mismatch_positions_on_reference], [], "... and returns the correct value";
	is_deeply [$self->obj(1)->mismatch_positions_on_reference], [22051062,22051125], "... and returns the correct value";
	is_deeply [$self->obj(2)->mismatch_positions_on_reference], [187239361,187239398], "... and returns the correct value";
	is_deeply [$self->obj(3)->mismatch_positions_on_reference], [22985517,22985530,22985542,22985544], "... and returns the correct value";
}

sub mismatch_positions_on_query : Test(5) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'mismatch_positions_on_query';
	
	is_deeply [$self->obj(0)->mismatch_positions_on_query], [], "... and returns the correct value";
	is_deeply [$self->obj(1)->mismatch_positions_on_query], [100,38], "... and returns the correct value";
	is_deeply [$self->obj(2)->mismatch_positions_on_query], [12,48], "... and returns the correct value";
	is_deeply [$self->obj(3)->mismatch_positions_on_query], [73,86,98,100], "... and returns the correct value";
}

sub cigar_relative_to_query : Test(6) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'cigar_relative_to_query';
	
	is $self->obj(0)->cigar_relative_to_query, '32M', "... and returns the correct value";
	is $self->obj(1)->cigar_relative_to_query, '95M2D3M1I2M', "... and returns the correct value";
	is $self->obj(2)->cigar_relative_to_query, '36M2D2M1I62M', "... and returns the correct value";
	is $self->obj(3)->cigar_relative_to_query, '56M1D45M', "... and returns the correct value";
	is $self->obj(4)->cigar_relative_to_query, '*', "... and again";
}

sub to_string : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'to_string';
	
	my $expected = join("\t",
		'HWI-EAS235_25:1:1:4282:1093',
		'16',
		'chr18',
		'85867636',
		'0',
		'32M',
		'*',
		'0',
		'0',
		'ATTCGGCAGGTGAGTTGTTACACACTCCTTAG',
		'GHHGHHHGHHGGGDGEGHHHFHGG<GG>?BGG',
		'XG:i:0', 'MD:Z:32', 'X1:i:0', 'XM:i:0', 'XO:i:0', 'X0:i:2', 'XT:A:R',
		'XA:Z:chr9,+110183777,32M,0;chr8,+110183756,30M1I,0;', 'NM:i:0'
	);
	is $self->obj(0)->to_string, $expected, "... and returns the correct value";
}

sub is_mapped : Test(6) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'is_mapped';
	
	is $self->obj(0)->is_mapped, 1, "... and returns the correct value";
	is $self->obj(1)->is_mapped, 1, "... and returns the correct value";
	is $self->obj(2)->is_mapped, 1, "... and returns the correct value";
	is $self->obj(3)->is_mapped, 1, "... and returns the correct value";
	is $self->obj(4)->is_mapped, 0, "... and again";
}

sub is_unmapped : Test(6) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'is_unmapped';
	
	is $self->obj(0)->is_unmapped, 0, "... and returns the correct value";
	is $self->obj(1)->is_unmapped, 0, "... and returns the correct value";
	is $self->obj(2)->is_unmapped, 0, "... and returns the correct value";
	is $self->obj(3)->is_unmapped, 0, "... and returns the correct value";
	is $self->obj(4)->is_unmapped, 1, "... and again";
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self, $index) = @_;
	
	return $self->{TEST_OBJECTS}->[$index];
}

sub objs {
	my ($self) = @_;
	
	return @{$self->{TEST_OBJECTS}};
}

#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	
	my @test_objects;
	
	push @test_objects, $test_class->class->new({
		qname      => 'HWI-EAS235_25:1:1:4282:1093',
		flag       => '16',
		rname      => 'chr18',
		pos        => '85867636',
		mapq       => '0',
		cigar      => '32M',
		rnext      => '*',
		pnext      => '0',
		tlen       => '0',
		seq        => 'ATTCGGCAGGTGAGTTGTTACACACTCCTTAG',
		qual       => 'GHHGHHHGHHGGGDGEGHHHFHGG<GG>?BGG',
		tags       => ['XT:A:R','NM:i:0','X0:i:2','X1:i:0','XM:i:0','XO:i:0','XG:i:0','MD:Z:32','XA:Z:chr9,+110183777,32M,0;chr8,+110183756,30M1I,0;'],
	});
	
	push @test_objects, $test_class->class->new({
		qname      => 'HWI-EAS235_32:2:20:11311:1509',
		flag       => '16',
		rname      => 'chr11',
		pos        => '22051063',
		mapq       => '37',
		cigar      => '2M1I3M2D95M',
		rnext      => '*',
		pnext      => '0',
		tlen       => '0',
		seq        => 'TTGGTTCTTCTGAGTCAGGATCTCCAAATGGATTTAATTCTGTTACATCAGGTTCATCAAATNGATTGGTATTCACAGTGGCCAAGTCCTTTTGTGCTTCA',
		qual       => 'B>D>EEBGHGEGCGGHFCGEEFB@HFFFGFDAEC?C>G@EFBDD@DHHFHHGGB<D8>@@@/#869>EGGEG@<DGBH<EHHHHHHHHHHHDEG@EGGGFG',
		tags       => ['XT:A:U', 'NM:i:5', 'X0:i:1', 'X1:i:0', 'XM:i:4', 'XO:i:1', 'XG:i:1', 'MD:Z:0A4^AC56G38'],
	});
	
	push @test_objects, $test_class->class->new({
		qname      => 'HWI-EAS235_32:2:20:9009:10694',
		flag       => '0',
		rname      => 'chr1',
		pos        => '187239350',
		mapq       => '37',
		cigar      => '36M2D2M1I62M',
		rnext      => '*',
		pnext      => '0',
		tlen       => '0',
		seq        => 'AGGAGCAGGAGAAAGGGCAACAGTGGAGGAGAGCAGCCTAGGCATGAGCTCTGGGAAGTCTAGCACACAGTTACTCCTGAAAGGGGCTTCCCGGAGCAGGA',
		qual       => '4*24.7*0*9B;B=;9:2=0/531.+*288===>=@BB03=8*==?==/1A8@?@;8BB=8??=@1@688,7@89CCCCCCCCCAC6CC@CC@C@C<<@C9',
		tags       => ['XT:A:U', 'NM:i:5', 'X0:i:1', 'X1:i:0', 'XM:i:4', 'XO:i:1', 'XG:i:1', 'MD:Z:12G23^GT11A52'],
	});
	
	push @test_objects, $test_class->class->new({
		qname      => 'HWI-EAS235_32:2:19:14059:2128',
		flag       => '0',
		rname      => 'chr5',
		pos        => '22985444',
		mapq       => '37',
		cigar      => '56M1D45M',
		rnext      => '*',
		pnext      => '0',
		tlen       => '0',
		seq        => 'CAACACGTAAAGATCTATTTCAACGCTTCTTGCTTGTTTCTATATTGCTGAATACTAAGTAAGCCACATTGAAAAAGTAAAAGCAAGATTGCTTAGCTCTC',
		qual       => 'DDGE<EF8BFFGDDFHBGHHHHHHHGHH@GHHGHHD2@==FEEGEDBGGGGH@GFGDD@,EE8AAAACCCAAC;CA<8AE@;+)9<3:08<===<=*A>@5',
		tags       => {
			'XT:A' => 'U',
			'NM:i' => '5',
			'X0:i' => '1',
			'X1:i' => '0',
			'XM:i' => '4',
			'XO:i' => '1',
			'XG:i' => '1',
			'MD:Z' => '56^A17C12A11A1A0'
		},
	});
	
	push @test_objects, $test_class->class->new({
		qname      => 'HWI-EAS235_32:1:1:7112:1235',
		flag       => '4',
		rname      => '*',
		pos        => '0',
		mapq       => '0',
		cigar      => '*',
		rnext      => '*',
		pnext      => '0',
		tlen       => '0',
		seq        => 'TNNNNNNNNCCAAGTGAAAG',
		qual       => '?########20;<73@@B@@',
		tags       => [],
	});
	
	return \@test_objects;
}

1;
