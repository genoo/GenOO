package Test::GenOO::GeneCollection::Factory::FromTranscriptCollection;
use strict;

use Test::GenOO::TranscriptCollection::Factory;
use GenOO::TranscriptCollection::Factory::GTF;

use base qw(Test::GenOO);
use Test::Most;
use Test::Moose;

######################################################################
###############   Startup (Runs once in the begining  ################
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
##########################   Initial Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	isa_ok $self->obj(0), $self->class, "... and the object";
}

sub _role_check : Test(1) {
	my ($self) = @_;
	does_ok($self->obj(0), 'GenOO::RegionCollection::Factory::Requires', '... does the appropriate role');
}

#######################################################################
#######################   Class Interface Tests   #####################
#######################################################################
sub annotation_hash : Test(1) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'annotation_hash', "... test object has the 'annotation_hash' attribute");
}
# 
sub transcript_collection : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'transcript_collection';
	
	my $collection = $self->obj(0)->transcript_collection;
	does_ok($collection, 'GenOO::RegionCollection', "... and the returned object does the GenOO::RegionCollection role");
	is $collection->records_count, 70, "... and it contains the correct number of records";
}

sub read_collection : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'read_collection';
	
	my $collection = $self->obj(0)->read_collection;
	does_ok($collection, 'GenOO::RegionCollection', "... and the returned object does the GenOO::RegionCollection role");
	is $collection->records_count, 6, "... and it contains the correct number of records";
}

#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	
	my @test_objects;
	
	my $annotation_hash_ref = {
		"uc001aal.1"  =>  "OR4F5",
		"uc001aav.3"  =>  "LOC388312",
		"uc009vjm.2"  =>  "LOC388312",
		"uc001abe.3"  =>  "LOC388312",
		"uc002khh.2"  =>  "LOC388312",
		"uc001abi.1"  =>  "DQ575788",
		"uc010nxz.1"  =>  "FLJ39609",
		"uc010nxy.1"  =>  "FLJ39609",
		"uc009vit.2"  =>  "DKFZp434K1323",
		"uc001aae.3"  =>  "DKFZp434K1323",
		"uc001aah.3"  =>  "DKFZp434K1323",
		"uc009viu.2"  =>  "DKFZp434K1323",
		"uc001aac.3"  =>  "DKFZp434K1323",
		"uc009viq.2"  =>  "DKFZp434K1323",
		"uc001aab.3"  =>  "DKFZp434K1323",
		"uc009vis.2"  =>  "DKFZp434K1323",
		"uc009vir.2"  =>  "DKFZp434K1323",
		"uc009vix.2"  =>  "DKFZp434K1323",
		"uc009vjd.2"  =>  "DKFZp434K1323",
		"uc009viz.2"  =>  "DKFZp434K1323",
		"uc009viy.2"  =>  "DKFZp434K1323",
		"uc001aai.1"  =>  "DKFZp434K1323",
		"uc010nxs.1"  =>  "DKFZp434K1323",
		"uc009vjb.1"  =>  "DKFZp434K1323",
		"uc009vjc.1"  =>  "DKFZp434K1323",
		"uc009vje.2"  =>  "DKFZp434K1323",
		"uc009vjf.2"  =>  "DKFZp434K1323"
	};
	
	my $transcript_collection_object_array = Test::GenOO::TranscriptCollection::Factory::GTF->test_objects();
	my $transcript_collection = $$transcript_collection_object_array[0]->read_collection;
	
	push @test_objects, $test_class->class->new({
		transcript_collection => $transcript_collection,
		annotation_hash       => $annotation_hash_ref,
	});
	
	return \@test_objects;
}

1;
