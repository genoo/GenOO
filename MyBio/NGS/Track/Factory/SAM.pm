# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::Track::Factory::SAM - Factory for creating MyBio::NGS::Track object from a SAM formatted file

=head1 SYNOPSIS

    # Creates MyBio::NGS::Track object from a SAM formatted file 

    # It should not be used directly but through the generic MyBio::NGS::Track::Factory as follows
    my $factory = MyBio::NGS::Track::Factory->new({
        TYPE => 'SAM'
        FILE => 'sample.sam'
    });

=head1 DESCRIPTION

    Implements the Track::Factory interface and uses the SAM parser to create
    MyBio::NGS::Track object from a SAM formatted file.

=head1 EXAMPLES

    # Create the factory
    my $factory = MyBio::NGS::Track::Factory->new({
        TYPE => 'SAM'
        FILE => 'sample.sam'
    });
    
    # ditto (preferably)
    my $factory = MyBio::NGS::Track::Factory->instantiate({
        TYPE => 'SAM'
        FILE => 'sample.sam'
    });

=cut

# Let the code begin...

package MyBio::NGS::Track::Factory::SAM;
use strict;

use MyBio::NGS::Track;
use MyBio::Data::File::SAM;
use MyBio::NGS::Track::Factory::SAM::Tag;

use base qw(MyBio::_Initializable MyBio::NGS::Track::Factory::Interface);

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
	
	my $parser = MyBio::Data::File::SAM->new({
		FILE => $self->get_file,
	});
	while (my $record = $parser->next_record) {
		if ($record->is_mapped) {
			$track->add_entry(
				MyBio::NGS::Track::Factory::SAM::Tag->new({
					RECORD => $record,
				})
			);
		}
	}
	
	return $track;
}

1;
