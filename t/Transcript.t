use Test::More 'no_plan';

BEGIN {
	use_ok('MyBio::Transcript'); 
}
require_ok('MyBio::Transcript');

my $transcript = MyBio::Transcript->new({
	ENSTID         => 'enstid',
	SPECIES        => 'human',
	STRAND         => '+',
	CHR            => 'chr1',
	START          => 1500,
	STOP           => 2500,
	GENE           => undef,
	UTR5           => undef,
	CDS            => undef,
	UTR3           => undef,
	CDNA           => undef,
	BIOTYPE        => 'protein_coding',
	INTERNAL_ID    => undef,
	INTERNAL_GID   => undef,
	EXTRA_INFO     => undef,
});


isa_ok($transcript, 'MyBio::SplicedLocus');
isa_ok($transcript, 'MyBio::Locus');

is ($transcript->get_species, 'HUMAN', 'Is species correct');
is ($transcript->get_strand, 1, 'Is strand correct');
is ($transcript->get_chr, 'chr1', 'Is chromosome correct');
is ($transcript->get_start, 1500, 'Is start correct');
is ($transcript->get_stop, 2500, 'Is stop correct');

# TODO: {
# 	local $TODO = "Need's to be done because ..." if (1);
# 	is( 42, 23, $test_name );
# };



# 
# # Various ways to say "ok"
# ok($got eq $expected, $test_name);
# 
# is  ($got, $expected, $test_name);
# isnt($got, $expected, $test_name);
# 
# # Rather than print STDERR "# here's what went wrong\n"
# 
# 
# like  ($got, qr/expected/, $test_name);
# unlike($got, qr/expected/, $test_name);
# 
# cmp_ok($got, '==', $expected, $test_name);
# 
# is_deeply($got_complex_structure, $expected_complex_structure, $test_name);
# 
# SKIP: {
# 	skip $why, $how_many unless $have_some_feature;
# 	
# 	ok( foo(),       $test_name );
# 	is( foo(42), 23, $test_name );
# };
# 

# 
# can_ok($module, @methods);
# isa_ok($object, $class);
# 
# pass($test_name);
# fail($test_name);
# 
# BAIL_OUT($why);
