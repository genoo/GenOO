# POD documentation - main docs before the code

=head1 NAME

MyBio::Data::DB::Alignment::Record - Class consuming MyBio::Region role for a database record

=head1 SYNOPSIS

    # Initialize 
    my $db_region = MyBio::Data::DB::Alignment::Record->new({
        name        => undef,
        strand      => undef,
        rname       => undef,
        start       => undef,
        stop        => undef,
        copy_number => undef,
        extra       => undef,
    });


=head1 DESCRIPTION

    This class provides a MyBio::Region interface for records stored in a database. The objects of the class consume the MyBio::Region role and therefore support all attributes and methods defined by the role. They also have extra accessors for the remaining data provided by the database records.

=head1 EXAMPLES

    # Return 1 or -1 for the strand
    my $strand = $db_region->strand;

=cut

# Let the code begin...

package MyBio::Data::DB::Alignment::Record;

use Moose;
use namespace::autoclean;

has 'strand'      => (is => 'rw', required => 1);
has 'rname'       => (isa => 'Str', is => 'rw', required => 1);
has 'start'       => (isa => 'Int', is => 'rw', required => 1);
has 'stop'        => (isa => 'Int', is => 'rw', required => 1);
has 'copy_number' => (isa => 'Int', is => 'rw', required => 1);
has 'sequence'    => (isa => 'Str', is => 'rw', required => 1);
has 'cigar'       => (isa => 'Str', is => 'rw', required => 1);
has 'mdz'         => (isa => 'Int', is => 'rw', required => 1);
has 'extra'       => (is => 'rw');

with 'MyBio::Region';

__PACKAGE__->meta->make_immutable;
1;
