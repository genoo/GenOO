#!/usr/bin/env perl
use warnings;
use strict;
use File::Find;

BEGIN { 
	
	find(\&load, 't/Test/MyBio/');
	
	sub load {
		my $filename = $_;
		
		if ((-f $filename) and ($filename =~ /.+\.pm$/)) {
			open my $HANDLE, $filename or die "Cannot open $filename. $!";
			while (my $line = <$HANDLE>) {
				if ($line =~ /package\s+(.+);/o) {
					eval "require ".$1;
					last;
				}
			}
			close $HANDLE;
		}
	}
};

Test::Class->runtests;


