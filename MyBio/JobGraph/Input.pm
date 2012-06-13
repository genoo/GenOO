# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Input - Input interface object

=head1 SYNOPSIS

    # This is the main Input object
       
    # To initialize 
    my $input = MyBio::JobGraph::Input->new({
		NAME       => 'anything',
		SOURCE     => 'anything',
		TYPE       => 'anything',
    });

=head1 DESCRIPTION

    The Input object contains all information for an Input of a job.

=head1 EXAMPLES

    ###TODO

=cut

# Let the code begin...

package MyBio::JobGraph::Input;
use strict;

use base qw(MyBio::_Initializable MyBio::JobGraph::IO);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	return $self;
}
 
#######################################################################
########################   Attribute Getters   ########################
#######################################################################

#######################################################################
########################   Attribute Setters   ########################
#######################################################################

#######################################################################
#############################   Methods   #############################
#######################################################################

1;
