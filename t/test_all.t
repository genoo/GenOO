#!/usr/bin/env perl
use warnings;
use strict;

use Test::Class::Load qw(t/Test/GenOO/);
Test::Class->runtests;

# use File::Find;
# 
# BEGIN { 
# 	
# 	find(\&load, 't/Test/GenOO/');
# 	
# 	sub load {
# 		my $filename = $_;
# 		
# 		warn "$filename\n";
# 		if ((-f $filename) and ($filename =~ /.+\.pm$/)) {
# 			open my $HANDLE, $filename or die "Cannot open $filename. $!";
# 			while (my $line = <$HANDLE>) {
# 				if ($line =~ /package\s+(.+);/o) {
# 					warn "$1\n";
# 					eval "require ".$1;
# 					last;
# 				}
# 			}
# 			close $HANDLE;
# 		}
# 	}
# };
# 
# Test::Class->runtests;


