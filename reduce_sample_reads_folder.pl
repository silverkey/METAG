#!/usr/bin/perl
use strict;
use warnings;

# VERSION: 0.1

my $usage = "\n\tUSAGE: perl $0 [folder] [reduction ratio (e.g. 100)]\n\n";

die $usage unless scalar(@ARGV) == 2;
die $usage unless -d $ARGV[0];
die $usage unless $ARGV[1] > 0;

my $folder = $ARGV[0];
my $reduction = $ARGV[1];

chdir($folder) or die "\nERROR: cannot cd into $folder\n\n";

my @archive = glob('*.gz');

foreach my $archive(@archive) {

  my $tot = 0;
  my $count = 0;
  my $written = 0;

  my $file = "$archive";
  $file =~ s/\.gz//;
  my $new = "REDUCED_$file";

  print "Working on file: $file\...\n";
  print "Gunzipping...\n";
  system("gunzip $file");

  print "Opening file $file for reading\...\n";
  open(IN,$file);
  print "Opening file $new for writing\...\n";
  open(OUT,">$new");

  my $seq;

  while(my $row = <IN>) {
    $tot ++;
    $count ++;

    $seq = $row;
    $seq .= <IN>;
    $seq .= <IN>;
    $seq .= <IN>;
  
    if($count == $reduction) {
      print OUT $seq;
      $count = 0;
      $written ++;
    }
    $seq = '';
  }

  print "Total sequences: $tot\n";
  print "Written sequences in reduced file: $written\n";

  close(IN);
  close(OUT);

  print "Gzipping $new\n\n";
  system("gzip $new");
}
