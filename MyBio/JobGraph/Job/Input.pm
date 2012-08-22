# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Job::Input - Abstract class for the input of a job

=head1 SYNOPSIS

    # To initialize 
    my $input = MyBio::JobGraph::Job::Input->new({
        NAME       => 'anything',
        SOURCE     => 'anything',
    });

=head1 DESCRIPTION

    Implements and defines methods that need to be present in all derived classes that handle the input
    of a job

=head1 EXAMPLES

    ###TODO

=cut

# Let the code begin...

package MyBio::JobGraph::Job::Input;
use strict;

use base qw(MyBio::_Initializable);

sub _init {
	my ($self,$data) = @_;
	
	$self->set_name($$data{NAME});
	$self->check_and_set_source($$data{SOURCE});
	
	return $self;
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_name {
	my ($self,$value) = @_;
	$self->{NAME} = $value if defined $value;
}

sub check_and_set_source {
	my ($self, $value) = @_;
	
	if (defined $value and $self->source_is_appropriate($value)) {
		$self->{SOURCE} = $value;
	}
}

#######################################################################
############################   Accessors  #############################
#######################################################################
sub name {
	my ($self) = @_;
	return $self->{NAME};
}

sub source {
	my ($self) = @_;
	return $self->{SOURCE};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub source_is_appropriate {
	my ($self, $value) = @_;
	
	unless ($value->isa('MyBio::JobGraph::Data')) {
		die "Data source object $value does not implement MyBio::JobGraph::Data\n";
	}
}

#######################################################################
########################   Abstract Methods   #########################
#######################################################################
sub type {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	if ($class eq __PACKAGE__) {
		return undef;
	}
	else {
		die "Error: Undefined Abstract Method \"".(caller(0))[3]."\" used by $class\n";
	}
}

1;
