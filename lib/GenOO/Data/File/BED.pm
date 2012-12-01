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
use strict;
use FileHandle;

use GenOO::Data::File::BED::Record;

use base qw(GenOO::_Initializable);

our $VERSION = '1.0';

sub _init {
	my ($self,$data) = @_;
	
	$self->set_file($$data{FILE});
	$self->set_extra($$data{EXTRA_INFO});
	
	$self->init;
}

sub open {
	my ($self, $filename) = @_;
	
	my $read_mode = ($filename !~ /\.gz$/) ? '<' : '<:gzip';
	$self->{FILEHANDLE} = FileHandle->new($filename, $read_mode) or die "Cannot open file \"$filename\". $!";
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_file {
	my ($self, $value) = @_;
	$self->{FILE} = $value if defined $value;
}

sub set_eof_reached {
	my ($self) = @_;
	$self->{EOF} = 1;
}

#######################################################################
############################   Accessors   ############################
#######################################################################
sub file {
	my ($self) = @_;
	return $self->{FILE};
}

sub filehandle {
	my ($self) = @_;
	return $self->{FILEHANDLE};
}

sub header {
	my ($self) = @_;
	return $self->{HEADER};
}

sub records_cache {
	my ($self) = @_;
	return $self->{RECORDS_CACHE};
}

sub records_read_count {
	my ($self) = @_;
	return $self->{RECORDS_READ_COUNT};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub init {
	my ($self) = @_;
	$self->open($self->file);
	
	$self->init_header;
	$self->init_records_cache;
	$self->init_records_read_count;
	
	$self->parse_header_section;
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
	
	my $filehandle = $self->filehandle;
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
# 		
# 	}
# 	else {
# 		$self->parse_and_store_header_line($line);
# 	}
}

sub add_to_records_cache {
	my ($self, $record) = @_;
	push @{$self->{RECORDS_CACHE}}, $record,
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

sub next_record_from_file {
	my ($self) = @_;
	
	while (my $line = $self->filehandle->getline) {
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

1;
