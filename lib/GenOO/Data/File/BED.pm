# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::File::BED - Object implementing methods for accessing bed formatted files (http://genome.ucsc.edu/FAQ/FAQformat#format1)

=head1 SYNOPSIS

    # Object that manages a bed file. 

    # To initialize 
    my $bed_file = GenOO::Data::File::BED->new({
        FILE            => undef,
        EXTRA_INFO      => undef,
    });

=head1 DESCRIPTION

    This object offers methods to read a bed file line by line.

=head1 EXAMPLES

    # Create object
    my $bed_file = GenOO::Data::File::BED->new({
          FILE => 't/sample_data/sample.bed.gz'
    });
    
    # Read one record at a time
    my $record = $bed_file->next_record();

=cut

# Let the code begin...

package GenOO::Data::File::BED;


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
use GenOO::Data::File::BED::Record;


#######################################################################
#######################   Interface attributes   ######################
#######################################################################
has 'file' => (
	isa      => 'Maybe[Str]',
	is       => 'rw',
	required => 1
);

has 'redirect_score_to_copy_number' => (
	traits  => ['Bool'],
	is      => 'rw',
	isa     => 'Bool',
	default => 0,
	lazy    => 1
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
##############################   BUILD   ##############################
#######################################################################
sub BUILD {
	my $self = shift;
	
	$self->init_header;
	$self->init_records_cache;
	$self->init_records_read_count;
	
	$self->parse_header_section;
}


#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub records_read_count {
	my ($self) = @_;
	return $self->{RECORDS_READ_COUNT};
}

sub next_record {
	my ($self) = @_;
	
	my $record;
	if ($self->record_cache_not_empty) {
		$record = $self->next_record_from_cache;
	}
	else {
		$record = $self->next_record_from_file;
	}
	
	if (defined $record) {
		$self->increment_records_read_count;
	}
	return $record;
}


#######################################################################
#######################   Private Methods  ############################
#######################################################################
sub set_eof_reached {
	my ($self) = @_;
	$self->{EOF} = 1;
}

sub header {
	my ($self) = @_;
	return $self->{HEADER};
}

sub records_cache {
	my ($self) = @_;
	return $self->{RECORDS_CACHE};
}

sub init_header {
	my ($self) = @_;
	$self->{HEADER} = {};
}

sub init_records_cache {
	my ($self) = @_;
	$self->{RECORDS_CACHE} = [];
}

sub init_records_read_count {
	my ($self) = @_;
	$self->{RECORDS_READ_COUNT} = 0;
}

sub increment_records_read_count {
	my ($self) = @_;
	$self->{RECORDS_READ_COUNT}++;
}

sub parse_header_section {
	my ($self) = @_;
	
	my $filehandle = $self->_filehandle;
	while (my $line = $filehandle->getline) {
		if ($self->line_looks_like_header($line)) {
			$self->recognize_and_store_header_line($line);
		}
		elsif ($self->line_looks_like_record($line)) {
			# the while loop will read one line after header. Usually, this is the first record and unfortunately in zipped files we cannot go back
			my $record = $self->parse_record_line($line);
			$self->add_to_records_cache($record); 
			return;
		}
		else {
			return;
		}
	}
}

# TODO fix to store "browser" and "track" lines
sub recognize_and_store_header_line {
	my ($self, $line) = @_;
# 	if ($self->line_looks_like_version($line)) {
# 		$self->parse_and_store_version_line($line);
# 	}
# 	else {
# 		$self->parse_and_store_header_line($line);
# 	}
}

sub add_to_records_cache {
	my ($self, $record) = @_;
	push @{$self->{RECORDS_CACHE}}, $record,
}

sub next_record_from_file {
	my ($self) = @_;
	
	while (my $line = $self->_filehandle->getline) {
		if ($self->line_looks_like_record($line)) {
			return $self->parse_record_line($line);
		}
		else {
			if ($self->line_looks_like_header($line)) {
				die "Record was expected but line looks like a header - the header should have been parsed already. $line\n";
			}
			else {
				warn "Record was expected but line looks different. $line\n";
			}
		}
	}
	
	$self->set_eof_reached;
	return undef;
}

sub next_record_from_cache {
	my ($self) = @_;
	
	my $record = shift @{$self->{RECORDS_CACHE}};
	if (defined $record) {
		return $record;
	}
	else {
		return undef;
	}
}

sub parse_record_line {
	my ($self, $line) = @_;
	
	chomp $line;
	my ($chr,$start,$stop_1,$name,$score,$strand,$thick_start,$thick_stop,$rgb,$block_count,$block_sizes,$block_starts) = split(/\t/,$line);
	
	my $data = {
		rname             => $chr,
		start             => $start,
		stop_1based       => $stop_1,
		name              => $name,
		score             => $score,
		strand_symbol     => $strand,
	};
	
	($data->{copy_number}       = $score) if $self->redirect_score_to_copy_number;
	($data->{thick_start}       = $thick_start) if defined $thick_start;
	($data->{thick_stop_1based} = $thick_stop) if defined $thick_stop;
	($data->{rgb}               = $rgb) if defined $rgb;
	($data->{block_count}       = $block_count) if defined $block_count;
	($data->{block_sizes}       = [split(/,/,$block_sizes)]) if defined $block_sizes;
	($data->{block_starts}      = [split(/,/,$block_starts)]) if defined $block_starts;
	
	return GenOO::Data::File::BED::Record->new($data);
}

sub line_looks_like_comment {
	my ($self, $line) = @_;
	return ($line =~ /^#/) ? 1 : 0;
}

sub line_looks_like_header {
	my ($self, $line) = @_;
	return ($line =~ /^(track|browser)/) ? 1 : 0;
}

sub line_looks_like_record {
	my ($self, $line) = @_;
	return ($line !~ /^(#|track|browser)/) ? 1 : 0;
}

sub record_cache_not_empty {
	my ($self) = @_;
	return ($self->record_cache_size > 0) ? 1 : 0;
}

sub record_cache_is_empty {
	my ($self) = @_;
	return ($self->record_cache_size == 0) ? 1 : 0;
}

sub record_cache_size {
	my ($self) = @_;
	return scalar @{$self->records_cache};
}

sub is_eof_reached {
	my ($self) = @_;
	return $self->{EOF};
}


#######################################################################
#########################   Private Methods   #########################
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


#######################################################################
############################   Finalize   #############################
#######################################################################
__PACKAGE__->meta->make_immutable;

1;
