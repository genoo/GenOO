# POD documentation - main docs before the code

=head1 NAME

MyBio::Data::File::FASTA - Object implementing methods for accessing fasta formatted files (http://genome.ucsc.edu/FAQ/FAQformat#format1)

=head1 SYNOPSIS

    # Object that manages a fasta file. 

    # To initialize 
    my $fasta_file = MyBio::Data::File::FASTA->new({
        FILE            => undef,
        EXTRA_INFO      => undef,
    });

=head1 DESCRIPTION

    This object offers methods to read a fasta file line by line.

=head1 EXAMPLES

    # Create object
    my $fasta_file = MyBio::Data::File::FASTA->new({
          FILE => 't/sample_data/sample.fasta.gz'
    });
    
    # Read one record at a time
    my $record = $fasta_file->next_record();

=cut

# Let the code begin...

package MyBio::Data::File::FASTA;
use strict;
use FileHandle;

use MyBio::Data::File::FASTA::Record;

use base qw(MyBio::_Initializable);

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

sub record_header_cache {
	my ($self) = @_;
	return $self->{RECORD_HEADER_CACHE};
}

sub record_seq_cache {
	my ($self) = @_;
	return $self->{SEQUENCE};
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
	
	$self->init_record_header_cache;
	$self->init_seq_cache;
	$self->init_records_read_count;
	
}

sub init_record_header_cache {
	my ($self) = @_;
	delete $self->{RECORD_HEADER_CACHE};
}

sub init_seq_cache {
	my ($self) = @_;
	delete $self->{SEQUENCE};
}

sub init_records_read_count {
	my ($self) = @_;
	$self->{RECORDS_READ_COUNT} = 0;
}

sub increment_records_read_count {
	my ($self) = @_;
	$self->{RECORDS_READ_COUNT}++;
}

sub set_record_header_cache {
	my ($self, $record_header) = @_;
	$self->{RECORD_HEADER_CACHE} = $record_header;
}

sub add_to_seq_cache {
	my ($self, $sequence) = @_;
	$self->{SEQUENCE} .= $sequence;
}

sub next_record {
	my ($self) = @_;
	
	if ($self->is_eof_reached) {
		return undef;
	}
	
	while (my $line = $self->filehandle->getline) {
		chomp $line;
		if ($self->line_looks_like_record_header($line)) {
			if ($self->record_header_cache_not_empty) {
				$self->increment_records_read_count;
				my $record = $self->create_record;
				$self->set_record_header_cache($line);
				return $record;
			}
			else {
				$self->set_record_header_cache($line);
			}
		}
		elsif ($self->line_looks_like_sequence($line)) {
			$self->add_to_seq_cache($line);
		}
	}
	$self->set_eof_reached;
	$self->increment_records_read_count;
	return $self->create_record;
}

sub create_record {
	my ($self) = @_;
	
	my $record = MyBio::Data::File::FASTA::Record->new({
		HEADER   => $self->record_header_cache,
		SEQUENCE => $self->record_seq_cache,
	});
	$self->init_record_header_cache;
	$self->init_seq_cache;
	
	return $record;
}

sub line_looks_like_record_header {
	my ($self, $line) = @_;
	return ($line =~ /^>/) ? 1 : 0;
}

sub line_looks_like_sequence {
	my ($self, $line) = @_;
	return ((!$self->line_looks_like_record_header($line)) and ($line =~ /\S/)) ? 1 : 0;
}

sub record_header_cache_not_empty {
	my ($self) = @_;
	return (defined $self->record_header_cache) ? 1 : 0;
}

sub record_header_cache_is_empty {
	my ($self) = @_;
	return (!defined $self->record_header_cache) ? 1 : 0;
}

sub is_eof_reached {
	my ($self) = @_;
	return defined $self->{EOF} ? 1 : 0;
}

1;
