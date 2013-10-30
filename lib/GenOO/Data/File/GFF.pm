# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::File::GFF - Object implementing methods for accessing GFF formatted files (http://www.sanger.ac.uk/resources/software/gff/spec.html)

=head1 SYNOPSIS

    # Object that manages a gff file. 

    # To initialize 
    my $gff_file = GenOO::Data::File::GFF->new(
        file            => undef,
    );


=head1 DESCRIPTION

    This object offers methods to read a gff file line by line.

=head1 EXAMPLES

    # Create object
    my $gff_file = GenOO::Data::File::GFF->new(
          file => 't/sample_data/sample.gff.gz'
    );
    
    # Read one record at a time
    my $record = $gff_file->next_record();

=cut

# Let the code begin...


package GenOO::Data::File::GFF;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Modern::Perl;
use autodie;
use Moose;
use namespace::autoclean;


#######################################################################
#########################   Load GenOO modules   ######################
#######################################################################
use GenOO::Data::File::GFF::Record;


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

has '_eof_reached' => (
	is        => 'rw',
	default   => 0,
	init_arg  => undef,
	lazy      => 1,
);

has '_header' => (
	is        => 'ro',
	default   => sub {{}},
	init_arg  => undef,
	lazy      => 1,
);

has '_cached_records' => (
	traits  => ['Array'],
	is      => 'ro',
	isa     => 'ArrayRef[GenOO::Data::File::GFF::Record]',
	default => sub { [] },
	handles => {
		_all_cached_records    => 'elements',
		_add_record_in_cache   => 'push',
		_shift_cached_record   => 'shift',
		_has_cached_records    => 'count',
		_has_no_cached_records => 'is_empty',
	},
);


#######################################################################
###############################   BUILD   #############################
#######################################################################
sub BUILD {
	my $self = shift;
	
	$self->_parse_header_section;
}

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub next_record {
	my ($self) = @_;
	
	my $record;
	if ($self->_has_cached_records) {
		$record = $self->_shift_cached_record;
	}
	else {
		$record = $self->_next_record_from_file;
	}
	
	if (defined $record) {
		$self->_inc_records_read_count;
	}
	return $record;
}

sub version {
	my ($self) = @_;
	return $self->_header->{VERSION};
}


#######################################################################
#########################   Private Methods   #########################
#######################################################################
sub _parse_header_section {
	my ($self) = @_;
	
	my $filehandle = $self->_filehandle;
	while (my $line = $filehandle->getline) {
		if ($self->_line_looks_like_header($line)) {
			$self->_recognize_and_store_header_line($line);
		}
		elsif ($self->_line_looks_like_record($line)) {
			# When the while reads the first line after the header section
			# we need to process it immediatelly because in zipped files we cannot go back
			my $record = $self->_parse_record_line($line);
			$self->_add_record_in_cache($record); 
			return;
		}
	}
}

sub _next_record_from_file {
	my ($self) = @_;
	
	while (my $line = $self->_filehandle->getline) {
		if ($self->_line_looks_like_record($line)) {
			return $self->_parse_record_line($line);
		}
		elsif ($self->_line_looks_like_header) {
			die "A record was expected but line looks like a header - the header should have been parsed already. $line\n";
		}
	}
	
	$self->_eof_reached(1); # When you reach this point the file has finished
	return undef;
}

sub _parse_record_line {
	my ($self, $line) = @_;
	
	chomp $line;
	$line =~ s/(#.+)$//;
	my $comment_string = $1;
	my ($seqname, $source, $feature, $start, $end, $score, $strand, $frame, $attributes_string) = split(/\t/,$line);
	my @attributes = split(/;\s*/,$attributes_string);
	my %attributes_hash;
	foreach my $attribute (@attributes) {
		$attribute =~ /(.+)="(.+)"/;
		$attributes_hash{$1} = $2;
	}
	
	return GenOO::Data::File::GFF::Record->new({
		seqname       => $seqname,
		source        => $source,
		feature       => $feature,
		start_1_based => $start, # 1-based
		stop_1_based  => $end, # 1-based
		score         => $score,
		strand        => $strand,
		frame         => $frame,
		attributes    => \%attributes_hash,
		comment       => $comment_string,
	});
}

sub _recognize_and_store_header_line {
	my ($self, $line) = @_;
	
	if ($self->_line_looks_like_version($line)) {
		$self->_parse_line_and_store_version($line);
	}
	else {
		$self->_parse_and_store_generic_header_line($line);
	}
}

sub _parse_line_and_store_version {
	my ($self, $line) = @_;
	
	my $version = (split(/\s+/,$line))[1];
	$self->_header->{VERSION} = $version;
}

sub _parse_and_store_generic_header_line {
	my ($self, $line) = @_;
	
	my ($key, @values) = split(/\s+/,$line);
	$self->_header->{$key} = join(' ', @values);
}

sub _line_looks_like_header {
	my ($self, $line) = @_;
	return ($line =~ /^#{2}/) ? 1 : 0;
}

sub _line_looks_like_record {
	my ($self, $line) = @_;
	return ($line !~ /^#/) ? 1 : 0;
}

sub _line_looks_like_version {
	my ($self, $line) = @_;
	return ($line =~ /^##gff-version/) ? 1 : 0;
}


#######################################################################
#########################   Private Methods   #########################
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


#######################################################################
############################   Finalize   #############################
#######################################################################
__PACKAGE__->meta->make_immutable;

1;