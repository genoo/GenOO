# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Job::Input - Input interface object

=head1 SYNOPSIS

    # This is the main Input object
       
    # To initialize 
    my $input = MyBio::JobGraph::Job::Input->new({
        NAME       => 'anything',
        SOURCE     => 'anything',
    });

=head1 DESCRIPTION

    The Input object contains all information for an Input of a job.

=head1 EXAMPLES

    ###TODO

=cut

# Let the code begin...

package MyBio::JobGraph::Job::Input;
use strict;

use base qw(MyBio::JobGraph::Job::IO);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	return $self;
}

1;
