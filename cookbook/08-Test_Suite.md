- [Summary](#summary)
- [Important](#important)
- [Using Test::Class](#using-testclass)
- [Using Test::Class::Moose](#using-testclassmoose)
- [How to run the test suite](#how-to-run-the-test-suite)

# Summary
In GenOO we use `Test::Class` and `Test::Class::Moose` to organise the test suite.
Older code is based on `Test::Class` and newer code has migrated to the newer and more shiny `Test::Class::Moose`.
In both cases there is a single driver script that runs all test modules that are written in any of the two structures.

The test code is organised under the `t/` directory and particularly in the folders named `t/lib*`.

The sample data (files, databases, etc.) which are required throughout the suite are organised under the directory `t/sample_data`.

# Important
There must be one test class for every regular GenOO class. This makes it extremely easy to find the tests for each particular module and also helps to identify if tests are missing.

# Using Test::Class
This describes the code organization used in older GenOO modules and is the most abundant one. Newer modules should follow the organization described in the following section `Test::Class::Moose`.

One of the basic ideas in the test suite is that we have to distinguish between tests and data. For this, every test class should provide a method named `test_objects` which returns an array reference with instantiated objects of the tested class.
Usually such a method looks like this:
```perl
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	
	my @test_objects;
	push @test_objects, $test_class->class->new( 'DATA GO HERE' );
	
	return \@test_objects;
}
```

There are two reason for the creation of this method:
1. The first is to instantiate objects that will be tested in the class itself.
2. The second and most important is to be used in subclasses of the test class that need access to the same data.

For example consider we have the test class `Test::Person` which tests for `Person` and `Test::Person::Employee` which tests for `Person::Employee`.
`Test::Person::Employee` inherits tests from `Test::Person` and therefore requires access to the same data as `Test::Person`.

```perl
package Test::Person;

use Test::Most;
use base 'Test::Class';

sub first_name : Tests {
	my $person = Test::Person->test_objects()->[0]; # Call the method that creates the test objects and get the first one
	is $person->first_name, 'John', '... should be named John';
}

sub test_objects {
	require Person;
	
	my @test_objects;
	push @test_objects, Person->new( 
		first_name => 'John'
	);
	
	return \@test_objects;
}

```

```perl
package Test::Person::Employee;

use Test::Most;
use base 'Test::Person';

sub salary : Tests {
	my $employee = Test::Person::Employee->test_objects()->[0]; # Call the method that creates the test objects and get the first one
	is $employee->salary, '50000', '... should be paid 50000';
}

sub test_objects {
	require Person::Employee;
	
	my $person = Test::Person->test_objects()->[0]; # Call the object creation method of the parent class and get the first one
	
	my @test_objects;
	push @test_objects, Person::Employee->new(
		first_name => $person->first_name,
		salary     => '50000';
	)
	
	return \@test_objects;
}
```
Given the above test classes, when `Test::Person::Employee` is run it will successfully test for `fisrt_name` and `salary`.
See how `John` cascades throught the inheritance tree?


# Using Test::Class::Moose
As you may have noticed, the code in the previous example is a little bit scetchy. The reason is that the method `Test::Person::Employee::test_objects` uses the instantiated objects provided by `Test::Person::test_objects` to just access the data. It would be nicer if it would just access the data directly instead of the instantiated objects. For this, in newer code based on `Test::Class::Moose` we use one more level of abstraction distinguishing instantiation and data code. Therefore there are two new methods used: `_init_testable_objects` and `_init_data_for_testable_objects`.
Using these two new methods and `Test::Class::Moose` the above code for `Person` becomes:

```perl
package Test::Person;

use Test::Class::Moose;
with 'MyTCM::Testable';

sub test_first_name {
	is Test::Person->get_testable_object(0)->first_name, 'John', '... should be named John';
	is Test::Person->get_testable_object(1)->first_name, 'Mike', '... should be named Mike';
}

sub _init_testable_objects {
	my ($test) = @_;
	
	# Loop on the data and create one instance for each set of data
	return [$test->map_data_for_testable_objects(sub {$test->class_name->new($_)})];
}

sub _init_data_for_testable_objects {
	my ($test) = @_;
	
	my @data;
	
	push @data, {
		first_name => 'John'
	};
	
	push @data, {
		first_name => 'Mike'
	};
	
	return \@data;
}

```

# How to run the test suite
* To run the whole test suite
```bash
prove -l t/*.t
```

* To run tests for a specific module written using `Test::Class`
```bash
prove -l -It/lib_for_test_class/ here_put_the_path_to_the_module
```
eg. `prove -l -It/lib_for_test_class/ t/lib_for_test_class/Test/GenOO/Transcript.pm`


* To run tests for a specific module written using `Test::Class::Moose`
```bash
prove -l t/test_all_test_class_moose.t :: here_put_the_module_name  # Notice the arisdottle :: to provide arguments to your test driver script
```
eg. `prove -l t/test_all_test_class_moose.t :: TestsFor::GenOO::RegionCollection::Factory::DBIC`

