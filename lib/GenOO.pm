# POD documentation - main docs before the code

=head1 NAME

GenOO - A Modern Perl Framework for High Throughput Sequencing analysis

=head1 SYNOPSIS

    GenOO [jee-noo] is an object-oriented framework developed for the analysis of High Throughput Sequencing (HTS) data.
    The primary aim of GenOO is to make simple HTS analyses easy and complicated analyses possible.

=head1 DESCRIPTION

    GenOO models biological entities into objects and provides methods for the manipulation of high throughput
    sequencing data. Using GenOO as a core development module reduces the overhead and complexity of managing
    the data and the biological entities at hand. GenOO has been designed to be flexible, easily extendable with modular
    structure and minimal requirements for external tools and libraries.
    
    Source code: The source has been deposited in GitHub L<https://github.com/genoo/GenOO>.
    
    Documentation: A cookbook with basic ideas and examples is available in GitHub L<https://github.com/genoo/GenOO/tree/master/cookbook>
    
    Contribute: Please fork the GitHub repository and provide patches, features or tests.
    
    Bugs: Please open issues in the GitHub repository

=head1 EXAMPLES
    
    ####################
    # Parse a BED file. Similar for SAM, Fasta, FastQ etc.
    my $bed_parser = GenOO::Data::File::BED->new(
        file => 'input_file.bed'
    );
    while (my $record = $file_parser->next_record) {
        # $record is an instance of GenOO::Data::File::BED::Record
        print $record->name."\n"; # name
        print $record->strand."\n"; # strand
        print $record->length."\n"; # length
        print $record->head_position."\n"; # genomic location of the 5'end of the read
        print $record->to_string."\n"; # prints the record back in BED format
    }
    
    ####################
    # Create gene models from a GTF file
    my $transcript_collection = GenOO::TranscriptCollection::Factory->create('GTF', {
        file => 'transcripts_file.gtf'
    })->read_collection;
    
    # The gene models are now in a region collection type object
    # Loop on the collection and execute some code for each transcript
    $transcript_collection->foreach_record_do(sub{
        my ($transcript) = @_;
        
        print $transcript->id."\n" if $transcript->is_coding;
        # more code
    });
    
    ####################
    # Remember the BED parser before? Now instead of parsing the file line by line we
    # want to add its entries in a collection so we can perform range queries on it.
    my $reads_collection = GenOO::RegionCollection::Factory->create('BED', {
        file => 'input_file.bed'
    })->read_collection;
    
    # Get the reads of the BED file that overlap with a specified region
    my @overlapping_reads = $reads_collection->records_overlapping_region($strand, $chromosome, $start, $stop)
    
    # Any collection can be used to perform range queries on it, including the transcript collection above.
    
    ...
    # For more information and examples check the cookbook in L<https://github.com/genoo/GenOO/tree/master/cookbook>

=cut

# Let the code begin...


package GenOO;

use Modern::Perl;

1;
