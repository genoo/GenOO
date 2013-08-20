# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::File::FASTQ::Record - Object representing a record of a fastq file

=head1 SYNOPSIS

    # Object representing a record of a fastq file 

    # To initialize 
    my $fastq_record = GenOO::Data::File::FASTQ::Record->new({
        name      => undef,    #required
        sequence  => undef,    #required
        quality   => undef,    #required
        extra     => undef,
    });


=head1 DESCRIPTION

    This object represents a record of a fastq file and offers methods for accessing the different attributes.

=head1 EXAMPLES

    # Return record name
    my $name = $fastq_record->name;

=cut

# Let the code begin...

package GenOO::Data::File::FASTQ::Record;

use Moose;
use namespace::autoclean;

has 'name'     => (isa => 'Str', is => 'rw', required => 1);
has 'sequence' => (isa => 'Str', is => 'rw', required => 1);
has 'quality'  => (isa => 'Str', is => 'rw', required => 1);
has 'extra'    => (is => 'rw');

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub to_string {
	my ($self) = @_;
	
	return join("\n",(
		'@'.$self->name,
		$self->sequence,
		'+',
		$self->quality,
	));
}

#######################################################################
############################   Finalize   #############################
#######################################################################
__PACKAGE__->meta->make_immutable;

1;
