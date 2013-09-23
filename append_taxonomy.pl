#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Bio::DB::Taxonomy;

my @KEYS = qw(species genus family order class phylum superkingdom);

my $DIR = '/media/LOCAL_DATA_1/metag/blastn/TAXONOMY';
my $NOD = '/media/LOCAL_DATA_1/metag/blastn/TAXONOMY/nodes.dmp';
my $NAM = '/media/LOCAL_DATA_1/metag/blastn/TAXONOMY/names.dmp';

my($dbh,$group) = initialize_taxonomy_db();

my $FILE = 'summary_134_135.txt';

open(IN,$FILE);
open(OUT,">$FILE\.taxon");

my $head = <IN>;
chomp($head);
$head .= "\tused";
foreach my $key(@KEYS) {
  $head .= "\t".$key;
}
print OUT "$head\n";

while(my $row = <IN>) {

  chomp($row);
  my @data = split(/\t/,$row);
  my $def = $data[3];
  my @part = split(/\,/,$def);
  my $sel = $part[0];
  print "$sel\t";
  my @word = split(/ /,$sel);
  $sel =~ s/ chromosome.*$//;
  $sel =~ s/ mega plasmid.*$//;
  $sel =~ s/ plasmid.*$//;
  $sel =~ s/ DNA.*$//;
  $sel =~ s/ draft.*$//;
  print "$sel\n";

  my $taxon = $dbh->get_taxon(-name => $sel);

  if(!defined($taxon)) {
    $sel = "$word[0] $word[1]";
    $taxon = $dbh->get_taxon(-name => $sel);
  }
  if(!defined($taxon)) {
    $sel = "$word[0] $word[1] $word[2]";
    $taxon = $dbh->get_taxon(-name => $sel);
  }
  my $cl = get_classification($taxon);

  $row .= "\t$sel";
  foreach my $key(@KEYS) {
    if(exists $cl->{$key}) {
      $row .= "\t".$cl->{$key};
    }
    else {
      $row .= "\tNA";
    }
  }
  print OUT "$row\n";
}

sub initialize_taxonomy_db {
  my $dbh = Bio::DB::Taxonomy->new(-source =>'flatfile',
                                   -directory=> $DIR,
                                   -nodesfile=> $NOD,
                                   -namesfile=> $NAM);

  my $group = {};
  foreach my $item (@KEYS) { $group->{$item} = 1 }
  return($dbh,$group);
}

sub get_classification {
  my $taxon = shift;
  my $href = {};
  while(defined $taxon->ancestor) {
    $taxon = $taxon->ancestor;
    my $name = $taxon->scientific_name;
    my $rank = $taxon->rank;
    if(exists $group->{$rank}) {
      $href->{$rank} = $name;
    }
  }
  return $href;
}

