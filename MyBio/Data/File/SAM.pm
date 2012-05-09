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

    # Read one line
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

use base qw(MyBio::_Initializable);

our $VERSION = '1.0';

sub _init {
	my ($self,$data) = @_;
	
	$self->set_file($$data{FILE});
	$self->set_extra($$data{EXTRA_INFO});
	
	$self->open($self->get_file);
	
	$self->init_header_cache;
	$self->init_records_cache;
	
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
	return $self->{FILE}=$value if defined $value;
}

#######################################################################
########################   Attribute Getters   ########################
#######################################################################
sub get_file {
	my ($self) = @_;
	return $self->{FILE};
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
	return $self->{HEADER_CACHE}
}

sub records_cache {
	my ($self) = @_;
	return $self->{RECORDS_CACHE}
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
	
	if ($self->record_cache_not_empty) {
		return $self->get_next_record_from_cache;
	}
	else {
		return $self->get_next_record_from_file;
	}
}

sub get_next_record_from_file {
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
		return undef;
	}
}

sub get_next_record_from_cache {
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
	my ($qname, $flag, $rname, $pos, $mapq, $cigar, $mrnm, $mpos, $isize, $read, $qual) = split("\t",$line);
	if ($flag & 4) {return {};} # Unmapped read
	my $strand = ($flag & 16) ? '-' : '+';
	
	return {
		NAME          => $qname,
		CHR           => $rname,
		STRAND        => $strand,
		START         => $pos - 1, # convert position from one-based to zero-based
		STOP          => $pos - 1 + length($read) -1, # convert position from one-based to zero-based.
		FLAG          => $flag,
		CIGAR         => $cigar,
		SEQUENCE      => $read,
		SCORE         => $mapq,
		LOCUS         => 1,
	};
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
