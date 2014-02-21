# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::File::FASTQ - Object implementing methods for accessing fastq formatted files

=head1 SYNOPSIS

    # Object that manages a fastq file. 

    # To initialize 
    my $file = GenOO::Data::File::FASTQ->new(
        file            => undef,
    );

=head1 DESCRIPTION

    This object offers methods to read a fastq file entry by entry

=head1 EXAMPLES

    # Read one entry
    my $entry = $fastq_parser->next_record();

=cut

# Let the code begin...

package GenOO::Data::File::FASTQ;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Modern::Perl;
use autodie;
use Moose;
use namespace::autoclean;
use IO::Zlib;


#######################################################################
#########################   Load GenOO modules   ######################
#######################################################################
use GenOO::Data::File::FASTQ::Record;


#######################################################################
#######################   Interface attributes   ######################
#######################################################################
has 'file'  => (
	isa      => 'Maybe[Str]',
	is       => 'rw',
	required => 1
);

has 'records_read_count' => (
	traits  => ['Counter'],
	is      => 'ro',
	isa     => 'Num',
	default => 0,
	handles => {
		_inc_records_read_count   => 'inc',
		_reset_records_read_count => 'reset',
	},
);


#######################################################################
########################   Private attributes   #######################
#######################################################################
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
	
	my $filehandle = $self->_filehandle;
	while (my $line = $filehandle->getline) {
		if ($line =~ /^\@/) {
			my $id = substr($line,1); chomp($id);
			my $seq = $filehandle->getline; chomp($seq);
			$filehandle->getline; #unused line
			my $quality = $filehandle->getline; chomp($quality);
			
			$self->_inc_records_read_count;
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
	
	my $read_mode;
	my $HANDLE;
	if (!defined $self->file) {
		open ($HANDLE, '<-', $self->file);
	}
	elsif ($self->file =~ /\.gz$/) {
		$HANDLE = IO::Zlib->new($self->file, 'rb') or die "Cannot open file ".$self->file."\n";
	}
	else {
		open ($HANDLE, '<', $self->file);
	}
	
	return $HANDLE;
}

sub _create_record {
	my ($self, $id, $seq, $quality) = @_;
	
	return GenOO::Data::File::FASTQ::Record->new(
		name     => $id,
		sequence => $seq,
		quality  => $quality,
	);
}

#######################################################################
############################   Finalize   #############################
#######################################################################
__PACKAGE__->meta->make_immutable;

1;
