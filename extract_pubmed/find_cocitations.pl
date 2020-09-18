#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# 
# Precompute Gene-Gene Co-citations
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

my ( %pmids, %gene_info, %gene2gene );

# Map gene ID to its gene symbol.
open( GENE, '<', 'data_input/gene_information.csv' ) or die $!;
while (<GENE>) {
    chomp;
    chop;  # to remove carriage return
    my ( $gene_id, $taxon, $symbol ) = split ',';
    $gene_info{$gene_id} = $symbol;
}
close GENE;

# Consolidate list of gene IDs by PMID, skipping papers with >100 genes, e.g.
#    Gene ID       PMID
#    814631        10617197    ->    10617197 => [ 814631, 814636, 814642 ]
#    814636        10617197
#    814642        10617197
open( G2P, '<', 'data_extracted/gene2pubmed/gene2pubmed_modified.txt' ) or die $!;
while (<G2P>) {
    chomp;
    my ( $taxon, $gene, $pmid, $gene_count ) = split "\t";
    next if $gene_count > 100;

    if ( exists $pmids{$pmid} ) {
        push @{$pmids{$pmid}}, $gene;
    }
    else {
        $pmids{$pmid} = [$gene];
    }
}
close G2P;

# Create pairwise mapping of genes and their list of PMIDs, e.g.
#     10617197 => [ 814631, 814636, 814642 ]
#                     ↓
#     gene1     gene2     list of PMIDs
#     ------    ------    --------------
#     814631 => 814636 => [ 10617197 ],
#     814631 => 814642 => [ 10617197 ],
#     814636 => 814642 => [ 10617197 ]
foreach my $pmid ( keys %pmids ) {
    my @genes = @{ $pmids{$pmid} };

    for ( my $i = 0; $i < scalar @genes; $i++ ) {
        for ( my $j = $i + 1; $j < scalar @genes; $j++ ) {
            if ( exists $gene2gene{$genes[$i]}{$genes[$j]} ) {
                push @{$gene2gene{$genes[$i]}{$genes[$j]}}, $pmid;
            }
            elsif ( exists $gene2gene{$genes[$j]}{$genes[$i]} ) {
                push @{$gene2gene{$genes[$j]}{$genes[$i]}}, $pmid;
            }
            else {
                $gene2gene{$genes[$i]}{$genes[$j]} = [$pmid];
            }
        }
    }
}

# Print results to gene2gene.txt.
open( OUTPUT, '>', 'data_extracted/precomputation/gene2gene.txt' ) or die $!;
foreach my $gene1 ( keys %gene2gene ) {
    # print "gene $gene1 \n";
    foreach my $gene2 ( keys %{$gene2gene{$gene1}} ) {
	#print "key $gene2 \n";
        # Sorting in descending order so that latest PMID is listed first.
        my @pmids = sort { $b <=> $a } @{ $gene2gene{$gene1}{$gene2}} ;
        my $pmids = join( ', ', @pmids );
        my $paper_count = scalar @pmids;

        my $recent = $pmids;
        $recent = join ( ', ', @pmids[0..9] ) if $paper_count > 10;
        say OUTPUT join( "\t", 
            $gene1,  $gene2, $gene_info{$gene2} // '',
            $recent, $pmids, $paper_count 
        );
    }
}
close OUTPUT;

