# POD documentation - main docs before the code

=head1 NAME

MyBio::Data::File::FASTQ::Record - Object representing a record of a fastq file

=head1 SYNOPSIS

    # Object representing a record of a fastq file 

    # To initialize 
    my $fastq_record = MyBio::Data::File::FASTQ::Record->new({
        name      => undef,
        sequence  => undef,
        quality   => undef,
        extra     => undef,
    });


=head1 DESCRIPTION

    This object represents a record of a fastq file and offers methods for accessing the different attributes.

=head1 EXAMPLES

    # Return record name
    my $name = $fastq_record->name;

=cut

# Let the code begin...

package MyBio::Data::File::FASTQ::Record;

use Moose;
use namespace::autoclean;

has 'name'     => (isa => 'Str', is => 'rw', required => 1);
has 'sequence' => (isa => 'Str', is => 'rw', required => 1);
has 'quality'  => (isa => 'Str', is => 'rw', required => 1);
has 'extra'    => (is => 'rw');

1;