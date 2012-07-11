package Test::MyBio::JobGraph::Job::Description;
use strict;

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
sub new_object : Test(setup) {
	my ($self) = @_;
	
	$self->{OBJ} = $self->class->new({
		HEADER     => 'Job {{NAME}}',
		ABSTRACT   => 'A short summary of job {{NAME}}',
		TEXT       => 'Job {{NAME}} is on version {{VERSION}}',
	});
};


#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj, $self->class, "... and the object";
}

sub header : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('header', 'whatever', 'whatever');
}

sub abstract : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('abstract', 'whatever', 'whatever');
}

sub text : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('text', 'whatever', 'whatever');
}

sub placeholders : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'placeholders';
	
	isa_ok $self->obj->placeholders, 'HASH', "... and returned object";
}

sub init_placeholders : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'init_placeholders';
	
	$self->obj->init_placeholders;
	isa_ok $self->obj->placeholders, 'HASH', "... and the object it creates";
	is $self->obj->placeholder_names, 0 , "... and nothing should be stored";
}

sub add_placeholder : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'add_placeholder';
	
	$self->obj->add_placeholder('NAME', '1');
	is $self->obj->placeholder_names, 1 , "... and should add successfully";
	is $self->obj->placeholder_value('NAME'), 1 , "... and should add the correct values";
}

sub placeholder_names : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'placeholder_names';
	
	$self->obj->add_placeholder('NAME', '1');
	$self->obj->add_placeholder('VERSION', '1.1.0');
	
	is_deeply [$self->obj->placeholder_names], ['NAME','VERSION'] , "... and should return the correct values";
}

sub placeholder_value : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj, 'placeholder_value';
	
	$self->obj->add_placeholder('NAME', '1');
	is $self->obj->placeholder_value('NAME'), '1' , "... and should return the correct value";
}

sub to_string : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj, 'to_string';
	
	my $result = join("\n",
		'Job {{NAME}}',
		'A short summary of job {{NAME}}',
		'Job {{NAME}} is on version {{VERSION}}',
	);
	is $self->obj->to_string, $result , "... and should return the correct value";
	
	
	$self->obj->add_placeholder('NAME', '1');
	$self->obj->add_placeholder('VERSION', '1.1.0');
	$result = join("\n",
		'Job 1',
		'A short summary of job 1',
		'Job 1 is on version 1.1.0',
	);
	is $self->obj->to_string, $result , "... and should return the correct value again";
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
