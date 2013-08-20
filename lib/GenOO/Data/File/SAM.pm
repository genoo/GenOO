# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::File::SAM - Object implementing methods for accessing SAM formatted files

=head1 SYNOPSIS

    # Object that manages a sam file. 

    # To initialize 
    my $sam_file = GenOO::Data::File::SAM->new(
        file            => undef,
    );


=head1 DESCRIPTION

    This object implements methods to read a sam file line by line.

=head1 EXAMPLES

    # Create object
    my $sam_file = GenOO::Data::File::SAM->new(
          file => 't/sample_data/sample.sam.gz'
    );
    
    # Read one record at a time
    my $sam_record = $sam_file->next_record();

=cut

# Let the code begin...

package GenOO::Data::File::SAM;


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
use GenOO::Data::File::SAM::Record;


#######################################################################
#######################   Interface attributes   ######################
#######################################################################
has 'file' => (
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

has '_is_eof_reached' => (
	traits  => ['Bool'],
	is      => 'rw',
	isa     => 'Bool',
	default => 0,
	handles => {
		_set_eof_reached   => 'set',
		_unset_eof_reached => 'unset',
		_eof_not_reached   => 'not',
	},
);

has '_cached_header_lines' => (
	traits  => ['Array'],
	is      => 'ro',
	default => sub { [] },
	handles => {
		_all_cached_header_lines    => 'elements',
		_add_header_line_in_cache   => 'push',
		_shift_cached_header_line   => 'shift',
		_has_cached_header_lines    => 'count',
		_has_no_cached_header_lines => 'is_empty',
		_cached_header_lines_count  => 'count',
	},
);

has '_cached_records' => (
	traits  => ['Array'],
	is      => 'ro',
	isa     => 'ArrayRef[GenOO::Data::File::SAM::Record]',
	default => sub { [] },
	handles => {
		_all_cached_records    => 'elements',
		_add_record_in_cache   => 'push',
		_shift_cached_record   => 'shift',
		_has_cached_records    => 'count',
		_has_no_cached_records => 'is_empty',
		_cached_records_count  => 'count',
	},
);


#######################################################################
###############################   BUILD   #############################
#######################################################################
sub BUILD {
	my $self = shift;
	
	$self->_parse_header_section;
}

around BUILDARGS => sub {
	my $orig  = shift;
	my $class = shift;
	
	my $argv_hash_ref = $class->$orig(@_);
	
	if (exists $argv_hash_ref->{FILE}) {
		$argv_hash_ref->{file} = delete $argv_hash_ref->{FILE};
		warn 'Deprecated use of "FILE" in GenOO::Data::File::SAM constructor. '.
		     'Use "file" instead.'."\n";
	}
	
	return $argv_hash_ref;
};


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


#######################################################################
#########################   Private Methods   #########################
#######################################################################
sub _parse_header_section {
	my ($self) = @_;
	
	my $filehandle = $self->_filehandle;
	while (my $line = $filehandle->getline) {
		if ($line =~ /^\@/) {
			chomp($line);
			$self->_add_header_line_in_cache($line);
		}
		else {
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
	
	my $line = $self->_filehandle->getline;
	if (defined $line) {
		if ($line !~ /^\@/) {
			return $self->_parse_record_line($line);
		}
		else {
			die "A record is requested but the line looks like a header - header section should have been parsed. $line\n";
		}
	}
	else {
		$self->_set_eof_reached;
		return undef;
	}
}

sub _parse_record_line {
	my ($self,$line) = @_;
	
	chomp $line;
	my ($qname, $flag, $rname, $pos, $mapq, $cigar, $rnext, $pnext, $tlen, $seq, $qual, @tags) = split(/\t/,$line);
	
	return GenOO::Data::File::SAM::Record->new({
		qname      => $qname,
		flag       => $flag,
		rname      => $rname,
		'pos'        => $pos,
		mapq       => $mapq,
		cigar      => $cigar,
		rnext      => $rnext,
		pnext      => $pnext,
		tlen       => $tlen,
		seq        => $seq,
		qual       => $qual,
		tags       => \@tags,
	});
}

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

1;
