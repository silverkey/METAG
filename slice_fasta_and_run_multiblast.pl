#!/usr/bin/perl;
use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;

# VERSION 0.2

my $usage = "\n\tUSAGE: perl $0 [fasta] [processes]\n\n";
my $fasta = $ARGV[0];
my $processes = $ARGV[1];
die $usage unless scalar(@ARGV) == 2;
die $usage unless $processes > 0;

exec_command("perl slice_fasta_for_multiblast.pl $fasta $processes > slice.nohup");

my $outname = "$fasta";
$outname =~ s/\..+$//;
$outname .= '_slice';
exec_command("chdir $outname");

exec_command("perl ../multiblast.pl > ../multiblast.nohup");

sub exec_command {
  my $command = shift;
  print "\nLAUNCHING SYSTEM CALL:\n\t$command\n";
  system($command);
  print "ERROR using command:\n\t$command\:\n\t$!" unless $? == 0;
  print "CORRECTLY DONE command:\n\t$command\n" if $? == 0;
}

