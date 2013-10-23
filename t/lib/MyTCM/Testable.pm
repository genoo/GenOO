package MyTCM::Testable;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Modern::Perl;
use autodie;
use Moose::Role;
use namespace::autoclean;


#######################################################################
#################   Required methods and attributes   #################
#######################################################################
requires qw(_init_testable_objects _init_data_for_testable_objects);


#######################################################################
#########################   Consumed Roles   ##########################
#######################################################################
with 'MyTCM::AutoUse';


#######################################################################
#######################   Interface attributes   ######################
#######################################################################
has 'testable_objects' => (
	traits    => ['Array'],
	is        => 'ro',
	isa       => 'ArrayRef[Any]',
	clearer   => '_clear_testable_objects',
	builder   => '_init_testable_objects',
	handles   => {
		all_testable_objects    => 'elements',
		add_testable_object     => 'push',
		map_testable_objects    => 'map',
		get_testable_object     => 'get',
		count_testable_objects  => 'count',
		has_testable_objects    => 'count',
		has_no_testable_objects => 'is_empty',
	},
	lazy   => 1
);

has 'data_for_testable_objects' => (
	traits    => ['Array'],
	is        => 'ro',
	isa       => 'ArrayRef[HashRef]',
	builder   => '_init_data_for_testable_objects',
	handles   => {
		all_data_for_testable_objects    => 'elements',
		add_data_for_testable_object     => 'push',
		map_data_for_testable_objects    => 'map',
		get_data_for_testable_object     => 'get',
		count_data_for_testable_objects  => 'count',
		has_data_for_testable_objects    => 'count',
		has_no_data_for_testable_objects => 'is_empty',
	},
	lazy   => 1
);

1;
