package Test::GenOO::Data::File::FASTQ::Record;
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

sub name : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'name', "... test object has the 'name' attribute");
	is $self->obj(0)->name, 'HWUSI-EAS366_7:1:7:1032#0/1', "... and returns the correct value";
}

sub sequence : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'sequence', "... test object has the 'sequence' attribute");
	is $self->obj(0)->sequence, 'TAATAGTTTTATTTCAGGTATAAGNATC', "... and returns the correct value";
}

sub quality : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'quality', "... test object has the 'quality' attribute");
	is $self->obj(0)->quality, 'BCCB<B@BC@;BBBBB=A;BCBA9%?BB', "... and returns the correct value";
}

sub extra : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'extra', "... test object has the 'extra' attribute");
	is $self->obj(0)->extra, 'something', "... and returns the correct value";
}

sub to_string : Test(2) {
	my ($self) = @_;
	
	can_ok($self->obj(0), 'to_string');
	my $correct_result = join("\n",(
		'@HWUSI-EAS366_7:1:7:1032#0/1',
		'TAATAGTTTTATTTCAGGTATAAGNATC',
		'+',
		'BCCB<B@BC@;BBBBB=A;BCBA9%?BB',
	));
	is $self->obj(0)->to_string, $correct_result, "... and returns the correct value";
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
		name         => 'HWUSI-EAS366_7:1:7:1032#0/1',
		sequence     => 'TAATAGTTTTATTTCAGGTATAAGNATC',
		quality      => 'BCCB<B@BC@;BBBBB=A;BCBA9%?BB',
		extra        => 'something',
	});

	return \@test_objects;
}

1;
