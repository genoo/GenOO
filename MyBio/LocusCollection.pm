# POD documentation - main docs before the code

=head1 NAME

MyBio::LocusCollection - Object for a collection of MyBio::Locus objects, with features

=head1 SYNOPSIS

    # Object that manages a collection of MyBio::Locus objects. 

    # To initialize 
    my $locus_collection = MyBio::LocusCollection->new({
        NAME            => undef,
        SPECIES         => undef,
        DESCRIPTION     => undef,
        EXTRA_INFO      => undef,
    });


=head1 DESCRIPTION

    The primary data structure of this object is a 2D hash whose primary key is the strand 
    and its secondary key is the chromosome name. Each such pair of keys correspond to an
    array reference which stores objects of the class L<MyBio::Locus> sorted by start position.

=head1 EXAMPLES

    # Print entries in FASTA format
    $locus_collection->print("FASTA",'STDOUT',"/data1/data/UCSC/hg19/chromosomes/");
    
    # ditto
    $locus_collection->print_in_fasta_format('STDOUT',"/data1/data/UCSC/hg19/chromosomes/");

=cut

# Let the code begin...

package MyBio::LocusCollection;
use strict;

use MyBio::Locus;
use MyBio::MySub;
use MyBio::LocusCollection::Container;

use base qw(MyBio::_Initializable);

sub _init {
	my ($self,$data) = @_;
	
	$self->set_name($$data{NAME});
	$self->set_species($$data{SPECIES});
	$self->set_description($$data{DESCRIPTION});
	$self->set_extra($$data{EXTRA_INFO});
	$self->init;
	
	return $self;
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_name {
	my ($self, $value) = @_;
	$self->{NAME}=$value if defined $value;
}

sub set_species {
	my ($self, $value) = @_;
	$self->{SPECIES}=$value if defined $value;
}

sub set_description {
	my ($self, $value) = @_;
	$self->{DESCRIPTION}=$value if defined $value;
}

#######################################################################
########################   Accessor Methods   #########################
#######################################################################
sub name {
	my ($self) = @_;
	return $self->{NAME};
}

sub species {
	my ($self) = @_;
	return $self->{SPECIES};
}

sub description {
	my ($self) = @_;
	return $self->{DESCRIPTION};
}

sub container {
	my ($self) = @_;
	return $self->{CONTAINER};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub init {
	my ($self) = @_;
	
	$self->init_container;
}

sub init_container {
	my ($self) = @_;
	$self->{CONTAINER} = MyBio::LocusCollection::Container->new();
}

sub add_entry {
	my ($self, $entry) = @_;
	$self->container->add_entry($entry);
}

sub foreach_entry_do {
	my ($self, $block) = @_;
	$self->container->foreach_entry_do($block);
}

sub entries_count {
	my ($self) = @_;
	return $self->container->entries_count;
}

sub strands {
	my ($self) = @_;
	return $self->container->strands;
}

sub chromosomes_for_strand {
	my ($self, $strand) = @_;
	return $self->container->chromosomes_for_strand($strand);
}

sub chromosomes_for_all_strands {
	my ($self) = @_;
	return $self->container->chromosomes_for_all_strands;
}

sub get_or_find_longest_entry_length {
	my ($self) = @_;
	return $self->container->get_or_find_longest_entry_length;
}

sub is_empty {
	my ($self) = @_;
	return $self->container->is_empty;
}

sub is_not_empty {
	my ($self) = @_;
	return $self->container->is_not_empty;
}

sub sort_entries {
# TODO this method does not belong here. It should only be in the container. It should not be required by any other method.
	my ($self) = @_;
	$self->container->sort_entries;
}

sub entries_overlapping_region {
	my ($self, $strand, $chr, $start, $stop) = @_;
	return $self->container->entries_overlapping_region($strand, $chr, $start, $stop);
}

#######################################################################
##################   Methods that modify the object  ##################
#######################################################################
=head2 set_sequence_for_all_entries
  Arg [1]    : Hash reference containing parameters.
               Required parameters:
                  1/ CHR_FOLDER: The folder that contains fasta files with the chromosome sequences
  Example    : set_sequence_for_all_entries({
                 CHR_FOLDER       => "/chromosomes/hg19/"
               })
  Description: Sets the sequence attribute for all entries in the LocusCollection.
=cut
sub set_sequence_for_all_entries {
	my ($self, $params) = @_;
	
	my $chr_folder = delete $params->{'CHR_FOLDER'};
	unless (defined $chr_folder) {
		die "Error. The CHR_FOLDER must be specified in ".(caller(0))[3]."\n";
	}
	
	my $current_chr;
	my $current_chr_seq;
	$self->foreach_entry_do( sub {
		my ($entry) = @_;
		
		if ($entry->chr ne $current_chr) {
			my $chr_file = $chr_folder.'/'.$entry->chr.'.fa';
			if (-e $chr_file) {
				$current_chr_seq = MyBio::MySub::read_fasta($chr_file, $entry->chr);
				$current_chr = $entry->chr;
			}
			else {
				warn "Skipping chromosome. File $chr_file does not exist";
				next;
			}
		}
		
		my $entry_seq = substr($current_chr_seq, $entry->start, $entry->length);
		if ($entry->strand == -1) {
			$entry_seq = reverse($entry_seq);
			if ($entry_seq =~ /U/i) {
				$entry_seq =~ tr/ATGCUatgcu/UACGAuacga/;
			}
			else {
				$entry_seq =~ tr/ATGCUatgcu/TACGAtacga/;
			}
		}
		$entry->set_sequence($entry_seq);
	});
}

=head2 collapse
  Example    : $locus_collection->collapse
  Description: Entries with the same start and stop positions are collapsed into a single entry.
=cut
sub collapse {
	my ($self) = @_;
	
	my $entries_ref = $self->entries;
	my %collapsed_hash;
	foreach my $strand (keys %{$entries_ref}) {
		foreach my $chr (keys %{$$entries_ref{$strand}}) {
			if (exists $$entries_ref{$strand}{$chr}) {
				$collapsed_hash{$strand}{$chr} = [];
				my %count;
				foreach my $entry (@{$$entries_ref{$strand}{$chr}}) {
					my $start = $entry->get_start;
					my $stop = $entry->get_stop;
					$count{"$start|$stop"}++;
				}
				foreach my $pos (keys %count) {
					my ($start, $stop) = split(/\|/,$pos);
					my $entryObj = MyBio::Locus->new({
						CHR           => $chr,
						START         => $start,
						STOP          => $stop,
						STRAND        => $strand,
						NAME          => $count{$pos},
					});
					push (@{$collapsed_hash{$strand}{$chr}}, $entryObj);
					
				}
			}
		}
	}
	$self->set_entries(\%collapsed_hash);
}

=head2 merge
  Arg [1..]  : hash reference. Defines parameters for merging.
  Example    : $locus_collection->merge({OFFSET  => 0}) 
  Description: Merges loci which overlap or are closer than a given distance with each other (entries are replaced by merged ones)
  Returntype : NULL
=cut
sub merge {
	my ($self, $params) = @_;
	
	my $entries_ref = $self->entries;
	my %merged_hash;
	foreach my $strand (keys %{$entries_ref}) {
		foreach my $chr (keys %{$$entries_ref{$strand}}) {
			if (exists $$entries_ref{$strand}{$chr}) {
				$merged_hash{$strand}{$chr} = [];
				@{$merged_hash{$strand}{$chr}} = $self->merge_entries_in_array($$entries_ref{$strand}{$chr},$params);
			}
		}
	}
	$self->set_entries(\%merged_hash);
}

sub merge_entries_in_array {
	my ($self,$entries_array_ref,$params) = @_;
	
	my $offset = exists $params->{'OFFSET'} ? $params->{'OFFSET'} : 0;
	
	my @out = ();
	my @temp = ();
	my $region_of_overlap;
	foreach my $entry (@$entries_array_ref) {
		if (!defined $region_of_overlap) {
			$region_of_overlap = $entry->clone(); 
			push(@temp, $entry);
		}
		elsif ($region_of_overlap->overlaps($entry,$offset)) {
			push(@temp, $entry);
			my $start = $region_of_overlap->get_start < $entry->get_start ? $region_of_overlap->get_start : $entry->get_start;
			my $stop = $region_of_overlap->get_stop > $entry->get_stop ? $region_of_overlap->get_stop : $entry->get_stop;
			$region_of_overlap->set_start($start);
			$region_of_overlap->set_stop($stop);
		}
		else {
			$region_of_overlap = $entry->clone();
			if ($#temp == 0) {
				push (@out, $temp[0]);
			}
			else {
				push(@out,$self->merge_overlaping_entries(\@temp));
			}
			@temp = ();
			push(@temp, $entry);
		}
	}
	
	if ($#temp == 0) {
		push (@out, $temp[0]);
	}
	else {
		push(@out,$self->merge_overlaping_entries(\@temp));
	}
	@temp = ();
	return @out;
}

sub merge_overlaping_entries {
	my ($self,$temp) = @_;
	
	my @entryobjects = sort {$a->get_start() <=> $b->get_start()} @{$temp};
	
	my @out = ();
	my $newentry = $entryobjects[0];
	for (my $i = 1; $i < @entryobjects; $i++) {
		if ($entryobjects[$i]->get_start() < $newentry->get_start()) {
			$newentry->set_start($entryobjects[$i]->get_start());
		}
		if ($entryobjects[$i]->get_stop() > $newentry->get_stop()) {
			$newentry->set_stop($entryobjects[$i]->get_stop());
		}
		$newentry->set_name('');
	}
	push (@out,$newentry);
	return @out;
}

#######################################################################
##########################   Print Methods   ##########################
#######################################################################
=head2 print
  Arg [1]    : hash reference. Defines parameters for the output. The type of output (BED, FASTA, WIG) must be specified!
  Example    : $locus_collection->print({METHOD=>"BED"})
  Description: Prints all entries.
  Returntype : NULL
=cut
sub print {
	my ($self, $params) = @_;
	
	my $method = delete $params->{'METHOD'};
	
	if ($method eq 'BED'){
		$self->print_in_bed_format($params);
	}
	elsif ($method eq 'FASTA') {
		$self->print_in_fasta_format($params);
	}
	elsif ($method eq 'WIG') {
		$self->print_in_wiggle_format($params);
	}
	else {
		die "Unknown or no method specified in ".(caller(0))[3].". Use one of BED, WIG, or FASTA)";
	}
}

=head2 print_in_bed_format
  Arg [1]    : hash reference. Defines parameters for the output
               Required parameters are:
                  1/ OUTPUT: STDOUT or filename
  Example    : $locus_collection->print({OUTPUT => 'STDOUT'})      
  Description: Prints all entries in BED format.
  Returntype : NULL
=cut
sub print_in_bed_format {
	my ($self, $params) = @_;
	
	my $OUT;
	if ((!exists $params->{'OUTPUT'}) or ($params->{'OUTPUT'} eq "STDOUT")) {
		open ($OUT,">&=",STDOUT);
	}
	else {
		open($OUT,">",$params->{'OUTPUT'}) or die "Cannot open file ".$params->{'OUTPUT'}.". $!";
	}
	
	my $iterator = $self->entries_iterator;
	while (my $entry = $iterator->next) {
		print $OUT $entry->to_string("BED")."\n";
	}
}

=head2 print_in_fasta_format
  Arg [1]    : hash reference. Defines parameters for the output
               Required parameters are:
                  1/ OUTPUT: STDOUT or filename
                  2/ CHR_FOLDER: The folder containing the fasta files of the chromosomes
  Example    : $locus_collection->print({
                  OUTPUT           => "STDOUT",
                  CHR_FOLDER       => "/chromosomes/hg19/"
               })
  Description: Prints all entries in FASTA format.
  Returntype : NULL
=cut
sub print_in_fasta_format {
	my ($self, $params) = @_;
	
	my $chr_folder = exists $params->{'CHR_FOLDER'} ? $params->{'CHR_FOLDER'} : die "The method FASTA is requested in \"print\" but the folder with chromosome sequences is not provided";
	my $upflank = exists $params->{'UP_FLANK'} ? $params->{'UP_FLANK'} : 0;
	my $downflank = exists $params->{'DOWN_FLANK'} ? $params->{'DOWN_FLANK'} : 0;
	my $maxflank = $upflank > $downflank ? $upflank : $downflank;
	
	my $OUT;
	if ((!exists $params->{'OUTPUT'}) or ($params->{'OUTPUT'} eq "STDOUT")) {
		open ($OUT,">&=",STDOUT);
	}
	else {
		open($OUT,">",$params->{'OUTPUT'});
	}
	
	my $entries_ref = $self->entries;
	my @chromosomes_for_all_strands = $self->chromosomes_for_all_strands;
	foreach my $chr (@chromosomes_for_all_strands) {
		my $chr_file = $chr_folder."/$chr.fa";
		unless (-e $chr_file) {
			warn "Skipping chromosome. File $chr_file does not exist";
			next;
		}
		my $chr_seq = join('',map{'N'} (1..$maxflank)).MyBio::MySub::read_fasta($chr_file,"$chr").join('',map{'N'} (1..$maxflank));
		
		foreach my $strand ($self->strands) {
			my $entries_array_ref = $$entries_ref{$strand}{$chr};
			if (defined $entries_array_ref) {
				# Unbelievable as it may be, although the if else statement is not needed, having it here speeds up the script by approximately 8 times
				if (defined $maxflank) {
					foreach my $entry (@$entries_array_ref) {
						my $entry_seq;
						if ($strand == 1) {
							$entry_seq = substr($chr_seq,$entry->get_start()+$maxflank-$upflank,$entry->get_length+$upflank+$downflank);
						}
						else {
							$entry_seq = substr($chr_seq,$entry->get_start()+$maxflank-$downflank,$entry->get_length+$upflank+$downflank);
							$entry_seq = reverse($entry_seq);
							if ($entry_seq =~ /U/i) {
								$entry_seq =~ tr/ATGCUatgcu/UACGAuacga/;
							}
							else {
								$entry_seq =~ tr/ATGCUatgcu/TACGAtacga/;
							}
						}
						if (exists $params->{'UPDATE_SEQUENCE'}){$entry->set_sequence($entry_seq);}
						my $header = $entry->to_string("BED");
						$header =~ s/\t/|/g;
						print $OUT ">$header\n$entry_seq\n";
					}
				}
				else {
					foreach my $entry (@$entries_array_ref) {
						my $entry_seq = substr($chr_seq,$entry->get_start,$entry->get_length);
						if ($strand == -1) {
							$entry_seq = reverse($entry_seq);
							if ($entry_seq =~ /U/i) {
								$entry_seq =~ tr/ATGCUatgcu/UACGAuacga/;
							}
							else {
								$entry_seq =~ tr/ATGCUatgcu/TACGAtacga/;
							}
						}
						if (exists $params->{'UPDATE_SEQUENCE'}){$entry->set_sequence($entry_seq);}
						my $header = $entry->to_string("BED");
						$header =~ s/\t/|/g;
						print $OUT ">$header\n$entry_seq\n";
					}
				}
			}
		}
	}
}

=head2 print_in_wiggle_format
  Arg [1]    : hash reference. Defines parameters for the output
               Required parameters are:
                  1/ OUTPUT: STDOUT or filename
                  2/ WINDOW: The size in nucleotides of each bin in the WIG
                  3/ STEP: The distance in nucleotides between adjacent bins in the WIG file
  Example    : $locus_collection->print({
                  OUTPUT       => "STDOUT",
                  WINDOW       => 1000,
                  STEP         => 100,
               })
  Description: Prints all entries in WIG format.
  Returntype : NULL
=cut
sub print_in_wiggle_format {
	my ($self, $params) = @_;
	
	my $OUT;
	if ((!exists $params->{'OUTPUT'}) or ($params->{'OUTPUT'} eq "STDOUT")) {
		open ($OUT,">&=",STDOUT);
	}
	else {
		open($OUT,">",$params->{'OUTPUT'});
	}
	
	my $window = defined $params->{'WINDOW'} ? $params->{'WINDOW'} : 1000;
	my $step = defined $params->{'STEP'} ? $params->{'STEP'} : 100;
	my $entries_ref = $self->entries;
	$self->sort_entries();
	
	foreach my $strand (keys %{$entries_ref}) {
		foreach my $chr (keys %{$$entries_ref{$strand}}) {
			if (exists $$entries_ref{$strand}{$chr}) {
				my $lastend = (sort {$a->get_stop() <=> $b->get_stop()} @{$$entries_ref{$strand}{$chr}})[-1]->get_stop();
				my $last_positive_entry_index = 0;
				print $OUT "variableStep chrom=chr$chr span=$step\n";
				for (my $start = $window; $start < $lastend; $start += $step) {
					my $wiglocus = MyBio::Locus->new({
						STRAND       => $strand,
						CHR          => $chr,
						START        => $start,
						STOP         => ($start+$window-1)
					});
					my $score = 0;
					for (my $i = $last_positive_entry_index; $i< $#{$$entries_ref{$strand}{$chr}}; $i++) {
						my $entry = ${$$entries_ref{$strand}{$chr}}[$i];
						
						if ($wiglocus->overlaps($entry)) {
							$score++;
							$last_positive_entry_index = $i;
						}
						elsif ($wiglocus->get_stop < $entry->get_start) {
							last;
						}
					}
					if ($score > 0){
						print $OUT $wiglocus->get_start."\t".$score."\n";
					}
				}
			}
		}
	}
	return 0;
}

#######################################################################
############################   Deprecated   ###########################
#######################################################################
sub get_entries {
	my ($self) = @_;
	warn 'Deprecated method "get_entries". Use the iterator instead';
	return $self->container->structure;
}

sub get_name {
	my ($self) = @_;
	warn 'Deprecated method "get_name". Consider using "name" instead';
	return $self->name;
}

sub get_species {
	my ($self) = @_;
	warn 'Deprecated method "get_species". Consider using "species" instead';
	return $self->species;
}

1;
