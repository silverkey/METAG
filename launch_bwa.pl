#!/usr/bin/perl
use strict;
use warnings;

my $command1 = '/home/remo/src/bwa-0.7.5a/bwa mem -t 20 genomes/allgenomes_april_2012_v6_one_per_species.fa fastq/34-1-1_1.fastq fastq/34-1-1_2.fastq > bwa_aln_34_pe.sam 2>ERR_bwa_aln_34_pe';
my $command2 = '/home/remo/src/bwa-0.7.5a/bwa mem -t 20 genomes/allgenomes_april_2012_v6_one_per_species.fa fastq/35-1-1_1.fastq fastq/35-1-1_2.fastq > bwa_aln_35_pe.sam 2>ERR_bwa_aln_35_pe';

exec_command($command1);
exec_command($command2);

sub exec_command {
  my $command = shift;
  print "\nLAUNCHING SYSTEM CALL:\n\t$command\n";
  system($command);
  die "ERROR using command:\n\t$command\:\n\t$!" unless $? == 0;
  print "DONE!\n";
}
