# POD documentation - main docs before the code

=head1 NAME

GenOO::GeneCollection::Factory::GTF - Factory to create GeneCollection from a GTF file

=head1 SYNOPSIS

Creates GenOO::GeneCollection containing genes from a GTF file 
Preferably use it through the generic GenOO::GeneCollection::Factory

    my $factory = GenOO::GeneCollection::Factory->new('GTF',{
        file => 'sample.gtf'
    });

=head1 DESCRIPTION

    An instance of this class is a concrete factory for the creation of a 
    L<GenOO::GeneCollection> containing genes from a GTF file. It offers the method 
    "read_collection" (as the consumed role requires) which returns the actual
    L<GenOO::GeneCollection> object in the form of 
    L<GenOO::RegionCollection::Type::DoubleHashArray>. The latter is the implementation
    of the L<GenOO::RegionCollection> class based on the complex data structure
    L<GenOO::Data::Structure::DoubleHashArray>.

=head1 EXAMPLES

    # Create a concrete factory
    my $factory_implementation = GenOO::GeneCollection::Factory->new('GTF',{
        file => 'sample.gtf'
    });
    
    # Return the actual GenOO::GeneCollection object
    my $collection = $factory_implementation->read_collection;
    print ref($collection) # GenOO::GeneCollection::Type::DoubleHashArray

=cut

# Let the code begin...

package GenOO::GeneCollection::Factory::GTF;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Modern::Perl;
use autodie;
use Moose;
use namespace::autoclean;


#######################################################################
#######################   Load GenOO modules      #####################
#######################################################################
use GenOO::RegionCollection::Factory;
use GenOO::Transcript;
use GenOO::Gene;
use GenOO::Data::File::GFF;


#######################################################################
#######################   Interface attributes   ######################
#######################################################################
has 'file' => (
	isa => 'Str', 
	is  => 'ro'
);


#######################################################################
##########################   Consumed Roles   #########################
#######################################################################
with 'GenOO::RegionCollection::Factory::Requires';


#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub read_collection {
	my ($self) = @_;
	
	my @genes = $self->_read_gtf($self->file);
	
	return GenOO::RegionCollection::Factory->create('RegionArray', {
		array => \@genes
	})->read_collection;
}

#######################################################################
#########################   Private methods  ##########################
#######################################################################
sub _read_gtf {
	my ($self, $file)=@_;
	
	my %transcripts;
	my %transcript_splice_starts;
	my %transcript_splice_stops;
	my %genes;
	
	my $gff = GenOO::Data::File::GFF->new(file => $file);
	
	while (my $record = $gff->next_record){

		my $transcript_id = $record->attribute('transcript_id') or die "transcript_id attribute must be defined\n";
		my $gene_id = $record->attribute('gene_id') or die "gene_id attribute must be defined\n";
		
		if ($record->strand == 0){
			warn "Skipping transcript $transcript_id: strand symbol". $record->strand_symbol." not accepted\n";
			next;
		}
		
		# Get transcript with id or create a new one. Update coordinates if required
		my $transcript = $transcripts{$transcript_id};
		if (not defined $transcript) {
			$transcript = GenOO::Transcript->new(
				id            => $transcript_id,
				chromosome    => $record->rname,
				strand        => $record->strand,
				start         => $record->start,
				stop          => $record->stop,
				splice_starts => [$record->start], # will be re-written later
				splice_stops  => [$record->stop], # will be re-written later
			);
			$transcripts{$transcript_id} = $transcript;
			if (!exists $genes{$gene_id}){
				my $gene = GenOO::Gene->new(name => $gene_id);
				$genes{$gene_id} = $gene;
			}
			$transcript->gene($genes{$gene_id});
			$genes{$gene_id}->add_transcript($transcript);
			$transcript_splice_starts{$transcript_id} = [];
			$transcript_splice_stops{$transcript_id} = [];
		}
		else {
			if ($record->start < $transcript->start) {
				$transcript->start($record->start);
			}
			if ($record->stop > $transcript->stop) {
				$transcript->stop($record->stop);
			}
		}
		
		if ($record->feature eq 'exon') {
			push @{$transcript_splice_starts{$transcript_id}}, $record->start;
			push @{$transcript_splice_stops{$transcript_id}}, $record->stop;
		}
		elsif ($record->feature eq 'start_codon') {
			if ($record->strand eq '+') {
				$transcript->coding_start($record->start);
			}
			elsif ($record->strand eq '-') {
				$transcript->coding_stop($record->stop);
			}
		}
		elsif ($record->feature eq 'stop_codon') {
			if ($record->strand eq '+') {
				$transcript->coding_stop($record->stop);
			}
			elsif ($record->strand eq '-') {
				$transcript->coding_start($record->start);
			}
		}
	}
	
	foreach my $transcript_id (keys %transcripts) {
		$transcripts{$transcript_id}->set_splice_starts_and_stops($transcript_splice_starts{$transcript_id}, $transcript_splice_stops{$transcript_id});
	}
	
	return values %genes;
}

1;
