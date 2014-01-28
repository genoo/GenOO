- [Description](#description)
- [Details](#details)
	- [Gene](#gene)
	- [Transcript / Isoform](#transcript--isoform)
- [Examples](#examples)
	- [Creating a transcript](#creating-a-transcript)
	- [Creating a gene](#creating-a-gene)
	- [Collection of transcripts](#collection-of-transcripts)
	- [Collection of genes](#collection-of-genes)

# Description
Arguably, the backbone of GenOO is the `Region` role that corresponds to an area on a reference sequence. It requires other classes that consume it, to implement specific attributes such as the `strand`, `rname` (reference name), `start`, `stop` and `copy_number`. This role is consumed by several other classes within the framework and provides common grounds for code integration. Extending this approach, the `GenomicRegion` class consumes `Region` and additionally sets the constraint that the reference sequence has to be a particular chromosome. The `GenomicRegion` serves as the base for the representation of advanced genomic elements such as the genes, gene transcripts, 5'UTRs, non-coding RNAs and others.

# Details
## Gene
A `Gene`, in essence, is defined as a set of `Transcript` objects which also must share some positional overlap.

According to recent annotations and contrary to common conception, genes cannot be divided into protein coding and non-coding ones. Instead, and possibly more correctly even in biological terms, a user can ask if a gene has coding potential or not. In this case a gene will scan through its assigned transcripts and check if there are any coding ones or not.

Given the above gene definition, it is perhaps surprising that a gene extends the `GenomicRegion` class. However, this should not be the case as a gene object can extract positional information from its assigned transcripts. For example, the start position of a gene is defined as the smaller start position of its transcripts. Similarly, its strand is defined as the strand of its transcripts which by the way must be the same for all its transcripts.

## Transcript / Isoform
The `Transcript` class corresponds to a gene transcript/isoform and can be an independent object or more commonly belong to a `Gene` object.

Contrary to a gene object, a transcript object does not internally look upstream to its assigned gene to extract infromation. This is done on purpose to avoid strange cyclic assignments and also because we believe that the transcript annotation should serve as the base for the gene annotation and not vice versa. Therefore, information extraction from the gene level, although possible, is left entirelly on the user.

Transcripts contrary to genes are divided into protein coding and non-coding ones. Note that protein coding transcripts in contrast to non-coding ones have methods that extract the coding (`CDS`), 5’ UTR (`UTR5`) and 3’UTR (`UTR3`) sequences and coordinates.

A particularly important (as people that have worked with alternative splicing can verify) structure within the genomic group of classes is the `Spliceable` role. This role groups the functionality for entities/classes that undergo alternative splicing and supports several advanced methods such as the extraction of exonic and intronic elements and facilitates management of the complex structures. Importantly, `Spliceable` is primarily consumed by `Transcript` but it is also consumed by `UTR5`, `UTR3` and `CDS`. This has a very interesting and in several cases very useful side-effect that for example, one can ask for the introns that are extracted from the 3'UTR sequence of a transcript (`$transcript->utr3->introns`)

# Examples
## Creating a transcript
```perl
my $transcript = GenOO::Transcript->new(
    id             => 'transcr_1',
    strand         => 1,
    chromosome     => 'chrY',
    start          => 100,
    stop           => 410,
    splice_starts  => [100, 200, 300],
    splice_stops   => [150, 260, 410],
    coding_start   => 220,
    coding_stop    => 370,
    biotype        => 'coding',
);
```

## Creating a gene
```perl
my $gene = GenOO::Gene->new(
	name        => 'Gene_A',
	transcripts => [$transcript_1, $transcript_2] # These are objects, not transcript ids
);
```

## Collection of transcripts
```perl
# Create a collection of transcripts from a GTF file
my $transcript_collection = GenOO::TranscriptCollection::Factory->create('GTF', {
    file => 'transcripts_file.gtf'
})->read_collection;
```

## Collection of genes
```perl
# A collection of genes can be created from a transcript collection and from a hash that
# assigns transcript ids to gene names
my $transcript_id_to_genename = {
    'transcr_1' => 'Gene_A',
    'transcr_2' => 'Gene_A',
    'transcr_3' => 'Gene_B', # ...
}
my $gene_collection = GenOO::GeneCollection::Factory->create('FromTranscriptCollection', {
    transcript_collection => $transcript_collection,
    annotation_hash       => $transcript_id_to_genename
})->read_collection;
```