package TestClassLoader;

use Modern::Perl;
use base qw( Test::Class::Load );


# Select what test classes are considered by T::C::Load
sub is_test_class {
	my ( $class, $file, $dir ) = @_;

	return if $file !~ m/Test\//;
	
	# return unless it's a .pm (the default)
	return unless $class->SUPER::is_test_class( $file, $dir );
}

1;