# POD documentation - main docs before the code

=head1 NAME

GenOO::NGS::Track::Factory::GFF - Factory for creating GenOO::NGS::Track object from a GFF formatted file

=head1 SYNOPSIS

    # Creates GenOO::NGS::Track object from a GFF formatted file 

    # It should not be used directly but through the generic GenOO::NGS::Track::Factory as follows
    my $factory = GenOO::NGS::Track::Factory->new({
        TYPE => 'GFF'
        FILE => 'sample.gff'
    });

=head1 DESCRIPTION

    Implements the Track::Factory interface and uses the GFF parser to create
    GenOO::NGS::Track object from a GFF formatted file.

=head1 EXAMPLES

    # Create the factory
    my $factory = GenOO::NGS::Track::Factory->new({
        TYPE => 'GFF'
        FILE => 'sample.gff'
    });
    
    # ditto (preferably)
    my $factory = GenOO::NGS::Track::Factory->instantiate({
        TYPE => 'GFF'
        FILE => 'sample.gff'
    });

=cut

# Let the code begin...

package GenOO::NGS::Track::Factory::GFF;
use strict;

use GenOO::NGS::Track::Type::DoubleHashArray;
use GenOO::Data::File::GFF;
use GenOO::NGS::Track::Factory::GFF::Tag;

use base qw(GenOO::_Initializable GenOO::NGS::Track::Factory::Interface);

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
	
	my $track = GenOO::NGS::Track::Type::DoubleHashArray->new;
	
	my $gff = GenOO::Data::File::GFF->new({
		FILE => $self->get_file,
	});
	while (my $record = $gff->next_record) {
		$track->add_record(
			GenOO::NGS::Track::Factory::GFF::Tag->new({
				RECORD => $record,
			})
		);
	}
	
	return $track;
}

1;
