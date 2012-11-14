package Test::MyBio::NGS::Track::Type::DoubleHashArray;
use strict;

use Scalar::Util qw(looks_like_number);

use Test::MyBio::NGS::Tag;

use base qw(Test::MyBio::LocusCollection::Type::DoubleHashArray);
use Test::Most;
use Test::Moose;

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
##########################   Override Tests   #########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	isa_ok $self->obj(0), $self->class, "... and the object";
}

sub _role_check : Test(1) {
	my ($self) = @_;
	does_ok($self->obj(0), 'MyBio::NGS::Track', '... does the MyBio::NGS::Track role');
}

sub add_entry : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'add_entry';
	
	$self->obj(0)->add_entry(
		MyBio::NGS::Tag->new({
			CHR           => 'chrX',
			START         => 1,
			STOP          => 100,
			STRAND        => '+',
			NAME          => 'test',
			SCORE         => 0.1,
		})
	);
	
	is $self->obj(0)->score_sum, 78.1, "... and should return the correct value";
}

sub get_scores_for_all_entries : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'get_scores_for_all_entries';
	
	my @scores = $self->obj(0)->get_scores_for_all_entries;
	is scalar @scores, 12, "... and should return the correct number of scores";
	
	my $look_like_number_count;
	foreach my $score (@scores) {
		if (looks_like_number($score)) {
			$look_like_number_count++;
		}
	}
	is $look_like_number_count, 12, "... and all should be numeric";
}

sub score_sum : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'score_sum';
	is $self->obj(0)->score_sum, 78, "... and should return the correct value";
}

sub score_mean : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'score_mean';
	is $self->obj(0)->score_mean, 6.5, "... and should return the correct value";
}

sub score_variance : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'score_variance';
	is $self->obj(0)->score_variance, 11.9166666666667, "... and should return the correct value";
}

sub score_stdv : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'score_stdv';
	is $self->obj(0)->score_stdv, 3.45205252953466, "... and should return the correct value";
}

sub quantile : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'quantile';
	is $self->obj(0)->quantile, 9, "... and should return the correct value";
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
	
	my @test_tags = @{Test::MyBio::NGS::Tag->test_objects};
	
	my $test_object_1 = $test_class->class->new({
		name        => 'test_object_1',
		species     => 'human',
		description => 'just a test object'
	});
	$test_object_1->add_entry($test_tags[$_]) for (0..11);
	
	return [$test_object_1];
}

1;
