# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Job::Log::File - Class that implements MyBio::JobGraph::Job::Log interface using a file

=head1 SYNOPSIS

    # Instantiate
    my $log = MyBio::JobGraph::Job::Log::File->new({
        NAME       => 'An identifier',
        FILENAME   => '/path/to/log/file',
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

use MyBio::JobGraph::Data::File;

use base qw(MyBio::_Initializable);

sub _init {
	my ($self,$data) = @_;
	
	$self->set_name($$data{NAME});
	$self->create_source_from_filename($$data{FILENAME});
	$self->open;
	
	return $self;
}

sub DESTROY {
	my $self = shift;
	$self->close;
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_name {
	my ($self,$value) = @_;
	$self->{NAME} = $value if defined $value;
}


#######################################################################
############################   Accessors  #############################
#######################################################################
sub name {
	my ($self) = @_;
	return $self->{NAME};
}

sub source {
	my ($self) = @_;
	return $self->{SOURCE};
}

sub filehandle {
	my ($self) = @_;
	return $self->{FILEHANDLE};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub create_source_from_filename {
	my ($self, $value) = @_;
	
	if (defined $value) {
		$self->{SOURCE} = MyBio::JobGraph::Data::File->new({
			FILENAME => $value,
		});
	}
}

sub open {
	my ($self) = @_;
	
	my $filename = $self->filename;
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
	unlink $self->filename or warn "Source file ".$self->filename." can not be deleted. $!";
}

sub filename {
	my ($self) = @_;
	return $self->source->filename;
}

sub type {
	my ($self) = @_;
	return $self->source->type;
}

sub start_devel_mode {
	my ($self) = @_;
	
	$self->close;
	$self->source->start_devel_mode;
	$self->open;
}

sub stop_devel_mode {
	my ($self) = @_;
	
	$self->close;
	$self->source->stop_devel_mode;
	$self->open;
}

sub is_devel_mode_on { # Override
	my ($self) = @_;
	return $self->source->is_devel_mode_on;
}

1;
