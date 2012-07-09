# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Job::Log::File - Class that implements MyBio::JobGraph::Job::Log interface using a file

=head1 SYNOPSIS

    # Instantiate
    my $log = MyBio::JobGraph::Job::Log::File->new({
        NAME       => 'An identifier',
        SOURCE     => '/path/to/log/file',
        DEVEL      => BOOLEAN
    });

=head1 DESCRIPTION

    This class handles a file as a logging mechanism for a job. It offers methods for transforming the file into
    a temporary development log file and for cleaning the file if asked.

=head1 EXAMPLES

    # Append a message to log
    $log->append('Job died with error code 124');
    
    # Start development mode. Sets log into a temporary development file
    $log->start_devel_mode;
    
    # Delete the development file
    $log->clean;
    
    # Stop development mode. Sets log into the original file
    $log->stop_devel_mode;
    
    # Delete the original log file
    $log->clean;

=cut

# Let the code begin...

package MyBio::JobGraph::Job::Log::File;
use strict;
use FileHandle;

use base qw(MyBio::JobGraph::Job::Log);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	$self->open;
	
	return $self;
}

sub DESTROY {
	my $self = shift;
	$self->close;
}

#######################################################################
############################   Accessors  #############################
#######################################################################
sub filehandle {
	my ($self) = @_;
	return $self->{FILEHANDLE};
}

sub type {
	my ($self) = @_;
	return 'File';
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub open {
	my ($self) = @_;
	
	my $filename = $self->source;
	my $read_mode = ($filename !~ /\.gz$/) ? '>>' : '>>:gzip';
	$self->{FILEHANDLE} = FileHandle->new($filename, $read_mode) or die "Cannot open file \"$filename\". $!";
}

sub close {
	my ($self) = @_;
	$self->filehandle->close if $self->filehandle;
}

sub append {
	my ($self, $message) = @_;
	
	my $OUT = $self->filehandle;
	print $OUT $message."\n";
}

sub clean {
	my ($self) = @_;
	
	$self->close;
	unlink $self->source or warn "Source file ".$self->source." can not be deleted. $!";
}

sub start_devel_mode {
	my ($self) = @_;
	
	$self->close;
	$self->set_source_to_devel;
	$self->{DEVEL} = 1;
	$self->open;
}

sub stop_devel_mode {
	my ($self) = @_;
	
	$self->close;
	$self->set_source_to_original;
	$self->{DEVEL} = 0;
	$self->open;
}

sub set_source_to_devel {
	my ($self) = @_;
	
	my ($volume, $directories, $file) = File::Spec->splitpath($self->original_source);
	
	my $dev_file = 'dev_'.$file;
	my $dev_source = File::Spec->catpath($volume, $directories, $dev_file);
	$self->set_source($dev_source);
}

sub set_source_to_original {
	my ($self) = @_;
	$self->set_source($self->original_source);
}

sub is_devel_mode_on {
	my ($self) = @_;
	return $self->{DEVEL} == 1 ? 1 : 0;
}

1;
