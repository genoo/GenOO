package Test::MyBio::NGS::Track;
use strict;

use base qw(Test::MyBio);
use Test::Most;
use Scalar::Util qw(looks_like_number);

use MyBio::NGS::Track::Factory::SAM;


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
sub new_object : Test(setup) {
	my ($self) = @_;
	
	$self->{OBJ} = MyBio::NGS::Track::Factory::SAM->new({
		FILE => 't/sample_data/sample.sam.gz'
	})->read_track;
};

#######################################################################
##########################   Override Tests   #########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj, $self->class, "... and the object";
}

sub stats : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'stats';
	isa_ok $self->obj->stats, 'MyBio::NGS::Track::Stats', "... and the object";
}

sub add_entry : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'add_entry';
	
	$self->obj->add_entry(
		MyBio::NGS::Tag->new({
			CHR           => 'chrX',
			START         => 1,
			STOP          => 100,
			STRAND        => '+',
			NAME          => 'test',
			SCORE         => 0.1,
		})
	);
	is $self->obj->entries_count, 646, "... and it should result in the correct number of tags";
}

sub get_scores_for_all_entries : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'get_scores_for_all_entries';
	
	my @scores = $self->obj->get_scores_for_all_entries;
	is scalar @scores, 645, "... and should return the correct number of scores";
	
	my $look_like_number_count;
	foreach my $score (@scores) {
		if (looks_like_number($score)) {
			$look_like_number_count++;
		}
	}
	is $look_like_number_count, 645, "... and all should be numeric";
}

sub score_sum : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'score_sum';
	is $self->obj->score_sum, 7891, "... and should return the correct value";
}

sub score_mean : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'score_mean';
	is $self->obj->score_mean, 12.2341085271318, "... and should return the correct value";
}

sub score_variance : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'score_variance';
	is $self->obj->score_variance, 234.994805600625, "... and should return the correct value";
}

sub score_stdv : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'score_stdv';
	is $self->obj->score_stdv, 15.3295402931929, "... and should return the correct value";
}

# 
# sub foreach_entry_do : Test(2) {
# 	my ($self) = @_;
# 	
# 	can_ok $self->obj, 'foreach_entry_do';
# 	
# 	my $iterations = 0;
# 	$self->obj->foreach_entry_do(sub{
# 		my ($arg) = @_;
# 		if ($arg->isa('MyBio::Locus')) {
# 			$iterations++;
# 		}
# 	});
# 	is $iterations, $self->obj->entries_count, "... and should do the correct number of iterations";
# }
# 
# sub add_entry : Test(3) {
# 	my ($self) = @_;
# 	
# 	can_ok $self->obj, 'add_entry';
# 	
# 	$self->obj->add_entry(MyBio::Locus->new({STRAND => '-', CHR => 'chr7'}));
# 	is $self->obj->entries_count, 13, "... and should result in the correct number of entries";
# 	is $self->obj->sorted, undef, "... and sort flag should be unset";
# }
# 
# sub get_or_find_longest_entry_length : Test(2) {
# 	my ($self) = @_;
# 	
# 	can_ok $self->obj, 'get_or_find_longest_entry_length';
# 	is $self->obj->get_or_find_longest_entry_length, 10, "... and should return the correct value";
# }
# 
# sub entries_ref_for_keys : Test(2) {
# 	my ($self) = @_;
# 	
# 	can_ok $self->obj, 'entries_ref_for_keys';
# 	is @{$self->obj->entries_ref_for_keys(1,'chr1')}, 3, "... and should return the correct value";
# }
# 
# #######################################################################
# ###########################   Actual Tests   ##########################
# #######################################################################
# sub strands : Test(2) {
# 	my ($self) = @_;
# 	
# 	can_ok $self->obj, 'strands';
# 	is_deeply [$self->obj->strands], [1,-1], "... and should return the correct value";
# }
# 
# sub chromosomes_for_strand : Test(3) {
# 	my ($self) = @_;
# 	
# 	can_ok $self->obj, 'chromosomes_for_strand';
# 	
# 	is $self->obj->chromosomes_for_strand(1), 2, "... and should return the correct value";
# 	is $self->obj->chromosomes_for_strand(-1), 2, "... and should return the correct value";
# }
# 
# sub chromosomes_for_all_strands : Test(2) {
# 	my ($self) = @_;
# 	
# 	can_ok $self->obj, 'chromosomes_for_all_strands';
# 	is_deeply [$self->obj->chromosomes_for_all_strands], ['chr3','chr1','chr4','chr2'], "... and should return the correct value";
# }
# 
# sub entries_ref_for_strand_and_chromosome : Test(2) {
# 	my ($self) = @_;
# 	
# 	can_ok $self->obj, 'entries_ref_for_strand_and_chromosome';
# 	is @{$self->obj->entries_ref_for_strand_and_chromosome(1,'chr1')}, 3, "... and should return the correct value";
# }
# 
# sub sort_entries : Test(7) {
# 	my ($self) = @_;
# 	
# 	can_ok $self->obj, 'sort_entries';
# 	
# 	is $self->obj->sorted, undef, "... and sort flag should be unset";
# 	
# 	$self->obj->sort_entries;
# 	my @test_array_1 = @{$self->obj->entries_ref_for_strand_and_chromosome(1,'chr1')};
# 	my @test_array_2 = @{$self->obj->entries_ref_for_strand_and_chromosome(1,'chr2')};
# 	my @test_array_3 = @{$self->obj->entries_ref_for_strand_and_chromosome(-1,'chr3')};
# 	my @test_array_4 = @{$self->obj->entries_ref_for_strand_and_chromosome(-1,'chr4')};
# 	is_deeply [map{$_->get_start} @test_array_1], [1,2,3], "... and sorting should result in correct order";
# 	is_deeply [map{$_->get_start} @test_array_2], [11,12,13], "... and sorting should result in correct order";
# 	is_deeply [map{$_->get_start} @test_array_3], [21,22,23], "... and sorting should result in correct order";
# 	is_deeply [map{$_->get_start} @test_array_4], [31,32,33], "... and sorting should result in correct order";
# 	
# 	is $self->obj->sorted, 1, "... and sort flag should be set";
# }
# 
# sub entries_overlapping_region  : Test(3) {
# 	my ($self) = @_;
# 	
# 	can_ok $self->obj, 'entries_overlapping_region';
# 	
# 	my @result = map{$_->get_id} $self->obj->entries_overlapping_region(1,'chr1', 2, 5);
# 	is_deeply [@result], ['chr1:1-10:1','chr1:2-10:1','chr1:3-10:1'], "... and should return the correct entries";
# 	
# 	@result = map{$_->get_id} $self->obj->entries_overlapping_region(-1,'chr4', 36, 40);
# 	is_deeply [@result], ['chr4:32-40:-1','chr4:33-40:-1'], "... and should return the correct entries";
# }

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
