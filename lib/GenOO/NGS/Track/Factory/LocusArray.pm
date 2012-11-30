# POD documentation - main docs before the code

=head1 NAME

GenOO::NGS::Track::Factory::LocusArray - Factory for creating GenOO::NGS::Track object from a LocusArray

=head1 SYNOPSIS

    # Creates GenOO::NGS::Track object from a LocusArray

    # It should not be used directly but through the generic GenOO::NGS::Track::Factory as follows
    my $factory = GenOO::NGS::Track::Factory->new({
        TYPE  => 'LocusArray'
        ARRAY => \@locus_array
    });

=head1 DESCRIPTION

    Implements the Track::Factory interface and creates a GenOO::NGS::Track object from an array of locuses

=head1 EXAMPLES

    # Create the factory
    my $factory = GenOO::NGS::Track::Factory->new({
        TYPE  => 'LocusArray'
        ARRAY => \@locus_array
    });
    
    # ditto (preferably)
    my $factory = GenOO::NGS::Track::Factory->instantiate({
        TYPE  => 'LocusArray'
        ARRAY => \@locus_array
    });

=cut

# Let the code begin...

package GenOO::NGS::Track::Factory::LocusArray;
use strict;

use GenOO::NGS::Track::Type::DoubleHashArray;

use base qw(GenOO::_Initializable GenOO::NGS::Track::Factory::Interface);

our $VERSION = '1.0';

sub _init {
	my ($self,$data) = @_;
	
	$self->set_array($$data{ARRAY});
	$self->set_extra($$data{EXTRA_INFO});
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_array {
	my ($self, $value) = @_;
	$self->{ARRAY} = $value if defined $value;
}

#######################################################################
########################   Attribute Getters   ########################
#######################################################################
sub array {
	my ($self) = @_;
	return $self->{ARRAY};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub read_track {
	my ($self) = @_;
	
	my $track = GenOO::NGS::Track::Type::DoubleHashArray->new;
	
	foreach my $record ( @{$self->array} ) {
		$track->add_record($record);
	}
	return $track;
}

1;
