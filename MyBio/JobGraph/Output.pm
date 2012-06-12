# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Output - Output interface object

=head1 SYNOPSIS

    # This is the main Output object
       
    # To initialize 
    my $output = MyBio::JobGraph::Output->new({
		NAME       => 'anything',
		SOURCE     => 'anything',
		TYPE       => 'anything',
    });

=head1 DESCRIPTION

    The Output object contains all information for an Output of a job.

=head1 EXAMPLES

    ###TODO

=cut

# Let the code begin...

package MyBio::JobGraph::Output;
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
