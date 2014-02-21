# POD documentation - main docs before the code

=head1 NAME

GenOO::RegionCollection::Factory::GTF - Factory for creating a TranscriptCollection with transcripts from a GTF file

=head1 SYNOPSIS

    # Creates GenOO::TranscriptnCollection containing transcripts from a GTF file 

    # Preferably use it through the generic GenOO::TranscriptCollection::Factory
    my $factory = GenOO::TranscriptCollection::Factory->new('GTF',
        {
            file => 'sample.gtf'
        }
    );

=head1 DESCRIPTION

    An instance of this class is a concrete factory for the creation of a 
    L<GenOO::TranscriptCollection> containing transcripts from a GTF file. It offers the method 
    "read_collection" (as the consumed role requires) which returns the actual
    L<GenOO::TranscriptCollection> object in the form of 
    L<GenOO::RegionCollection::Type::DoubleHashArray>. The latter is the implementation
    of the L<GenOO::RegionCollection> class based on the complex data structure
    L<GenOO::Data::Structure::DoubleHashArray>.

=head1 EXAMPLES

    # Create a concrete factory
    my $factory_implementation = GenOO::TranscriptCollection::Factory->new('GTF',
        {
            file => 'sample.gtf'
        }
    );
    
    # Return the actual GenOO::RegionCollection object
    my $collection = $factory_implementation->read_collection;
    print ref($collection) # GenOO::RegionCollection::Type::DoubleHashArray

=cut

# Let the code begin...

package GenOO::TranscriptCollection::Factory::GTF;

use Moose;
use namespace::autoclean;
use IO::Zlib;

use GenOO::RegionCollection::Factory;
use GenOO::Transcript;

has 'file' => (is => 'Str', is => 'ro');

with 'GenOO::RegionCollection::Factory::Requires';

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub read_collection {
	my ($self) = @_;
	
	my @transcripts = $self->_read_gtf_with_transcripts($self->file);
	
	return GenOO::RegionCollection::Factory->create('RegionArray',
		{
			array => \@transcripts
		}
	)->read_collection;
}

#######################################################################
#########################   Private methods  ##########################
#######################################################################
sub _read_gtf_with_transcripts {
	my ($self, $file)=@_;
	
	my %transcripts;
	my %transcript_splice_starts;
	my %transcript_splice_stops;
	
	my $FH;
	if ($file =~ /\.gz$/) {
		$FH = IO::Zlib->new($file, 'rb') or die "Cannot open file $file\n";
	}
	else {
		open ($FH, '<', $file);
	}
	
	while (my $line = $FH->getline){
		chomp($line);
		if (($line !~ /^#/) and ($line ne '') and ($line !~ /^\s*$/)) {
			my ($chr, $genome, $type, $start, $stop, $score, $strand, undef, $nameinfo) = split(/\t/, $line);
			
			if (($strand ne "+") and ($strand ne "-")){warn "Skipping transcript $nameinfo: strand $strand not accepted\n"; next;}
			
			$start = $start-1; #GTF is one based closed => convert to 0-based closed.
			$stop = $stop-1;
			$nameinfo =~ /transcript_id\s+\"(.+)\"/;
			my $transcript_id = $1;
			
			
			# Get transcript with id or create a new one. Update coordinates if required
			my $transcript = $transcripts{$transcript_id};
			if (not defined $transcript) {
				$transcript = GenOO::Transcript->new(
					id            => $transcript_id,
					chromosome    => $chr,
					strand        => $strand,
					start         => $start,
					stop          => $stop,
					splice_starts => [$start], # will be re-written later
					splice_stops  => [$stop], # will be re-written later
				);
				$transcripts{$transcript_id} = $transcript;
				$transcript_splice_starts{$transcript_id} = [];
				$transcript_splice_stops{$transcript_id} = [];
			}
			else {
				if ($start < $transcript->start) {
					$transcript->start($start);
				}
				if ($stop > $transcript->stop) {
					$transcript->stop($stop);
				}
			}
			
			if ($type eq 'exon') {
				push @{$transcript_splice_starts{$transcript_id}}, $start;
				push @{$transcript_splice_stops{$transcript_id}}, $stop;
			}
			elsif ($type eq 'start_codon') {
				if ($strand eq '+') {
					$transcript->coding_start($start);
				}
				elsif ($strand eq '-') {
					$transcript->coding_stop($stop);
				}
			}
			elsif ($type eq 'stop_codon') {
				if ($strand eq '+') {
					$transcript->coding_stop($stop);
				}
				elsif ($strand eq '-') {
					$transcript->coding_start($start);
				}
			}
		}
	}
	close $FH;
	
	foreach my $transcript_id (keys %transcripts) {
		$transcripts{$transcript_id}->set_splice_starts_and_stops($transcript_splice_starts{$transcript_id}, $transcript_splice_stops{$transcript_id});
	}
	
	return values %transcripts;
}

1;
