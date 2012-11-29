# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::Track::Factory::LocusArray - Factory for creating MyBio::NGS::Track object from a LocusArray

=head1 SYNOPSIS

    # Creates MyBio::NGS::Track object from a LocusArray

    # It should not be used directly but through the generic MyBio::NGS::Track::Factory as follows
    my $factory = MyBio::NGS::Track::Factory->new({
        TYPE  => 'LocusArray'
        ARRAY => \@locus_array
    });

=head1 DESCRIPTION

    Implements the Track::Factory interface and creates a MyBio::NGS::Track object from an array of locuses

=head1 EXAMPLES

    # Create the factory
    my $factory = MyBio::NGS::Track::Factory->new({
        TYPE  => 'LocusArray'
        ARRAY => \@locus_array
    });
    
    # ditto (preferably)
    my $factory = MyBio::NGS::Track::Factory->instantiate({
        TYPE  => 'LocusArray'
        ARRAY => \@locus_array
    });

=cut

# Let the code begin...

package MyBio::NGS::Track::Factory::LocusArray;
use strict;

use MyBio::NGS::Track::Type::DoubleHashArray;

use base qw(MyBio::_Initializable MyBio::NGS::Track::Factory::Interface);

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
	
	my $track = MyBio::NGS::Track::Type::DoubleHashArray->new;
	
	foreach my $record ( @{$self->array} ) {
		$track->add_entry($record);
	}
	return $track;
}

1;
