# POD documentation - main docs before the code

=head1 NAME

MyBio::Data::File::SAM - Object implementing methods for accessing sam formatted files

=head1 SYNOPSIS

    # Object that manages a sam file. 

    # To initialize 
    my $sam_file = MyBio::Data::File::SAM->new({
        FILE            => undef,
        EXTRA_INFO      => undef,
    });


=head1 DESCRIPTION

    This object offers methods to read a sam file line by line.

=head1 EXAMPLES

    # Create object
    my $sam_file = MyBio::Data::File::SAM->new({
          FILE => 't/sample_data/sample.sam.gz'
    });
    
    # Read one record at a time
    my $sam_record = $sam_file->next_record();

=head1 AUTHOR - Manolis Maragkakis

Email em.maragkakis@gmail.com

=cut

# Let the code begin...

package MyBio::Data::File::SAM;
use strict;
use FileHandle;

use MyBio::Data::File::SAM::Record;

use base qw(MyBio::_Initializable);

our $VERSION = '1.0';

sub _init {
	my ($self,$data) = @_;
	
	$self->set_file($$data{FILE});
	$self->set_extra($$data{EXTRA_INFO});
	
	$self->open($self->file);
	
	$self->init_header_cache;
	$self->init_records_cache;
	$self->init_records_read_count;
	
	$self->parse_header_section;
}

sub open {
	my ($self, $filename) = @_;
	
	my @open_args;
	if (!defined $filename or $filename eq '-') {
		@open_args = ('<-'); # opens the STDIN see http://perldoc.perl.org/functions/open.html
	}
	elsif ($filename =~ /\.gz$/) {
		@open_args = ($filename, '<:gzip');
	}
	else {
		@open_args = ($filename, '<');
	}
	$self->{FILEHANDLE} = FileHandle->new(@open_args) or die "Cannot open file \"$filename\". $!";
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

sub header_cache {
	my ($self) = @_;
	return $self->{HEADER_CACHE};
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
sub init_header_cache {
	my ($self) = @_;
	$self->{HEADER_CACHE} = [];
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
		if ($line =~ /^\@/) {
			$self->add_to_header_cache($line);
		}
		else {
			$self->add_to_records_cache($line); # unfortunatelly the while reads the first line after the header section and in zipped files we cannot go back
			return;
		}
	}
}

sub add_to_header_cache {
	my ($self, $line) = @_;
	push @{$self->{HEADER_CACHE}}, $line,
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
	
	my $line = $self->filehandle->getline;
	if (defined $line) {
		if ($line !~ /^\@/) {
			return $self->parse_record_line($line);
		}
		else {
			die "A record is requested but the line looks like a header - header section should have been parsed. $line\n";
		}
	}
	else {
		$self->set_eof;
		return undef;
	}
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
	my ($self,$line) = @_;
	
	chomp $line;
	my ($qname, $flag, $rname, $pos, $mapq, $cigar, $rnext, $pnext, $tlen, $seq, $qual, @tags) = split(/\t/,$line);
	
	return MyBio::Data::File::SAM::Record->new({
		QNAME      => $qname,
		FLAG       => $flag,
		RNAME      => $rname,
		POS        => $pos,
		MAPQ       => $mapq,
		CIGAR      => $cigar,
		RNEXT      => $rnext,
		PNEXT      => $pnext,
		TLEN       => $tlen,
		SEQ        => $seq,
		QUAL       => $qual,
		TAGS       => \@tags,
	});
}

sub next_header_line {
	my ($self) = @_;
	
	my $record;
	if ($self->header_cache_not_empty) {
		return $self->next_header_line_from_cache;
	}
	else {
		return undef;
	}
}

sub next_header_line_from_cache {
	my ($self) = @_;
	
	my $line = shift @{$self->header_cache};
	chomp ($line);
	return $line;
}

sub record_cache_not_empty {
	my ($self) = @_;
	
	if ($self->record_cache_size > 0) {
		return 1;
	}
	else {
		return 0;
	}
}

sub header_cache_not_empty {
	my ($self) = @_;
	
	if ($self->header_cache_size > 0) {
		return 1;
	}
	else {
		return 0;
	}
}

sub record_cache_is_empty {
	my ($self) = @_;
	
	if ($self->record_cache_size > 0) {
		return 0;
	}
	else {
		return 1;
	}
}

sub header_cache_is_empty {
	my ($self) = @_;
	
	if ($self->header_cache_size > 0) {
		return 0;
	}
	else {
		return 1;
	}
}

sub record_cache_size {
	my ($self) = @_;
	return scalar @{$self->records_cache};
}

sub header_cache_size {
	my ($self) = @_;
	return scalar @{$self->header_cache};
}

1;
