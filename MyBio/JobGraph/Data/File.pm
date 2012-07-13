# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Data::File - Output file object that implements MyBio::JobGraph::Data interface

=head1 SYNOPSIS

    # Instantiate
    my $output = MyBio::JobGraph::Data::File->new({
        NAME       => 'An identifier',
        FILENAME     => '/path/to/output/file',
        DEVEL      => BOOLEAN
    });

=head1 DESCRIPTION

    This class handles a file as an output for a job. It offers methods for transforming the into
    a temporary development output file and for cleaning the file when done.

=head1 EXAMPLES

    # Start development mode. Sets output into a temporary development file
    $output->start_devel_mode
    
    # Delete the development file
    $output->clean
    
    # Stop development mode. Sets output into the original file
    $output->stop_devel_mode
    
    # Delete the original output file
    $output->clean

=cut

# Let the code begin...

package MyBio::JobGraph::Data::File;
use strict;

use base qw(MyBio::JobGraph::Data);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	$self->set_filename($$data{FILENAME});
	$self->set_original_filename($$data{FILENAME});
	
	return $self;
}


#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_filename {
	my ($self,$value) = @_;
	$self->{FILENAME} = $value if defined $value;
}

sub set_original_filename {
	my ($self,$value) = @_;
	$self->{ORIGINAL_FILENAME} = $value if defined $value;
}

#######################################################################
############################   Accessors  #############################
#######################################################################
sub filename {
	my ($self) = @_;
	return $self->{FILENAME};
}

sub original_filename {
	my ($self) = @_;
	return $self->{ORIGINAL_FILENAME};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub type { # override
	my ($self) = @_;
	return 'File';
}

sub clean { # override
	my ($self) = @_;
	unlink $self->filename or warn "File can not be deleted. $!";
}

sub start_devel_mode { # override
	my ($self) = @_;
	
	$self->set_filename_to_devel;
	$self->set_devel_mode(1);
}

sub stop_devel_mode { # override
	my ($self) = @_;
	
	$self->set_filename_to_original;
	$self->set_devel_mode(0);
}

sub set_filename_to_devel {
	my ($self) = @_;
	
	my ($volume, $directories, $file) = File::Spec->splitpath($self->original_filename);
	
	my $dev_file = 'dev_'.$file;
	my $dev_filename = File::Spec->catpath($volume, $directories, $dev_file);
	$self->set_filename($dev_filename);
}

sub set_filename_to_original {
	my ($self) = @_;
	$self->set_filename($self->original_filename);
}

1;
