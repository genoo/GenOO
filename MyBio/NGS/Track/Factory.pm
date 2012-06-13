# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::Track::Factory - Factory for creating MyBio::NGS::Track objects

=head1 SYNOPSIS

    # It helps to encapsulate the actual factories that handle the creation of the requested objects
    
    # Usage
    my $factory = MyBio::NGS::Track::Factory->new({
        TYPE => 'GFF'
        FILE => 'sample.gff'
    });

=head1 DESCRIPTION

    It helps to encapsulate the actual factories that handle the creation of the requested objects

=head1 EXAMPLES

    # Create a factory
    my $factory = MyBio::NGS::Track::Factory->new({
        TYPE => 'GFF'
    }); # returns the actual factory that can handle GFF files
    
    # ditto (preferably)
    my $factory = MyBio::NGS::Track::Factory->instantiate({
        TYPE => 'GFF'
    });

=cut

# Let the code begin...

package MyBio::NGS::Track::Factory;
use strict;

our $VERSION = '1.0';

sub new {
	my ($class,$data) = @_;
	
	return $class->instantiate($data);
}

sub instantiate {
	my ($self,$data) = @_;
	
	my $type = delete $data->{TYPE};
	
	if (defined $type) {
		my $handler_class_path = 'MyBio/NGS/Track/Factory/'.$type.'.pm';
		my $handler_class = 'MyBio::NGS::Track::Factory::'.$type;
		require $handler_class_path;
	
		return $handler_class->new($data);
	}
	else {
		die "\n\nUnknown type or no type specified when calling ".(caller(0))[3]." in script $0\n\n";
	}
}

1;
