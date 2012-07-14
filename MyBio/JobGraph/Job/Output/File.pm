# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Job::Output::File - Output interface between L<MyBio::JobGraph::Job> and L<MyBio::JobGraph::Data::File>

=head1 SYNOPSIS

    # Instantiate
    my $output = MyBio::JobGraph::Job::Output::File->new({
        NAME       => A name for the input/output object,
        SOURCE     => MyBio::JobGraph::Data::File,
    });

=head1 DESCRIPTION

    This class serves as an output interface between L<MyBio::JobGraph::Job> and L<MyBio::JobGraph::Data::File>
    It implements MyBio::JobGraph::Job::Output. It also interfaces the methods for transition to development
    mode and for cleaning the file when done.

=head1 EXAMPLES

    # Start development mode. Sets output into a temporary development file
    $output->start_devel_mode
    
    # Delete the development file
    $output->clean
    
    # Stop development mode. Sets output into the original file
    $output->stop_devel_mode
    
    # Delete the original output file
    $output->clean

=cut

# Let the code begin...

package MyBio::JobGraph::Job::Output::File;
use strict;

use MyBio::JobGraph::Data::File;
use MyBio::JobGraph::Job::Input::File;

use base qw(MyBio::JobGraph::Job::Output);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	$self->create_source_from_filename($$data{FILENAME});
	
	return $self;
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub source_is_appropriate { # Override
	my ($self, $value) = @_;
	
	unless ($value->isa('MyBio::JobGraph::Data::File')) {
		die "Data source object $value does not implement MyBio::JobGraph::Data::File\n";
	}
}

sub create_source_from_filename {
	my ($self, $value) = @_;
	
	if (defined $value) {
		$self->{SOURCE} = MyBio::JobGraph::Data::File->new({
			FILENAME => $value,
		});
	}
}

sub to_input {
	my ($self) = @_;
	
	return MyBio::JobGraph::Job::Input::File->new({
		SOURCE => $self->source,
	});
}

sub filename {
	my ($self) = @_;
	return $self->source->filename;
}

sub type { # Override
	my ($self) = @_;
	return $self->source->type;
}

sub clean { # Override
	my ($self) = @_;
	return $self->source->clean;
}

sub start_devel_mode { # Override
	my ($self) = @_;
	return $self->source->start_devel_mode;
}

sub stop_devel_mode { # Override
	my ($self) = @_;
	return $self->source->stop_devel_mode;
}

sub is_devel_mode_on { # Override
	my ($self) = @_;
	return $self->source->is_devel_mode_on;
}

1;
