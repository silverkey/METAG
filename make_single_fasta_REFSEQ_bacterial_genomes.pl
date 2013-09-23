#!/usr/bin/perl
use strict;
use warnings;

my $dbdir = 'all';
chdir $dbdir or die "Cannot change dir in dbdir $dbdir: $!\n";

my @folder = glob('*');

foreach my $folder(@folder) {
  next unless -d $folder;
  print "Found $folder\n";
  chdir($folder) or die "Error in changing dir $folder $!\n";
  my @file = glob('*');
  foreach my $file(@file) {
    print "\t$file\n";
    system("cat $file >> ../all_bacteria.fa");
  }
  chdir('..') or die "Error in chancing dir ../ $!\n";
}
