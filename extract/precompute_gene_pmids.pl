#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Precompute Mapping of Gene to List of PMIDs
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

my $pmids;
my $input_dir = "data_extracted/gene2pubmed/" ;
my $output_dir = "data_extracted/precomputation/" ;

system( "mkdir -p $output_dir" );

open( INPUT, '<',  $input_dir . 'gene2pubmed_modified.txt' ) or die $!;
while (<INPUT>) {
	chomp;
	my ( $taxon, $gene, $pmid ) = split "\t";
	
	if ( exists $pmids->{$gene} ) {
		push @{$pmids->{$gene}}, $pmid;
	}
	else {
		$pmids->{$gene} = [$pmid];
	}
}
close INPUT;

open( OUTPUT, '>', $output_dir . 'gene_pmids.txt' ) or die $!;
foreach my $gene ( keys %$pmids ) {
	my @pmids = sort { $b <=> $a } @{ $pmids->{$gene} };
	say OUTPUT $gene, "\t", join(', ', @pmids ), "\t", scalar @pmids;
}
close OUTPUT;
