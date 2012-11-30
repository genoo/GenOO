# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::File::FASTQ - Object implementing methods for accessing fastq formatted files

=head1 SYNOPSIS

    # Object that manages a fastq file. 

    # To initialize 
    my $file = GenOO::Data::File::FASTQ->new({
        FILE            => undef,
        EXTRA_INFO      => undef,
    });


=head1 DESCRIPTION

    This object offers methods to read a fastq file entry by entry

=head1 EXAMPLES

    # Read one entry
    my $entry = $fastq_parser->next();

=head1 AUTHOR - Manolis Maragkakis

Email em.maragkakis@gmail.com

=cut

# Let the code begin...

package GenOO::Data::File::FASTQ;

use FileHandle;
use Moose;
use namespace::autoclean;
use GenOO::Data::File::FASTQ::Record;

has 'file'  => (isa => 'Str', is => 'rw', required => 1);
has 'extra' => (isa => 'Str', is => 'rw');

has '_filehandle' => (
	is        => 'ro',
	builder   => '_open_filehandle',
	init_arg  => undef,
	lazy      => 1,
);

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub next_record {
	my ($self) = @_;
	
	while (my $line = $self->_filehandle->getline) {
		if ($line =~ /^\@/) {
			my $id = substr($line,1); chomp($id);
			my $seq =$self->_filehandle->getline; chomp($seq);
			my $not_used = $self->_filehandle->getline; chomp($not_used); #unused line
			my $quality = $self->_filehandle->getline; chomp($quality);
			
			return $self->_create_record($id, $seq, $quality);
		}
	}
	return undef;
}

#######################################################################
#######################   Private Methods  ############################
#######################################################################
sub _open_filehandle {
	my ($self) = @_;
	
	my $read_mode = ($self->file !~ /\.gz$/) ? '<' : '<:gzip';
	return FileHandle->new($self->file, $read_mode) or die 'Cannot open file '.$self->file.". $!";
}

sub _create_record {
	my ($self, $id, $seq, $quality) = @_;
	
	return GenOO::Data::File::FASTQ::Record->new(
		name     => $id,
		sequence => $seq,
		quality  => $quality,
	);
}

1;
