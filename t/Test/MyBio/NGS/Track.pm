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

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
