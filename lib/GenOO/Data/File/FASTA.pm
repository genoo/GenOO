# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::File::FASTA - Object implementing methods for accessing fasta formatted files (http://genome.ucsc.edu/FAQ/FAQformat#format1)

=head1 SYNOPSIS

    # Object that manages a fasta file. 

    # To initialize
    my $fasta_parser = GenOO::Data::File::FASTA->new(
        file            => undef,
    );

=head1 DESCRIPTION

    This object offers methods to read a fasta file line by line.

=head1 EXAMPLES

    # Create object
    my $fasta_parser = GenOO::Data::File::FASTA->new(
          file => 't/sample_data/sample.fasta.gz'
    );
    
    # Read one record at a time
    my $record = $fasta_parser->next_record;
    
    # Get the number of records read
    my $count = $fasta_parser->records_read_count;

=cut

# Let the code begin...

package GenOO::Data::File::FASTA;

# Load external modules
use Modern::Perl;
use autodie;
use Moose;
use namespace::autoclean;

# Load GenOO modules
use GenOO::Data::File::FASTA::Record;

#######################################################################
############################   Attributes   ###########################
#######################################################################
has 'file'  => (isa => 'Maybe[Str]', is => 'rw', required => 1);

has 'records_read_count' => (
	is        => 'rw',
	default   => 0,
	init_arg  => undef,
);

has '_filehandle' => (
	is        => 'ro',
	builder   => '_open_filehandle',
	init_arg  => undef,
	lazy      => 1,
);

has '_stored_record_header' => (
	is        => 'rw',
	clearer   => '_clear_stored_record_header',
	predicate => '_has_stored_record_header',
	init_arg  => undef,
);

has '_stored_record_sequence' => (
	is        => 'rw',
	clearer   => '_clear_stored_record_sequence',
	predicate => '_has_stored_record_sequence',
	init_arg  => undef,
);

has '_eof' => (
	is        => 'rw',
	predicate => '_reached_eof',
	init_arg  => undef
);


#######################################################################
#################   MANIPULATE INSTANCE ARGUMENTS     #################
#######################################################################
around BUILDARGS => sub {
	my ($orig, $class)  = (shift, shift);
	
	my $argv_hash_ref = $class->$orig(@_);
	
	if (exists $argv_hash_ref->{FILE}) {
		$argv_hash_ref->{file} = delete $argv_hash_ref->{FILE};
		warn 'Deprecated use of "FILE" in GenOO::Data::File::FASTA constructor. Use "file" instead.'."\n";
	}
	
	return $argv_hash_ref;
};


#######################################################################
#########################   General Methods   #########################
#######################################################################
sub next_record {
	my ($self) = @_;
	
	return undef if ($self->_reached_eof);
	
	while (my $line = $self->_filehandle->getline) {
		chomp $line;
		if (_line_looks_like_record_header($line)) {
			if ($self->_has_stored_record_header) {
				my $record = $self->_create_record;
				$self->_stored_record_header($line);
				return $record;
			}
			else {
				$self->_stored_record_header($line);
			}
		}
		elsif (_line_looks_like_sequence($line)) {
			$self->_concatenate_to_stored_record_sequence($line);
		}
	}
	$self->_eof(1);
	return $self->_create_record;
}

#######################################################################
#########################   Private methods  ##########################
#######################################################################
sub _open_filehandle {
	my ($self) = @_;
	
	my $read_mode;
	if (!defined $self->file) {
		$read_mode = '<-';
	}
	elsif ($self->file =~ /\.gz$/) {
		$read_mode = '<:gzip';
	}
	else {
		$read_mode = '<';
	}
	open (my $HANDLE, $read_mode, $self->file);
	
	return $HANDLE;
}

sub _concatenate_to_stored_record_sequence {
	my ($self) = @_;
	
	if ($self->_has_stored_record_sequence) {
		$self->_stored_record_sequence($self->_stored_record_sequence.$_[1]);
	}
	else {
		$self->_stored_record_sequence($_[1]);
	}
}

sub _increment_records_read_count {
	my ($self) = @_;
	$self->records_read_count($self->records_read_count+1);
}

sub _create_record {
	my ($self) = @_;
	
	my $record = GenOO::Data::File::FASTA::Record->new(
		header   => $self->_stored_record_header,
		sequence => $self->_stored_record_sequence,
	);
	$self->_clear_stored_record_header;
	$self->_clear_stored_record_sequence;
	$self->_increment_records_read_count;
	
	return $record;
}


#######################################################################
#######################   Private subroutines  ########################
#######################################################################
sub _line_looks_like_record_header {
	return ($_[0] =~ /^>/) ? 1 : 0;
}

sub _line_looks_like_sequence {
	return ((!_line_looks_like_record_header($_[0])) and ($_[0] =~ /\S/)) ? 1 : 0;
}


#######################################################################
############################   Finalize   #############################
#######################################################################
__PACKAGE__->meta->make_immutable;

1;
