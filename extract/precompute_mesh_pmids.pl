#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Precompute Mapping of MeSH ID to List of PMIDs
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

my $pmids;


my $input_dir = "data_extracted/combined/sorted/" ;
my $output_dir = "data_extracted/precomputation/" ;

# pmid	mesh
# 1		D000432
open( INPUT, '<', $input_dir.  'mesh2pubmed.txt' ) or die $!;
while (<INPUT>) {
	chomp;
	my ( $pmid, $mesh ) = split "\t";
	
	if ( exists $pmids->{$mesh} ) {
		push @{$pmids->{$mesh}}, $pmid;
	}
	else {
		$pmids->{$mesh} = [$pmid];
	}
}
close INPUT;

open( OUTPUT, '>', $output_dir. 'mesh_pmids.txt' ) or die $!;
foreach my $mesh ( keys %$pmids ) {
	my @pmids = sort { $b <=> $a } @{ $pmids->{$mesh} };
	say OUTPUT $mesh, "\t", join(', ', @pmids ), "\t", scalar @pmids;
}
close OUTPUT;

