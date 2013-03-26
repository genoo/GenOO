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

# Load external modules
use Modern::Perl;
use autodie;
use Moose;
use namespace::autoclean;


#######################################################################
############################   Attributes   ###########################
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

around BUILDARGS => sub {
	my ($orig, $class) = @_;
	
	my $argv_hash_ref = $class->$orig(@_);
	
	if (exists $argv_hash_ref->{HEADER}) {
		$argv_hash_ref->{header} = delete $argv_hash_ref->{HEADER};
		warn 'Deprecated use of "HEADER" in '.__PACKAGE__.' constructor. Use "header" instead.'."\n";
	}
	if (exists $argv_hash_ref->{SEQUENCE}) {
		$argv_hash_ref->{sequence} = delete $argv_hash_ref->{SEQUENCE};
		warn 'Deprecated use of "SEQUENCE" in '.__PACKAGE__.' constructor. Use "sequence" instead.'."\n";
	}
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

1;
