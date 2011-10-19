# POD documentation - main docs before the code

=head1 NAME

MyBio::File::SAM - Object implementing mehtods for accessing sam formatted files

=head1 SYNOPSIS

    # Object that manages a sam file. 

    # To initialize 
    my $file = MyBio::File::SAM->new({
        TYPE            => undef,
        FILE            => undef,
        EXTRA_INFO      => undef,
    });


=head1 DESCRIPTION

    This object offers functions to read a sam file line by line.

=head1 EXAMPLES

    # Read one line
    my $line = $sam_obj->readline();
    
    # Read one entity
    my %entity = %{$sam_obj->next_entity()};

=head1 AUTHOR - Manolis Maragkakis

Email em.maragkakis@gmail.com

=cut

# Let the code begin...

package MyBio::File::SAM;
use strict;

use FileHandle;

use base qw(MyBio::_Initializable);

sub _init {
	
	my ($self,$data) = @_;
	
	$self->set_type($$data{TYPE});
	$self->set_file($$data{FILE});
	$self->set_extra($$data{EXTRA_INFO});
	
	my $read_mode = "<";
	if ($self->get_file =~ /\.gz$/) {
		$read_mode = "<:gzip";
	}
	
	my $filehandle = FileHandle->new($self->get_file, $read_mode) or die "Cannot open file \"".$self->get_file."\"  $!";
	$self->set_filehandle($filehandle);
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_type {
	return $_[0]->{TYPE};
}
sub get_file {
	return $_[0]->{FILE};
}
sub get_filehandle {
	return $_[0]->{FILEHANDLE};
}
sub get_extra {
	return $_[0]->{EXTRA_INFO};
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_type {
	$_[0]->{TYPE}=$_[1] if defined $_[1];
}
sub set_file {
	$_[0]->{FILE}=$_[1] if defined $_[1];
}
sub set_filehandle {
	$_[0]->{FILEHANDLE}=$_[1] if defined $_[1];
}
sub set_extra {
	$_[0]->{EXTRA_INFO}=$_[1] if defined $_[1];
}

#######################################################################
#########################   General Methods   #########################
#######################################################################

sub readline {
	my ($self) = @_;
	
	my $fh = $self->get_filehandle or return;
	my $line = <$fh>;
	chomp($line);
	return $line;
}

sub next_entity {
	my ($self) = @_;
	
	my $line = $self->readline or return;
	return $self->line_to_entity($line);
}

sub line_to_entity {
	my ($self, $line) = @_;
	
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
	};
}

1;
