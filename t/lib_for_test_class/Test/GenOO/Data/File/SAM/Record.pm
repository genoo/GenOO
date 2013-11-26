package Test::GenOO::Data::File::SAM::Record;
use strict;

use base qw(Test::GenOO);
use Test::Moose;
use Test::Most;

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
	
	can_ok $self->obj(0), 'qname';
	is $self->obj(0)->qname, 'HWI-EAS235_25:1:1:4282:1093', "... and returns the correct value";
}

sub flag : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'flag';
	is $self->obj(0)->flag, 16, "... and returns the correct value";
}

sub rname : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'rname';
	is $self->obj(0)->rname, 'chr18', "... and returns the correct value";
}

sub pos : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'pos';
	is $self->obj(0)->pos, 85867636, "... and returns the correct value";
}

sub mapq : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'mapq';
	is $self->obj(0)->mapq, 0, "... and returns the correct value";
}

sub cigar : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'cigar';
	is $self->obj(0)->cigar, '32M', "... and returns the correct value";
}

sub rnext : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'rnext';
	is $self->obj(0)->rnext, '*', "... and returns the correct value";
}

sub pnext : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'pnext';
	is $self->obj(0)->pnext, 0, "... and returns the correct value";
}

sub tlen : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'tlen';
	is $self->obj(0)->tlen, 0, "... and returns the correct value";
}

sub seq : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'seq';
	is $self->obj(0)->seq, 'ATTCGGCAGGTGAGTTGTTACACACTCCTTAG', "... and returns the correct value";
}

sub qual : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'qual';
	is $self->obj(0)->qual, 'GHHGHHHGHHGGGDGEGHHHFHGG<GG>?BGG', "... and returns the correct value";
}

sub tags : Test(1) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'tags';
}

sub alignment_length : Test(7) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'alignment_length';
	is $self->obj(0)->alignment_length, 32, "... and returns the correct value";
	is $self->obj(1)->alignment_length, 102, "... and returns the correct value";
	is $self->obj(2)->alignment_length, 102, "... and returns the correct value";
	is $self->obj(3)->alignment_length, 102, "... and returns the correct value";
	is $self->obj(6)->alignment_length, 23, "... and returns the correct value";
	is $self->obj(7)->alignment_length, 23, "... and returns the correct value";
}

sub start : Test(5) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'start';
	is $self->obj(0)->start, 85867635, "... and returns the correct value";
	is $self->obj(1)->start, 22051062, "... and returns the correct value";
	is $self->obj(2)->start, 187239349, "... and returns the correct value";
	is $self->obj(3)->start, 22985443, "... and returns the correct value";
}

sub stop : Test(7) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'stop';
	is $self->obj(0)->stop, 85867666, "... and returns the correct value";
	is $self->obj(1)->stop, 22051163, "... and returns the correct value";
	is $self->obj(2)->stop, 187239450, "... and returns the correct value";
	is $self->obj(3)->stop, 22985544, "... and returns the correct value";
	is $self->obj(6)->stop, 356788, "... and returns the correct value";
	is $self->obj(7)->stop, 356788, "... and returns the correct value";
}

sub strand : Test(6) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'strand';
	is $self->obj(0)->strand, -1, "... and returns the correct value";
	is $self->obj(1)->strand, -1, "... and returns the correct value";
	is $self->obj(2)->strand, 1, "... and returns the correct value";
	is $self->obj(3)->strand, 1, "... and returns the correct value";
	is $self->obj(4)->strand, undef, "... and returns the correct value";
}

sub strand_symbol : Test(4) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'strand_symbol';
	
	is $self->obj(0)->strand_symbol, '-', "... and returns the correct value";
	is $self->obj(2)->strand_symbol, '+', "... and returns the correct value";
	is $self->obj(4)->strand_symbol, undef, "... and returns the correct value";
}

sub query_seq : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'query_seq';
	is $self->obj(0)->query_seq, 'CTAAGGAGTGTGTAACAACTCACCTGCCGAAT', "... and returns the correct value";
}

sub query_length : Test(8) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'query_length';
	
	is $self->obj(0)->query_length, 32, "... and returns the correct value";
	is $self->obj(1)->query_length, 101, "... and returns the correct value";
	is $self->obj(2)->query_length, 101, "... and returns the correct value";
	is $self->obj(3)->query_length, 101, "... and returns the correct value";
	is $self->obj(4)->query_length, 20, "... and returns the correct value";
	is $self->obj(6)->query_length, 18, "... and returns the correct value";
	is $self->obj(7)->query_length, 18, "... and returns the correct value";
}

sub tag : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'tag';
	
	is $self->obj(0)->tag('NM:i'), 0, "... and returns the correct value";
	is $self->obj(0)->tag('MD:Z'), 32, "... and returns the correct value";
}

sub M_count : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'M_count';
	is $self->obj(7)->M_count, 15, "... and returns the correct value";
}

sub I_count : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'I_count';
	is $self->obj(7)->I_count, 3, "... and returns the correct value";
}

sub D_count : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'D_count';
	is $self->obj(7)->D_count, 4, "... and returns the correct value";
}

sub N_count : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'N_count';
	is $self->obj(7)->N_count, 4, "... and returns the correct value";
}

sub S_count : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'S_count';
	is $self->obj(7)->S_count, 0, "... and returns the correct value";
}

sub H_count : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'H_count';
	is $self->obj(7)->H_count, 0, "... and returns the correct value";
}

sub EQ_count : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'EQ_count';
	is $self->obj(6)->EQ_count, 12, "... and returns the correct value";
}

sub X_count : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'X_count';
	is $self->obj(6)->X_count, 3, "... and returns the correct value";
}

sub insertion_count : Test(7) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'insertion_count';
	
	is $self->obj(0)->insertion_count, 0, "... and returns the correct value";
	is $self->obj(1)->insertion_count, 1, "... and returns the correct value";
	is $self->obj(2)->insertion_count, 1, "... and returns the correct value";
	is $self->obj(3)->insertion_count, 0, "... and returns the correct value";
	is $self->obj(6)->insertion_count, 3, "... and returns the correct value";
	is $self->obj(7)->insertion_count, 3, "... and returns the correct value";
}

sub deletion_count : Test(7) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'deletion_count';
	
	is $self->obj(0)->deletion_count, 0, "... and returns the correct value";
	is $self->obj(1)->deletion_count, 2, "... and returns the correct value";
	is $self->obj(2)->deletion_count, 2, "... and returns the correct value";
	is $self->obj(3)->deletion_count, 1, "... and returns the correct value";
	is $self->obj(6)->deletion_count, 4, "... and returns the correct value";
	is $self->obj(7)->deletion_count, 4, "... and returns the correct value";
}

sub deletion_positions_on_query : Test(7) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'deletion_positions_on_query';
	
	is_deeply [$self->obj(0)->deletion_positions_on_query], [], "... and returns the correct value";
	is_deeply [$self->obj(1)->deletion_positions_on_query], [94], "... and returns the correct value";
	is_deeply [$self->obj(2)->deletion_positions_on_query], [35], "... and returns the correct value";
	is_deeply [$self->obj(3)->deletion_positions_on_query], [55], "... and returns the correct value";
	is_deeply [$self->obj(6)->deletion_positions_on_query], [8,16], "... and returns the correct value";
	is_deeply [$self->obj(7)->deletion_positions_on_query], [8,16], "... and returns the correct value";
}

sub insertion_positions_on_query : Test(7) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'insertion_positions_on_query';
	
	is_deeply [$self->obj(0)->insertion_positions_on_query], [], "... and returns the correct value";
	is_deeply [$self->obj(1)->insertion_positions_on_query], [98], "... and returns the correct value";
	is_deeply [$self->obj(2)->insertion_positions_on_query], [38], "... and returns the correct value";
	is_deeply [$self->obj(3)->insertion_positions_on_query], [], "... and returns the correct value";
	is_deeply [$self->obj(6)->insertion_positions_on_query], [2,10,14], "... and returns the correct value";
	is_deeply [$self->obj(7)->insertion_positions_on_query], [2,10,14], "... and returns the correct value";
}

sub mismatch_positions_on_query : Test(8) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'mismatch_positions_on_query';
	
	is_deeply [$self->obj(0)->mismatch_positions_on_query], [], "... and returns the correct value";
	is_deeply [$self->obj(1)->mismatch_positions_on_query], [100,38], "... and returns the correct value";
	is_deeply [$self->obj(2)->mismatch_positions_on_query], [12,48], "... and returns the correct value";
	is_deeply [$self->obj(3)->mismatch_positions_on_query], [73,86,98,100], "... and returns the correct value";
	is_deeply [$self->obj(5)->mismatch_positions_on_query], [73,86,98,100], "... and returns the correct value";
	is_deeply [$self->obj(6)->mismatch_positions_on_query], [4,7,13], "... and returns the correct value";
	is_deeply [$self->obj(7)->mismatch_positions_on_query], [4,7,13], "... and returns the correct value";
}

sub deletion_positions_on_reference : Test(7) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'deletion_positions_on_reference';
	
	is_deeply [$self->obj(0)->deletion_positions_on_reference], [], "... and returns the correct value";
	is_deeply [$self->obj(1)->deletion_positions_on_reference], [22051067,22051068], "... and returns the correct value";
	is_deeply [$self->obj(2)->deletion_positions_on_reference], [187239385,187239386], "... and returns the correct value";
	is_deeply [$self->obj(3)->deletion_positions_on_reference], [22985499], "... and returns the correct value";
	is_deeply [$self->obj(6)->deletion_positions_on_reference], [356778,356779,356780,356787], "... and returns the correct value";
	is_deeply [$self->obj(7)->deletion_positions_on_reference], [356778,356779,356780,356787], "... and returns the correct value";
}

sub mismatch_positions_on_reference : Test(8) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'mismatch_positions_on_reference';
	
	is_deeply [$self->obj(0)->mismatch_positions_on_reference], [], "... and returns the correct value";
	is_deeply [$self->obj(1)->mismatch_positions_on_reference], [22051062,22051125], "... and returns the correct value";
	is_deeply [$self->obj(2)->mismatch_positions_on_reference], [187239361,187239398], "... and returns the correct value";
	is_deeply [$self->obj(3)->mismatch_positions_on_reference], [22985517,22985530,22985542,22985544], "... and returns the correct value";
	is_deeply [$self->obj(5)->mismatch_positions_on_reference], [22985516,22985529,22985541,22985543], "... and returns the correct value";
	is_deeply [$self->obj(6)->mismatch_positions_on_reference], [356769,356776,356784], "... and returns the correct value";
	is_deeply [$self->obj(7)->mismatch_positions_on_reference], [356769,356776,356784], "... and returns the correct value";
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
	
	my $expected = join("\t", 'HWI-EAS235_25:1:1:4282:1093', '16', 'chr18', 
	                          '85867636', '0', '32M', '*', '0', '0',
	                          'ATTCGGCAGGTGAGTTGTTACACACTCCTTAG',
	                          'GHHGHHHGHHGGGDGEGHHHFHGG<GG>?BGG',
	                          'NM:i:0', 'MD:Z:32');
	
	is $self->obj(0)->to_string, $expected, "... and returns the correct value";
}

sub is_mapped : Test(4) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'is_mapped';
	
	is $self->obj(0)->is_mapped, 1, "... and returns the correct value";
	is $self->obj(2)->is_mapped, 1, "... and returns the correct value";
	is $self->obj(4)->is_mapped, 0, "... and again";
}

sub is_unmapped : Test(4) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'is_unmapped';
	
	is $self->obj(0)->is_unmapped, 0, "... and returns the correct value";
	is $self->obj(2)->is_unmapped, 0, "... and returns the correct value";
	is $self->obj(4)->is_unmapped, 1, "... and again";
}

sub mid_position : Test(9) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'mid_position';
	
	is $self->obj(0)->mid_position,  $self->obj(0)->region_mid_position, "... and returns the correct value";
	is $self->obj(1)->mid_position, 22051113, "... and returns the correct value";
	is $self->obj(2)->mid_position, 187239400, "... and returns the correct value";
	is $self->obj(3)->mid_position, 22985493, "... and returns the correct value";
	is $self->obj(4)->mid_position, undef, "... and returns the correct value";
	is $self->obj(5)->mid_position, 22985493, "... and returns the correct value";
	is $self->obj(6)->mid_position, 356780.5, "... and returns the correct value";
	is $self->obj(7)->mid_position, 356780.5, "... and returns the correct value";
}


#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	
	my @test_objects;
	
	push @test_objects, $test_class->class->new(fields => ['HWI-EAS235_25:1:1:4282:1093', '16', 'chr18', '85867636', '0', '32M', '*', '0', '0', 'ATTCGGCAGGTGAGTTGTTACACACTCCTTAG', 'GHHGHHHGHHGGGDGEGHHHFHGG<GG>?BGG', 'NM:i:0', 'MD:Z:32']);
	
	push @test_objects, $test_class->class->new(fields => ['HWI-EAS235_32:2:20:11311:1509', '16', 'chr11', '22051063', '37', '2M1I3M2D95M', '*', '0', '0', 'TTGGTTCTTCTGAGTCAGGATCTCCAAATGGATTTAATTCTGTTACATCAGGTTCATCAAATNGATTGGTATTCACAGTGGCCAAGTCCTTTTGTGCTTCA', 'B>D>EEBGHGEGCGGHFCGEEFB@HFFFGFDAEC?C>G@EFBDD@DHHFHHGGB<D8>@@@/#869>EGGEG@<DGBH<EHHHHHHHHHHHDEG@EGGGFG', 'NM:i:5', 'MD:Z:0A4^AC56G38']);
	
	push @test_objects, $test_class->class->new(fields => ['HWI-EAS235_32:2:20:9009:10694', '0', 'chr1', '187239350', '37', '36M2D2M1I62M', '*', '0', '0', 'AGGAGCAGGAGAAAGGGCAACAGTGGAGGAGAGCAGCCTAGGCATGAGCTCTGGGAAGTCTAGCACACAGTTACTCCTGAAAGGGGCTTCCCGGAGCAGGA', '4*24.7*0*9B;B=;9:2=0/531.+*288===>=@BB03=8*==?==/1A8@?@;8BB=8??=@1@688,7@89CCCCCCCCCAC6CC@CC@C@C<<@C9', 'NM:i:5', 'MD:Z:12G23^GT11A52']);
	
	push @test_objects, $test_class->class->new(fields => ['HWI-EAS235_32:2:19:14059:2128', '0', 'chr5', '22985444', '37', '56M1D45M', '*', '0', '0', 'CAACACGTAAAGATCTATTTCAACGCTTCTTGCTTGTTTCTATATTGCTGAATACTAAGTAAGCCACATTGAAAAAGTAAAAGCAAGATTGCTTAGCTCTC', 'DDGE<EF8BFFGDDFHBGHHHHHHHGHH@GHHGHHD2@==FEEGEDBGGGGH@GFGDD@,EE8AAAACCCAAC;CA<8AE@;+)9<3:08<===<=*A>@5', 'NM:i:5', 'MD:Z:56^A17C12A11A1A0']);
	
	push @test_objects, $test_class->class->new(fields => ['HWI-EAS235_32:1:1:7112:1235', '4', '*', '0', '0', '*', '*', '0', '0', 'TNNNNNNNNCCAAGTGAAAG', '?########20;<73@@B@@']);
	
	push @test_objects, $test_class->class->new(fields => ['HWI-EAS235_32:2:19:14059:2128', '0', 'chr5', '22985444', '37', '101M', '*', '0', '0', 'CAACACGTAAAGATCTATTTCAACGCTTCTTGCTTGTTTCTATATTGCTGAATACTAAGTAAGCCACATTGAAAAAGTAAAAGCAAGATTGCTTAGCTCTC', 'DDGE<EF8BFFGDDFHBGHHHHHHHGHH@GHHGHHD2@==FEEGEDBGGGGH@GFGDD@,EE8AAAACCCAAC;CA<8AE@;+)9<3:08<===<=*A>@5', 'NM:i:5', 'MD:Z:73C12A11A1A0']);
	
	
	# AGTGAT____GGA---GTGACTCA-C -> CIGAR: 2M1I3M4N3M3D1M1I3M1I2M1D1M  /  2=1I1=1X1=4N1=1X1=3D1=1I2=1X1I2=1D1=
    #     -      -        -
    # AG-GCTNNNNGTAGAGG-GAG-CAGC -> MD:Z:  3C1^NNNN1T1^GAG3G2^G1
	push @test_objects, $test_class->class->new(fields => ['Test6', '0', 'chr1', '356767', '37', '2=1I1=1X1=4N1=1X1=3D1=1I2=1X1I2=1D1=', '*', '0', '0', 'AGTGATGGAGTGACTCAC', 'B>D>EEBGHGEGCGGHFC', 'NM:i:5', 'MD:Z:3C1^NNNN1T1^GAG3G2^G1']);
	
	push @test_objects, $test_class->class->new(fields => ['Test7', '0', 'chr1', '356767', '37', '2M1I3M4N3M3D1M1I3M1I2M1D1M', '*', '0', '0', 'AGTGATGGAGTGACTCAC', 'B>D>EEBGHGEGCGGHFC', 'NM:i:5', 'MD:Z:3C1^NNNN1T1^GAG3G2^G1']);
	
	return \@test_objects;
}

1;
