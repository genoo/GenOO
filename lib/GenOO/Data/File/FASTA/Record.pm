# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::File::FASTA::Record - Object representing a record of a fasta file

=head1 SYNOPSIS

    # Object representing a record of a fasta file 

    # To initialize 
    my $record = GenOO::Data::File::FASTA::Record->new({
        HEADER          => undef,
        SEQUENCE        => undef,
    });


=head1 DESCRIPTION

    This object represents a record of a fasta file and offers methods for accessing the different attributes.

=head1 EXAMPLES
    
    my $sequence = $record->sequence();
    
=cut

# Let the code begin...

package GenOO::Data::File::FASTA::Record;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Modern::Perl;
use autodie;
use Moose;
use namespace::autoclean;


#######################################################################
#######################   Interface attributes   ######################
#######################################################################
has 'header' => (
	isa      => 'Str',
	is       => 'ro',
	required => 1
);

has 'sequence' => (
	isa      => 'Str',
	is       => 'ro',
	required => 1
);


#######################################################################
##############################   BUILD   ##############################
#######################################################################
around BUILDARGS => sub {
	my ($orig, $class) = @_;
	
	my $argv_hash_ref = $class->$orig(@_);
	
	if (exists $argv_hash_ref->{header}) {
		my $header = $argv_hash_ref->{header};
		$header =~ s/^>//;
		$argv_hash_ref->{header} = $header
	}
	
	return $argv_hash_ref;
};


#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub length {
	my ($self) = @_;
	return length($self->sequence);
}

sub to_string {
	my ($self) = @_;
	
	return join("\n",(
		'>'.$self->header,
		$self->sequence,
	));
}

#######################################################################
############################   Finalize   #############################
#######################################################################
__PACKAGE__->meta->make_immutable;

1;
