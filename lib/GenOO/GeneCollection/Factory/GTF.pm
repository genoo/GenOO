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

	# An instance of this class is a concrete factory for the creation of a
	# L<GenOO::GeneCollection> containing genes from a GTF file. It offers the
	# method "read_collection" (as the consumed role requires) which returns
	# the actual L<GenOO::GeneCollection> object in the form of
	# L<GenOO::RegionCollection::Type::DoubleHashArray>. The latter is the
	# implementation
	# of the L<GenOO::RegionCollection> class based on the complex data
	# structure L<GenOO::Data::Structure::DoubleHashArray>.

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
	isa => 'Maybe[Str]',
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

	my $genes = $self->_read_gtf($self->file);

	return GenOO::RegionCollection::Factory->create('RegionArray', {
		array => $genes
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
		next unless (($record->feature eq 'exon') or ($record->feature eq 'start_codon') or ($record->feature eq 'stop_codon'));
		my $tid = $record->attribute('transcript_id')
			or die "transcript_id attribute must be defined\n";
		my $gid = $record->attribute('gene_id')
			or die "gene_id attribute must be defined\n";

		if ($record->strand == 0){
			next;
		}

		# Get transcript with id or create a new one. Update coordinates if required
		my $transcript = $transcripts{$tid};
		if (not defined $transcript) {
			$transcript = GenOO::Transcript->new(
				id            => $tid,
				chromosome    => $record->rname,
				strand        => $record->strand,
				start         => $record->start,
				stop          => $record->stop,
				splice_starts => [$record->start], # will be re-written later
				splice_stops  => [$record->stop], # will be re-written later
			);
			$transcripts{$tid} = $transcript;
			$transcript_splice_starts{$tid} = [];
			$transcript_splice_stops{$tid} = [];
			if (!exists $genes{$gid}) {
				$genes{$gid} = [];
			}
			push @{$genes{$gid}}, $transcript;
		}
		else {
			$transcript->start($record->start) if ($record->start < $transcript->start);
			$transcript->stop($record->stop) if ($record->stop > $transcript->stop);
		}

		if ($record->feature eq 'exon') {
			push @{$transcript_splice_starts{$tid}}, $record->start;
			push @{$transcript_splice_stops{$tid}}, $record->stop;
		}
		elsif ($record->feature eq 'start_codon') {
			if ($record->strand == 1 and
				(!defined $transcript->coding_start or
				$record->start < $transcript->coding_start)) {

				$transcript->coding_start($record->start);
			}
			elsif ($record->strand == -1 and
				(!defined $transcript->coding_stop or
				$record->stop > $transcript->coding_stop)) {

				$transcript->coding_stop($record->stop);
			}
		}
		elsif ($record->feature eq 'stop_codon') {
			if ($record->strand == 1 and
				(!defined $transcript->coding_stop or
				$record->stop > $transcript->coding_stop)) {

				$transcript->coding_stop($record->stop);
			}
			elsif ($record->strand == -1 and
				(!defined $transcript->coding_start or
				$record->start < $transcript->coding_start)) {

				$transcript->coding_start($record->start);
			}
		}
	}

	foreach my $tid (keys %transcripts) {
		$transcripts{$tid}->set_splice_starts_and_stops(
			$transcript_splice_starts{$tid}, $transcript_splice_stops{$tid});
	}

	my @genes;
	GENE: foreach my $gid (keys %genes) {
		my $gene = GenOO::Gene->new(name => $gid);
		my @gene_transcripts = sort {$a->start <=> $b->start} @{$genes{$gid}};
		my $tr = shift @gene_transcripts;
		$gene->add_transcript($tr);
		$tr->gene($gene);
		foreach $tr (@gene_transcripts) {
			# if transcrpt doesn't overlap previous ones then skip the gene.
			if (!$gene->overlaps($tr)) {
				next GENE;
			}
			$gene->add_transcript($tr);
			$tr->gene($gene);
		}
		push @genes, $gene;
	}

	return \@genes;
}

1;
