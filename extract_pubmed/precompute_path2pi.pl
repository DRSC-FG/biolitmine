#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';
use List::MoreUtils 'uniq';


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Precompute Mapping of PMIDs to PIs
#
# NOTE: each PI is someone who studied pathway-related genes
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

my ( $pathways, $pi_info, $final );

my $input ="data_extracted/combined/sorted/";
my $output_dir = "data_extracted/precomputation/" ;
my $download_dir = "data_input/";

open( PATH, '<', $download_dir.'TM_pathways.csv' ) or die $!;
while (<PATH>) {
    chomp;

    # Remove all quotations.
    s/"//g;
    my ( 
        $id, $taxon, $gene_id, $symbol, 
        $gene_name, $uniprot, $pathway 
    ) = split "\t";

    my $composite_key = $taxon . ';' . $pathway;
    if ( exists $pathways->{$composite_key} ) {
        push @{$pathways->{$composite_key}}, $gene_id . ';' . $symbol;
    }
    else {
        $pathways->{$composite_key} = [$gene_id . ';' . $symbol];
    }
}
close PATH;

open( PI, '<', $input . 'pi_info.txt' ) or die $!;
while (<PI>) {
    chomp;
    my ( 
        $taxon, $gene, $lname, $initials, 
        $address, $recent, $year, $pmids
    ) = split "\t";

    my $pi = $lname . ', ' . $initials;
    $pi_info->{$gene}{$pi} = {
        recent => $recent,
        info => join( "\t", $address, $recent, $year ),
        pmids => [ split( ', ', $pmids ) ]
    };
}
close PI;

# Map pathway to PI, and include list of pathway-related genes and
# associating PMIDs (by PI).
foreach my $pathway ( keys %$pathways ) {
    foreach my $gene ( @{ $pathways->{$pathway} } ) {
        my ( $id, $symbol ) = split ';', $gene;

        # Skip if no PI info can be found for gene.
        next unless exists $pi_info->{$id};

        foreach my $pi ( keys %{$pi_info->{$id}} ) {
            if ( exists $final->{$pathway}{$pi} ) {
                push @{$final->{$pathway}{$pi}{genes}}, $symbol;

                # Add PMIDs to current list for PI. Re-sort list and remove
                # duplicates.
                my @pmids = @{ $final->{$pathway}{$pi}{pmids} };
                my @new_pmids = @{ $pi_info->{$id}{$pi}{pmids} };
                push @pmids, @new_pmids;
                @pmids = uniq ( sort { $b <=> $a } @pmids );
		        $final->{$pathway}{$pi}{pmids} = \@pmids;

                # If gene's recent paper is more recent than one currently
                # listed for PI, replace with updated info.
                if ( $final->{$pathway}{$pi}{recent} < $pi_info->{$id}{$pi}{recent} ) {
                    $final->{$pathway}{$pi}{recent} = $pi_info->{$id}{$pi}{recent};
                    $final->{$pathway}{$pi}{info} = $pi_info->{$id}{$pi}{info};
                }
            }
            else {
                $final->{$pathway}{$pi} = {
                    genes => [$symbol],
                    recent => $pi_info->{$id}{$pi}{recent},
                    pmids => $pi_info->{$id}{$pi}{pmids},
                    info => $pi_info->{$id}{$pi}{info}
                };
            }
        }
    }
}

# Output results to output file for upload into DB.
open( OUTPUT, '>', $output_dir . 'pathway2pi.txt' ) or die $!;
foreach my $pathway ( keys %$final ) {
    my ( $taxon, $name ) = split ';', $pathway;
    foreach my $pi ( keys %{$final->{$pathway}} ) {
        my @genes = uniq @{ $final->{$pathway}{$pi}{genes} };
        my @pmids =  @{$final->{$pathway}{$pi}{pmids}} ;
        say OUTPUT join( "\t", 
            $taxon, $name, $pi, $final->{$pathway}{$pi}{info},
            join(', ', @genes ), scalar @genes,  
            join( ', ', @pmids ), scalar @pmids
        );
    }
}
close OUTPUT;
