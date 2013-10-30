package Test::GenOO;

use Modern::Perl;

use base 'Test::Class';
use Test::More;

INIT { Test::Class->runtests }

#######################################################################
###########################   Class Methods   #########################
#######################################################################
sub class {
	my ($self) = @_;
	
	(my $class = ref($self) || $self) =~ s/^Test:://;
	return $class;
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

1;
