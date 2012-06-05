# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::TrackFactory::GFF - Factory for creating MyBio::NGS::Track object from a GFF formatted file

=head1 SYNOPSIS

    # Creates MyBio::NGS::Track object from a GFF formatted file 

    # It should not be used directly but through the generic MyBio::NGS::TrackFactory as follows
    my $factory = MyBio::NGS::TrackFactory->new({
        TYPE => 'GFF'
        FILE => 'sample.gff'
    });

=head1 DESCRIPTION

    Implements the TrackFactory interface and uses the GFF parser to create
    MyBio::NGS::Track object from a GFF formatted file.

=head1 EXAMPLES

    # Create the factory
    my $factory = MyBio::NGS::TrackFactory->new({
        TYPE => 'GFF'
        FILE => 'sample.gff'
    });
    
    # ditto (preferably)
    my $factory = MyBio::NGS::TrackFactory->instantiate({
        TYPE => 'GFF'
        FILE => 'sample.gff'
    });

=cut

# Let the code begin...

package MyBio::NGS::TrackFactory::GFF;
use strict;

use MyBio::NGS::Track;
use MyBio::Data::File::GFF;
use MyBio::Data::File::GFF::Tag;

use base qw(MyBio::_Initializable MyBio::NGS::TrackFactory::Interface);

our $VERSION = '1.0';

sub _init {
	my ($self,$data) = @_;
	
	$self->set_file($$data{FILE});
	$self->set_extra($$data{EXTRA_INFO});
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_file {
	my ($self, $value) = @_;
	$self->{FILE} = $value if defined $value;
}

#######################################################################
########################   Attribute Getters   ########################
#######################################################################
sub get_file {
	my ($self) = @_;
	return $self->{FILE};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub read_track {
	my ($self) = @_;
	
	my $track = MyBio::NGS::Track->new;
	
	my $gff = MyBio::Data::File::GFF->new({
		FILE => $self->get_file,
	});
	while (my $record = $gff->next_record) {
		$track->add_tag(
			MyBio::Data::File::GFF::Tag->new({
				RECORD => $record,
			})
		);
	}
	
	return $track;
}

1;
