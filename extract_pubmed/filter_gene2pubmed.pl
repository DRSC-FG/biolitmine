#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Filter Publications
#
# Only keep publications focused on or related to the study of model organisms
# and humans.
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

my $taxons = [
    3702,            #  1. thale cress
    4896, 284812,    #  2. fission yeast
    4932, 559292,    #  3. bakers yeast
    6239,            #  4. worm
    7227,            #  5. fruit fly
    7955,            #  6. zebrafish
    8364,            #  7. western clawed frog
    9606,            #  8. human
    10090,           #  9. mouse
    10116            # 10. rat
];

filter_file( $taxons );
my $gene_counts = find_unique_PMIDs();
print_gene_counts( $gene_counts );


#-----------------------
# HELPER FUNCTIONS 
#-----------------------

sub filter_file {
    my ( $taxons ) = @_;

    foreach my $taxon ( @$taxons ) {
        `egrep '^$taxon\\s' data_input/gene2pubmed >> data_extracted/gene2pubmed/gene2pubmed_filtered.txt`;
    }
}

# Return list of "gene counts" index by PMID with count (# of times each PMID shows up).
sub find_unique_PMIDs {
    open( G2P, "<", "data_extracted/gene2pubmed/gene2pubmed_filtered.txt" ) or die $!;
    open( UNIQ, ">", "data_extracted/gene2pubmed/gene2pubmed_uniq.txt" ) or die $!;

    my %pmids;
    my %species;
    while (my $line = <G2P>) {
        chomp $line;
        my ( $taxon, $gene, $pmid ) = split /\t/, $line;
        $taxon =~ s/284812/4896/;
        $taxon =~ s/559292/4932/;
        unless ( exists $species{$taxon}{$pmid} ) {
            say UNIQ $line;
            $species{$taxon}{$pmid}++;
        }
        $pmids{$pmid}++;
    }
    close G2P;
    close UNIQ;

    return \%pmids;
}

# Add "Gene Count" to records and re-print to "gene2pubmed_modified.txt".
sub print_gene_counts {
    my ( $counts ) = @_;
    open( G2P, "<", "data_extracted/gene2pubmed/gene2pubmed_filtered.txt" ) or die $!;
    open( OUTPUT, ">", "data_extracted/gene2pubmed/gene2pubmed_modified.txt" ) or die $!;

    while (<G2P>) {
        chomp;
        my ( $tax, $gene, $pmid ) = split /\t/;
        say OUTPUT join( "\t", $tax, $gene, $pmid, $counts->{$pmid} // "" );    
    }
    close G2P;
    close OUTPUT;
}

