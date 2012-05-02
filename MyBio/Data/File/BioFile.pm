# POD documentation - main docs before the code

=head1 NAME

MyBio::Data::File::BioFile - Object that acts as an accessor for biology related files eg BED, FASTA ...

=head1 SYNOPSIS

    # Object that based on the type of file provided returns the correct file accessor object

    # To initialize 
    my $file_obj = MyBio::Data::File::BioFile->new({
        TYPE            => undef,
    });


=head1 DESCRIPTION

    It returns a blessed file accessor object of the correspoding type requested.

=head1 EXAMPLES

    # Read tracks from a file in BED format
    my $filobj = MyBio::Data::File::BioFile->new({TYPE => "BED"});
    
=head1 AUTHOR - Manolis Maragkakis

Email em.maragkakis@gmail.com

=cut

# Let the code begin...

package MyBio::Data::File::BioFile;
use strict;

sub new {
	
	my ($self,$data) = @_;
	
	my $type = $$data{TYPE};

	# normalize capitalization
	return undef unless( &_load_format_module($type) );
	return "MyBio::Data::File::$type"->new($data);
}


#######################################################################
#########################   General Methods   #########################
#######################################################################

=head2 _load_format_module

 Title   : _load_format_module
 Usage   : *INTERNAL SeqIO stuff*
 Function: Loads up (like use) a module at run time on demand
 Example :
 Returns :
 Args    :

=cut
sub _load_format_module {
	my ($format) = @_;
	my ($module, $load, $m);

	$module = "_<Bio/SeqIO/$format.pm";
	$load = "MyBio/File/$format.pm";

	return 1 if $main::{$module};
	eval {
		require $load;
	};
	if ( $@ ) {
		warn "$load: $format cannot be found. $@\n";
		return;
	}
	return 1;

}

1;
