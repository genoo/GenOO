# POD documentation - main docs before the code

=head1 NAME

MyBio::Data::File::GFF - Object implementing methods for accessing gff formatted files (http://www.sanger.ac.uk/resources/software/gff/spec.html)

=head1 SYNOPSIS

    # Object that manages a gff file. 

    # To initialize 
    my $gff_file = MyBio::Data::File::GFF->new({
        FILE            => undef,
        EXTRA_INFO      => undef,
    });


=head1 DESCRIPTION

    This object offers methods to read a gff file line by line.

=head1 EXAMPLES

    # Create object
    my $gff_file = MyBio::Data::File::GFF->new({
          FILE => 't/sample_data/sample.gff.gz'
    });
    
    # Read one record at a time
    my $record = $gff_file->next_record();

=head1 AUTHOR - Manolis Maragkakis

Email em.maragkakis@gmail.com

=cut

# Let the code begin...

package MyBio::Data::File::GFF;
use strict;
use FileHandle;

use MyBio::Data::File::GFF::Record;

use base qw(MyBio::_Initializable);

our $VERSION = '1.0';

sub _init {
	my ($self,$data) = @_;
	
	$self->set_file($$data{FILE});
	$self->set_extra($$data{EXTRA_INFO});
	
	$self->open($self->file);
	
	$self->init_header;
	$self->init_records_cache;
	$self->init_records_read_count;
	
	$self->parse_header_section;
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

sub set_eof {
	my ($self) = @_;
	$self->{EOF} = 1;
}
#######################################################################
########################   Attribute Getters   ########################
#######################################################################
sub file {
	my ($self) = @_;
	return $self->{FILE};
}

sub eof {
	my ($self) = @_;
	return $self->{EOF};
}

#######################################################################
############################   Accessors   ############################
#######################################################################
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

sub version {
	my ($self) = @_;
	return $self->header->{VERSION};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
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
			$self->add_to_records_cache($line); # unfortunatelly the while reads the first line after the header section and in zipped files we cannot go back
			return;
		}
	}
}

sub recognize_and_store_header_line {
	my ($self, $line) = @_;
	if ($self->line_looks_like_version($line)) {
		$self->parse_and_store_version_line($line);
		
	}
	else {
		$self->parse_and_store_generic_header_line($line);
	}
}

sub add_to_records_cache {
	my ($self, $line) = @_;
	push @{$self->{RECORDS_CACHE}}, $line,
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
		elsif ($self->line_looks_like_header) {
			die "A record was expected but line looks like a header - the header should have been parsed already. $line\n";
		}
	}
	
	$self->set_eof; # When you reach this point the file has finished
	return undef;
}

sub next_record_from_cache {
	my ($self) = @_;
	
	my $line = shift @{$self->{RECORDS_CACHE}};
	if (defined $line) {
		return $self->parse_record_line($line);
	}
	else {
		return undef;
	}
}

sub parse_record_line {
	my ($self, $line) = @_;
	
	chomp $line;
	$line =~ s/(#.+)$//;
	my $comment_string = $1;
	my ($seqname, $source, $feature, $start, $end, $score, $strand, $frame, $attributes_string) = split(/\t/,$line);
	my @attributes = split(/;\s*/,$attributes_string);
	
	return MyBio::Data::File::GFF::Record->new({
		SEQNAME     => $seqname,
		SOURCE      => $source,
		FEATURE     => $feature,
		START_1     => $start, # 1-based
		STOP_1      => $end, # 1-based
		SCORE       => $score,
		STRAND      => $strand,
		FRAME       => $frame,
		ATTRIBUTES  => \@attributes,
		COMMENT     => $comment_string,
	});
}

sub parse_and_store_version_line {
	my ($self, $line) = @_;
	
	my $version = (split(/\s+/,$line))[1];
	$self->header->{VERSION} = $version;
}

sub parse_and_store_generic_header_line {
	my ($self, $line) = @_;
	
	my ($key,@values) = split(/\s+/,$line);
	$self->header->{$key} = join(' ',@values);
}

sub line_looks_like_comment {
	my ($self, $line) = @_;
	return ($line !~ /^#{2}/) ? 1 : 0;
}

sub line_looks_like_header {
	my ($self, $line) = @_;
	return ($line =~ /^#{2}/) ? 1 : 0;
}

sub line_looks_like_record {
	my ($self, $line) = @_;
	return ($line !~ /^#/) ? 1 : 0;
}

sub line_looks_like_version {
	my ($self, $line) = @_;
	return ($line =~ /^##gff-version/) ? 1 : 0;
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

1;
