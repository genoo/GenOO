# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Job::Input::File - Input file object that implements MyBio::JobGraph::Job::Input interface

=head1 SYNOPSIS

    # Instantiate
    my $input = MyBio::JobGraph::Job::Input::File->new({
        NAME       => 'An identifier',
        SOURCE     => '/path/to/input/file',
    });

=head1 DESCRIPTION

    This class handles a file as an input for a job.

=head1 EXAMPLES

    # Get the input type
    $input->type

=cut

# Let the code begin...

package MyBio::JobGraph::Job::Input::File;
use strict;

use base qw(MyBio::JobGraph::Job::Input);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	
	return $self;
}

#######################################################################
############################   Accessors  #############################
#######################################################################
sub type {
	my ($self) = @_;
	return 'File';
}

1;
