# POD documentation - main docs before the code

=head1 NAME

MyBio::JobGraph::Job::Output::File - Output file object that implements MyBio::JobGraph::Job::Output interface

=head1 SYNOPSIS

    # Instantiate
    my $output = MyBio::JobGraph::Job::Output::File->new({
        NAME       => 'An identifier',
        SOURCE     => '/path/to/output/file',
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

package MyBio::JobGraph::Job::Output::File;
use strict;

use base qw(MyBio::JobGraph::Job::Output);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	
	return $self;
}

#######################################################################
############################   Accessors  #############################
#######################################################################
sub type {
	my ($self) = @_;
	return 'File';
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub clean {
	my ($self) = @_;
	unlink $self->source or warn "Source file can not be deleted. $!";
}

sub start_devel_mode {
	my ($self) = @_;
	
	$self->set_source_to_devel;
	$self->{DEVEL} = 1;
}

sub stop_devel_mode {
	my ($self) = @_;
	
	$self->set_source_to_original;
	$self->{DEVEL} = 0;
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
