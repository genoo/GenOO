# POD documentation - main docs before the code

=head1 NAME

MyBio::File::BED - Object implementing mehtods for accessing bed formatted files

=head1 SYNOPSIS

    # Object that manages a bed file. 

    # To initialize 
    my $file = MyBio::File::BED->new({
        TYPE            => undef,
        FILE            => undef,
        EXTRA_INFO      => undef,
    });


=head1 DESCRIPTION

    This object offers functions to read a bed file line by line.

=head1 EXAMPLES

    # Read one line
    my $line = $bed_obj->read_ln();
    
    # Read one entity
    my %entity = %{$bed_obj->read_entity()};

=head1 AUTHOR - Manolis Maragkakis

Email em.maragkakis@gmail.com

=cut

# Let the code begin...

package MyBio::File::BED;
use strict;

use FileHandle;

use base qw(MyBio::_Initializable);

sub _init {
	
	my ($self,$data) = @_;
	
	$self->set_type($$data{TYPE});
	$self->set_file($$data{FILE});
	$self->set_extra($$data{EXTRA_INFO});
	my $filehandle = FileHandle->new($self->get_file, "r") or die "Cannot open file \"".$self->get_file."\"  $!";
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
sub get_comments {
	unless (exists $_[0]->{COMMENTS}) {
		$_[0]->set_comments();
	}
	return $_[0]->{COMMENTS};
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
sub set_comments {
	if (defined $_[1]) {
		$_[0]->{COMMENTS} = $_[1]
	}
	else {
		$_[0]->{COMMENTS} = [];
	}
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
	
	while (1) {
		my $line = $self->readline or return;
		my $entity = $self->line_to_entity($line);
		if (exists $entity->{START}) {
			return $entity;
		}
		elsif (exists $entity->{COMMENT_LINE}) {
			push @{$self->get_comments}, $line;
		}
	}
}

sub line_to_entity {
	my ($self, $line) = @_;
	
	if ($line =~ /^chr/) {
		my ($chr,$start,$stop,$name,$score,$strand,@others) = split(/\t/,$line);
		if (@others) {
			return {
				STRAND        => $strand,
				CHR           => $chr,
				START         => $start,
				STOP          => $stop - 1, #[start,stop)
				NAME          => $name,
				SCORE         => $score,
				THICK_START   => $others[0],
				THICK_STOP    => $others[1],
				RGB           => $others[2],
				BLOCK_COUNT   => $others[3],
				BLOCK_SIZES   => $others[4],
				BLOCK_STARTS  => $others[5],
			};
		}
		else {
			return {
				STRAND        => $strand,
				CHR           => $chr,
				START         => $start,
				STOP          => $stop - 1, #[start,stop)
				NAME          => $name,
				SCORE         => $score,
			};
		}
	}
	elsif ($line =~ /^#/) {
		return {
			COMMENT_LINE => 1,
		}
	}
	else {
		return {};
	}
}

1;
