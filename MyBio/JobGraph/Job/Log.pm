# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Job::Log - Abstract class for the log of a job

=head1 SYNOPSIS

    # To initialize 
    my $log = MyBio::JobGraph::Job::Log->new({
        NAME       => 'A name for the log object',
        SOURCE     => 'A file, a database or whatever can store information',
    });

=head1 DESCRIPTION

    Abstract class for storing log information of a job

=cut

# Let the code begin...

package MyBio::JobGraph::Job::Log;
use strict;

use base qw(MyBio::_Initializable);

sub _init {
	my ($self,$data) = @_;
	
	$self->set_name($$data{NAME});
	$self->set_source($$data{SOURCE});
	$self->set_original_source($$data{SOURCE});
	$self->set_devel($$data{DEVEL});
	
	return $self;
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_name {
	my ($self,$value) = @_;
	$self->{NAME} = $value if defined $value;
}

sub set_source {
	my ($self,$value) = @_;
	$self->{SOURCE} = $value if defined $value;
}

sub set_original_source {
	my ($self,$value) = @_;
	$self->{ORIGINAL_SOURCE} = $value if defined $value;
}

sub set_devel {
	my ($self,$value) = @_;
	
	if (defined $value and ($value == 1)) {
		$self->start_devel_mode;
	}
	else {
		$self->stop_devel_mode;
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

sub original_source {
	my ($self) = @_;
	return $self->{ORIGINAL_SOURCE};
}

#######################################################################
########################   Abstract Methods   #########################
#######################################################################
sub append {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	($class eq __PACKAGE__) or die "Error: Undefined Abstract Method \"".(caller(0))[3]."\" used by $class\n";
}

sub clean {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	($class eq __PACKAGE__) or die "Error: Undefined Abstract Method \"".(caller(0))[3]."\" used by $class\n";
}

sub start_devel_mode {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	($class eq __PACKAGE__) or die "Error: Undefined Abstract Method \"".(caller(0))[3]."\" used by $class\n";
}

sub stop_devel_mode {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	($class eq __PACKAGE__) or die "Error: Undefined Abstract Method \"".(caller(0))[3]."\" used by $class\n";
}

sub is_devel_mode_on {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	($class eq __PACKAGE__) or die "Error: Undefined Abstract Method \"".(caller(0))[3]."\" used by $class\n";
}

sub type {
	my ($self) = @_;
	
	my $class = ref($self) || $self;
	($class eq __PACKAGE__) or die "Error: Undefined Abstract Method \"".(caller(0))[3]."\" used by $class\n";
}




1;
