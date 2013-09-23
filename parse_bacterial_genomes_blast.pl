#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

my $usage = "\n\n\tUsage: perl $0 [blastout 1] [blastout2] [append string for out]\n\n\n";
die $usage unless scalar(@ARGV) == 3;
die $usage unless -e $ARGV[0];
die $usage unless -e $ARGV[1];
die $usage unless $ARGV[2];

# INPUT
my $FILE1 = $ARGV[0];
my $FILE2 = $ARGV[1];
my $OUT = $ARGV[2];

# BLAST CUTOFF PARAMETERS
my $PIDENT = 70;
my $LENGTH = 50;
my $EVALUE = 100;
my $QCOVHSP = 1;

# OTHER PARAMETERS

# Number of results to take out per query.
# If there are more than 1 results with the same evalue they will all be taken 
my $NUM = 1;

# PRINT DEBUG INFO
my $DEBUG = 0;

# VARIABLES TO SCAN THE BLAST OUTPUT
my $current;
my $seen;
my $init;
my $end;

# FIELDS OF THE BLAST TABLE OUTPUT IN THE ORDER THEY HAVE IN THE TABLE
my @blast_field = qw(qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qcovs qcovhsp sgi staxids sscinames sskingdoms stitle);

# FIELDS OF THE FILTERED BLAST OUTPUT PREPARED IN THE FIRST PHASE OF THE SCRIPT
my @filt_field = qw(qseqid sseqid pident qcovhsp evalue length stitle);

# CONTAINER FOR COMMON ID IN PAIRED END ANALYSIS
my $col = {};

# CONTAINER OF ALL THE ID THAT HAVE RESULTS IN BOTH FILES
my $paired = {};

# CONTAINER TO MAP THE REFSEQ ID TO THE REFSEQ TITLE
my $idtitmap = {};

# CONTAINER TO COUNT THE OCCURRENCES OF THE AASIGNED SPECIES
my $summary = {};

open(IN1,$FILE1);
open(IN2,$FILE2);
open(FILT1,">$FILE1\.filtered");
open(FILT2,">$FILE2\.filtered");
open(RES,">assignment_$OUT\.txt");
open(SUM,">summary_$OUT\.txt");

print FILT1 join("\t",@filt_field)."\n";
print FILT2 join("\t",@filt_field)."\n";
print RES "read_id\tgi\tname\n";
print SUM "gi\tcount\tname\n";

initialize();
while($end < 1) {
  my $res = next_res(\*IN1,\@blast_field);
  filter_res($res,\*FILT1,'1');
}

initialize();
while($end < 1) {
  my $res = next_res(\*IN2,\@blast_field);
  filter_res($res,\*FILT2,'2');
}

select_paired();
print Dumper $paired if $DEBUG;

close(IN1);
close(IN2);
close(FILT1);
close(FILT2);

open(FILT1,"$FILE1\.filtered");
open(FILT2,"$FILE2\.filtered");

initialize();
while($end < 1) {
  my $res = next_res(\*FILT1,\@filt_field);
  check_res($res,'1');
}

initialize();
while($end < 1) {
  my $res = next_res(\*FILT2,\@filt_field);
  check_res($res,'2');
}

foreach my $id(keys %$paired) {
  next unless $paired->{$id};
  my @tores = ($id,$paired->{$id},$idtitmap->{$paired->{$id}});
  print RES join("\t",@tores)."\n";
}

foreach my $id(keys %$summary) {
  my @tosum = ($id,$summary->{$id},$idtitmap->{$id});
  print SUM join("\t",@tosum)."\n";
}

close(FILT1);
close(FILT2);
close(RES);
close(SUM);

print Dumper $col if $DEBUG;
print Dumper $idtitmap if $DEBUG;
print Dumper $paired if $DEBUG;
print Dumper $summary if $DEBUG;

sub initialize {
  $current = 'NA';
  $seen = 'NA';
  $init = 'NA';
  $end = 0;
}

sub next_res {
  my $fh = shift;
  my $farray = shift;
  my $res = [];
  if($init eq 'NA') {
    my $irow = <$fh>;
    my $map = maprow($irow,$farray);
    $seen = $map->{qseqid};
    $current = $seen;
    push(@$res,$map);
  }
  else {
    push(@$res,$init);
    $current = $init->{qseqid};
  }
  while($current eq $seen) {
    my $row = <$fh>;
    if(!$row) {
      $end ++;
      return $res;
    }
    my $map = maprow($row,$farray);
    my $current = $map->{qseqid};
    if($current eq $seen) {
      push(@$res,$map);
    }
    else {
      $init = $map;
      $seen = $map->{qseqid};
    }
  }
  return $res;
}

sub maprow {
  my $row = shift;
  my $farray = shift;
  my @array = @$farray;
  chomp($row);
  my @val = split(/\t/,$row);
  my $map = {};
  for(my $c=0; $c<=$#array; $c++){
    $map->{$array[$c]} = $val[$c];
  }
  return $map;
}

sub filter_res {
  my $res = shift;
  my $fh = shift;
  my $string = shift;
  my $begin = 1;
  my $n = 1;
  my $mineval;
  foreach my $hsp(@$res){
    if($hsp->{pident} >= $PIDENT and $hsp->{length} >= $LENGTH and $hsp->{evalue} <= $EVALUE and $hsp->{qcovhsp} >= $QCOVHSP) {
      if($begin) {
        $mineval = $hsp->{evalue};
        undef($begin);
      }
      if($hsp->{evalue} > $mineval) {
        $n ++;
      }
      if($n <= $NUM) {
        # THE NEXT MUST TO BE THE SAME OF @FILT_FIELD!!!
        my @toout = ($hsp->{qseqid},$hsp->{sseqid},$hsp->{pident},$hsp->{qcovhsp},$hsp->{evalue},$hsp->{length},$hsp->{stitle});
        print $fh join("\t",@toout)."\n";
        $col->{$hsp->{qseqid}}->{$string} ++;
      }
    }
  }
}

sub select_paired {
  foreach my $id(keys %$col) {
    if(exists $col->{$id}->{1}) {
      if(exists $col->{$id}->{2}) {
        $paired->{$id} = '';
      }
    }
  }
  undef $col;
}

sub check_res {
  my $res = shift;
  my $file = shift;
  foreach my $hsp(@$res) {
    if(exists $paired->{$hsp->{qseqid}}) {
      if($file eq '1') {
        my $href = split_title($hsp->{stitle});
        my $gi = $href->{gi};
        push(@{$col->{$hsp->{qseqid}}},$gi);
      }
      if($file eq '2') {
        my $href = split_title($hsp->{stitle});
        my $gi = $href->{gi};
        foreach my $f1id(@{$col->{$hsp->{qseqid}}}) {
          if($f1id eq $gi) {
            undef $col->{$hsp->{qseqid}};
            $paired->{$hsp->{qseqid}} = $gi;
            $summary->{$gi} ++;
            return;
          }
        }
      }
    }
  }
}  

sub split_id {
  my $id = shift;
  my $href = {};
  my @id = split(/\|/,$id);
  $href->{gi} = $id[1];
  $href->{ref} = $id[4];
  return $href;
}

sub split_title {
  my $id = shift;
  my $href = {};
  my @id = split(/\|/,$id);
  $href->{gi} = $id[1];
  $href->{ref} = $id[3];
  $id[4] =~ s/^ //g;
  $href->{name} = $id[4];
  $idtitmap->{$id[1]} = $id[4];
  return $href;
}

__END__

Phylum
Order
Genus
