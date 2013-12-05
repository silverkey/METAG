#!/usr/bin/perl
use strict;
use warnings;
use Parallel::ForkManager;

# VERSION: 3

my $processes = 22;
my $cmd = '/home/remo/src/ncbi-blast-2.2.28+/bin/blastn ';
$cmd .= '-db /home/remo/BLASTDB/ALL_BACTERIA/all_bacteria.fa ';
$cmd .= '-max_target_seqs 30 -word_size 16 -num_threads 1 -outfmt ';
$cmd .= '"6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qcovs qcovhsp sgi staxids sscinames sskingdoms stitle" ';

open(LOG,'>MULTIBLAST.LOG');

my $pm = new Parallel::ForkManager($processes);

$pm->run_on_finish(
  sub {
    my($pid,$exit_code) = @_;
    print "** Just got out of the pool ".
          "with PID $pid and exit code: $exit_code\n";
  }
);

my @fasta = glob('*.fasta.*');
foreach my $fasta (@fasta) {
  my $out = "$fasta";
  $out =~ s/.fasta/.blast_out/;
  my $run = $cmd.'-query '.$fasta.' -out '.$out;
  sleep 1;
  # Forks and returns the pid for the child:
  my $pid = $pm->start and next;

  # Here is the parallelized block
  # -----------
  print "$pid ---> running on $fasta\n";
  print LOG "Launching $run\n";
  exec_command($run);
  # -----------

  # Terminates the child process
  $pm->finish;
}

sub exec_command {
  my $command = shift;
  print "\nLAUNCHING SYSTEM CALL:\n\t$command\n";
  system($command);
  print "ERROR using command:\n\t$command\:\n\t$!" unless $? == 0;
  print "CORRECTLY DONE command:\n\t$command\n" if $? == 0;
}

__END__

nohup time /home/remo/src/ncbi-blast-2.2.28+/bin/blastn -query D1N6AACXX_SZN-1-08_01_2013_13s000134-1-1_Balestra_lane313s000134_1_sequence.fasta -db /home/remo/BLASTDB/ALL_BACTERIA/al
l_bacteria.fa -out /media/LOCAL_DATA_1/metag/blastn/blast_allbac_134_1.txt -max_target_seqs 30 -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue b
itscore qcovs qcovhsp sgi staxids sscinames sskingdoms stitle" -word_size 16 -num_threads 24 > 134_1.nohup

