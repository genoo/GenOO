sub read_locus_collections {
		my ($class, $params) = @_;
	
		unless (ref($params) eq "HASH") {
			die "\n\nDon't panic - Just use hash notation when calling ".(caller(0))[3]." in script $0\n\n";
		}
		
		my %handlers = (
			'BED' => \&_read_bedFile_with_multiple_locus_collections,
			'BEDGRAPH' => \&_read_bedgraphFile,
		);
		
		my $method = delete $params->{'METHOD'};
		unless (exists $handlers{$method}) {
			if (!defined $method) {
				die "\nNo method specified in ".(caller(0))[3]."\n";
			}
			else {
				die "\nUnknown method \"$method\" in ".(caller(0))[3].". Try (BED)";
			}
		}
		
		my %locus_collections = $handlers{$method}->($class,$params);
		foreach my $locus_collection (values %locus_collections) {
			$locus_collection->sort_entries;
		}
		
		return %locus_collections;
	}
	sub _read_bedFile_with_multiple_locus_collections {
		my ($class,$params) = @_;
		
		my $filename = $params->{'FILENAME'};
		my $locus_collectionname = exists $params->{'TRACK_NAME'} ? $params->{'TRACK_NAME'} : scalar(localtime());
		my $entry_score_thres = $params->{'SCORE_THRESHOLD'};
		
		my $locus_collection;
		my @browser_info;
		my %return_locus_collections;
		my $BED = new FileHandle;
		$BED->open($filename) or die "Cannot open file $filename $!";
		while (my $line=<$BED>){
			chomp($line);
			if ($line =~ /^locus_collection/){
				my %info;
				while ($line =~ /(\S+?)=(".+?"|\d+?)/g) {
					$info{$1} = $2;
				}
				$locus_collection = $class->new({
					NAME            => $info{"name"} || $locus_collectionname,
					DESCRIPTION     => $info{"description"},
					VISIBILITY      => $info{"visibility"},
					COLOR           => $info{"color"},
					RGB_FLAG        => $info{"itemRgb"},
					COLOR_BY_STRAND => $info{"colorByStrand"},
					USE_SCORE       => $info{"useScore"},
				});
				if (@browser_info > 0) {
					$locus_collection->push_to_browser(@browser_info);
					@browser_info = ();
				}
				$return_locus_collections{$locus_collection->get_name} = $locus_collection;
			}
			elsif ($line =~ /^browser/) {
				push @browser_info,$line;
			}
			elsif ($line =~ /^chr/) {
				
				if (!defined $locus_collection){
					$locus_collection = $class->new({
						NAME            => $locus_collectionname
					});
					if (@browser_info > 0) {
						$locus_collection->push_to_browser(@browser_info);
						@browser_info = ();
					}
					$return_locus_collections{$locus_collection->get_name} = $locus_collection;
				}
				
				
				my ($chr,$start,$stop,$name,$score,$strand,@others) = split(/\t/,$line);
				
				if (!defined $entry_score_thres or ($score >= $entry_score_thres)) {
					my $entry = MyBio::NGS::Tag->new({
						STRAND        => $strand,
						CHR           => $chr,
						START         => $start,
						STOP          => $stop - 1, #[start,stop)
						NAME          => $name,
						SCORE         => $score,
						THICK_START   => $others[0],
						THICK_STOP    => $others[1],
						RGB           => $others[2],
						BLOCK_COUNT   => $others[3],
						BLOCK_SIZES   => $others[4],
						BLOCK_STARTS  => $others[5],
					});
					
					$locus_collection->add_entry($entry);
				}
			}
		}
		close $BED;
		return %return_locus_collections;
	}

	sub _read_bedgraphFile {
		my ($class,$params) = @_;
		
		my $filename = $params->{'FILENAME'};
		my $locus_collectionname = exists $params->{'TRACK_NAME'} ? $params->{'TRACK_NAME'} : scalar(localtime());
		my $entry_score_thres = $params->{'SCORE_THRESHOLD'};
		
		my $locus_collection;
		my @browser_info;
		my %return_locus_collections;
		my $BEDgraph = new FileHandle;
		$BEDgraph->open($filename) or die "Cannot open file $filename $!";
		while (my $line=<$BEDgraph>){
			chomp($line);
			if ($line =~ /^locus_collection/){
				my %info;
				while ($line =~ /(\S+?)=(".+?"|\d+?)/g) {
					$info{$1} = $2;
				}
				$locus_collection = $class->new({
					NAME            => $info{"name"} || $locus_collectionname,
					DESCRIPTION     => $info{"description"},
					VISIBILITY      => $info{"visibility"},
					COLOR           => $info{"color"},
					RGB_FLAG        => $info{"itemRgb"},
					COLOR_BY_STRAND => $info{"colorByStrand"},
					USE_SCORE       => $info{"useScore"},
				});
				if (@browser_info > 0) {
					$locus_collection->push_to_browser(@browser_info);
					@browser_info = ();
				}
				$return_locus_collections{$locus_collection->get_name} = $locus_collection;
			}
			elsif ($line =~ /^browser/) {
				push @browser_info,$line;
			}
			elsif ($line =~ /^chr/) {
				
				if (!defined $locus_collection){
					$locus_collection = $class->new({
						NAME            => $locus_collectionname
					});
					if (@browser_info > 0) {
						$locus_collection->push_to_browser(@browser_info);
						@browser_info = ();
					}
					$return_locus_collections{$locus_collection->get_name} = $locus_collection;
				}
				
				
				my ($chr,$start,$stop,$score) = split(/\t/,$line);
				
				if (!defined $entry_score_thres or ($score >= $entry_score_thres)) {
					my $entry = MyBio::NGS::Tag->new({
						CHR           => $chr,
						START         => $start,
						STOP          => $stop - 1, #[start,stop)
						SCORE         => $score,
					});
					
					$locus_collection->add_entry($entry);
				}
			}
		}
		close $BEDgraph;
		return %return_locus_collections;
	}
	
	sub read_locus_collection {
		my ($class, $params) = @_;
	
		my %handlers = (
			'BED' => \&_read_bedFile_with_single_locus_collection,
		);
		
		my $method = delete $params->{'METHOD'};
		unless (exists $handlers{$method}) {
			if (!defined $method) {die "\nNo method specified in ".(caller(0))[3]."\n";}
			else                  {die "\nUnknown method \"$method\" in ".(caller(0))[3].". Try (BED)";}
		}
		
		my $locus_collection = $handlers{$method}->($class,$params);
		$locus_collection->sort_entries;
		return $locus_collection;
	}
	
	sub _read_bedFile_with_single_locus_collection {
		my ($class,$params) = @_;
		
		my $file = $params->{'FILENAME'};
		my $locus_collectionname = exists $params->{'TRACK_NAME'} ? $params->{'TRACK_NAME'} : scalar(localtime());
		my $entry_score_thres = $params->{'SCORE_THRESHOLD'};
		
		
		my $locus_collection = $class->new({
			NAME            => $locus_collectionname,
		});
		
		my $bedfile = MyBio::Data::File::BioFile->new({
			TYPE => 'BED',
			FILE => $file,
		});
		
		while (my $entity = $bedfile->next_entity) {
			if (exists $entity->{LOCUS} and (!defined $entry_score_thres or ($entity->{SCORE} >= $entry_score_thres))) {
				$locus_collection->add_entry(MyBio::NGS::Tag->new($entity));
			}
			elsif (exists $entity->{TRACK_INFO}) {
				if (exists $entity->{NAME}) {$locus_collection->set_name($entity->{NAME})}
				if (exists $entity->{DESCRIPTION}) {$locus_collection->set_description($entity->{DESCRIPTION})}
				if (exists $entity->{VISIBILITY}) {$locus_collection->set_visibility($entity->{VISIBILITY})}
				if (exists $entity->{COLOR}) {$locus_collection->set_color($entity->{COLOR})}
				if (exists $entity->{RGB_FLAG}) {$locus_collection->set_rgb_flag($entity->{RGB_FLAG})}
				if (exists $entity->{COLOR_BY_STRAND}) {$locus_collection->set_color_by_strand($entity->{COLOR_BY_STRAND})}
				if (exists $entity->{USE_SCORE}) {$locus_collection->set_use_score($entity->{USE_SCORE})}
			}
			elsif (exists $entity->{BROWSER}) {
				$locus_collection->push_to_browser($entity->{BROWSER});
			}
		}
		return $locus_collection;
	}