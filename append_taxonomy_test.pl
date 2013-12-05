#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Bio::DB::Taxonomy;

my @KEYS = qw(species genus family suborder order subclass class phylum superkingdom);

my $DIR = '/media/LOCAL_DATA_1/metag/blastn/TAXONOMY';
my $NOD = '/media/LOCAL_DATA_1/metag/blastn/TAXONOMY/nodes.dmp';
my $NAM = '/media/LOCAL_DATA_1/metag/blastn/TAXONOMY/names.dmp';

my($db,$group) = initialize_taxonomy_db();

my $node = $db->get_taxon(-taxonid => '593905');

my $class = get_classification($node);
$class->{name} = $node->scientific_name;

print Dumper $class;

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
print "$rank -----> $name\n";
      $href->{$rank} = $name;
    }
  }
  return $href;
}

