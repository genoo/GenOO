# POD documentation - main docs before the code

=head1 NAME

MyBio::Data::File::FASTQ - Object implementing mehtods for accessing fastq formatted files

=head1 SYNOPSIS

    # Object that manages a fastq file. 

    # To initialize 
    my $file = MyBio::Data::File::FASTQ->new({
        FILE            => undef,
        EXTRA_INFO      => undef,
    });


=head1 DESCRIPTION

    This object offers methods to read a fastq file entry by entry

=head1 EXAMPLES

    # Read one line
    my $entry = $fasta_parser->next();

=head1 AUTHOR - Manolis Maragkakis

Email em.maragkakis@gmail.com

=cut

# Let the code begin...

package MyBio::Data::File::FASTQ;
use strict;

use FileHandle;

use base qw(MyBio::_Initializable);

sub _init {
	
	my ($self,$data) = @_;
	
	$self->set_file($$data{FILE});
	$self->set_extra($$data{EXTRA_INFO});
	
	my $read_mode = "<";
	if ($self->file =~ /\.gz$/) {
		$read_mode = "<:gzip";
	}
	
	my $filehandle = FileHandle->new($self->file, $read_mode) or die "Cannot open file \"".$self->file."\"  $!";
	$self->_set_filehandle($filehandle);
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub file {
	return $_[0]->{FILE};
}
sub extra {
	return $_[0]->{EXTRA_INFO};
}
sub _filehandle {
	return $_[0]->{FILEHANDLE};
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_file {
	$_[0]->{FILE}=$_[1] if defined $_[1];
}
sub set_extra {
	$_[0]->{EXTRA_INFO}=$_[1] if defined $_[1];
}
sub _set_filehandle {
	$_[0]->{FILEHANDLE}=$_[1] if defined $_[1];
}

#######################################################################
#########################   General Methods   #########################
#######################################################################


sub next {
	my ($self) = @_;
	
	my $filehandle = $self->_filehandle;
	while (my $line = <$filehandle>) {
		if ($line =~ /^\@/) {
			my $id = substr($line,1); chomp($id);
			my $seq = <$filehandle>; chomp($seq);
			my $not_used = <$filehandle>; chomp($not_used);
			my $quality = <$filehandle>; chomp($quality);
			
			return $self->_create_entry($id, $seq, $not_used, $quality);
		}
	}
	return undef;
}

sub _create_entry {
	my ($self, $id, $seq, $not_used, $quality) = @_;
	
	return {
		IDENTIFIER    => $id,
		SEQUENCE      => $seq,
		QUALITY       => $quality,
		ENTRY         => 1,
	};
}

1;
