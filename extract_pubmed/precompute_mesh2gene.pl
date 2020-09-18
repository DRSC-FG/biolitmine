#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';
use List::MoreUtils 'uniq';
use POSIX 'log10';
use Getopt::Long;
use Pod::Usage;


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Precompute Mapping of Gene to List of MeSH IDs
#
# There is one optional parameter: if `-child` is passed, then precomputed mappings
#                                  will include all child MeSH terms 
#
# TODO: 
#   for gene2mesh, an additional "score" is used to sort the list of 
#   MeSH terms for gene of interest. Current algorithm may not be the
#   most correct so will need to be updated (lines 243-245).
#
#   Current algorithm:
#     -log10(( gene-mesh papers / gene_papers ) * ( gene-mesh papers / mesh_papers ))
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

say "start";

# GLOBALS. Optional mapping of including child terms.
my $CHILD = '';
my $usage = "Usage:
  $0 [-child]

Quick Help:
  -child    precompute mappings to include child terms";

# Check flags.
GetOptions (
    'child' => \$CHILD,
    'help'  => sub { pod2usage($usage) }
) or pod2usage(2);

my ( $gene_info, $mesh_info, $pmid2mesh, $pmid2gene, $children, $final, $count );
my $input_dir = "." ;
my $output_dir = "data_extracted/precomputation/" ;
my $download_mesh_dir = "data_input/mesh_files/" ;

# Map gene ID to its gene symbol and total number of PMIDs.
say ".2. ";
open( GENE, '<', 'data_input/gene_information.csv' ) or die $!;
while (<GENE>) {
    chomp;
    chop;  # to remove carriage return
    my ( $gene_id, $taxon, $symbol ) = split ',';
    $gene_id = trim($gene_id);
    $symbol = trim($symbol);
    $gene_info->{$gene_id}{symbol} = $symbol;
}
close GENE;

say ".3. ";
open( GENE, '<', $output_dir. 'gene_pmids.txt' ) or die $!;
while (<GENE>) {
    chomp;
    my ( $gene_id, $pmids, $count ) = split "\t";
    $gene_id = trim($gene_id);
    $count = trim($count);
    $gene_info->{$gene_id}{paper_count} = $count;
}
close GENE;


# Map desc ID to its MeSH heading and total number of PMIDs.
say ".4. ";
open( MESH, '<',  $download_mesh_dir. 'mesh_info.txt' ) or die $!;
while (<MESH>) {
    chomp;
    my ( $desc_id, $term ) = split "\t";
    $term = trim($term);
    $desc_id = trim($desc_id);
    $mesh_info->{$desc_id}{term} = $term;
}
close MESH;

say ".5. ";
open( MESH, '<', $output_dir. 'mesh_pmids.txt' ) or die $!;
while (<MESH>) {
    chomp;
    my ( $desc_id, $pmids, $count ) = split "\t";
    $desc_id = trim($desc_id);
    $count = trim($count);
    next unless exists $mesh_info->{$desc_id};
    $mesh_info->{$desc_id}{paper_count} = $count;
}
close MESH;


# Map PMID to its list of MeSH terms
open( MESH, '<',  'data_extracted/combined/sorted/mesh2pubmed.txt' ) or die $!;
while (<MESH>) {
    chomp;
    my ( $pmid, $desc ) = split "\t";
    $desc = trim($desc);
    $pmid = trim($pmid);

    if ( exists $pmid2mesh->{$pmid} ) {
        push @{$pmid2mesh->{$pmid}}, $desc;
    }
    else {
        $pmid2mesh->{$pmid} = [$desc];
    }
}
close MESH;


# Map PMID to its list of gene IDs
say ".6. ";
open( GENE, '<', 'data_extracted/gene2pubmed/gene2pubmed_modified.txt' ) or die $!;
while (<GENE>) {
    chomp;
    my ( $taxon, $gene, $pmid, $count ) = split "\t";

    $taxon = trim($taxon);
    $pmid = trim($pmid);
    $count = trim($count);
    $gene = trim($gene);

    #??? amc
    #next if $count > 100;

    if ( exists $pmid2gene->{$pmid} ) {
        push @{$pmid2gene->{$pmid}}, join( ',', $taxon, $gene );
    }
    else {
        $pmid2gene->{$pmid} = [join( ',', $taxon, $gene )];
    }
}
close GENE;

# If 'child' option is enabled, create mapping of parent MeSH
# terms to all their child terms, e.g.
#     parent        child
#     D017918        D017919
#     D017918        D006515
if ( $CHILD ) {
    open( TREE, '<', 'data_extracted/mesh_files/mesh_tree.txt' ) or die $!;
    while(<TREE>) {
        chomp;
        my ( $parent, $child ) = split "\t";

        if ( exists $children->{$child} ) {
            push @{$children->{$child}}, $parent;
        }
        else {
            $children->{$child} = [$parent];
        }
    }
    close TREE;
}


# Create final mapping of mesh2gene and their full list of PMIDs.
my $printcount = 0;
foreach my $pmid_temp ( sort { $b <=> $a } keys %$pmid2mesh ) {
    chomp;
    my $pmid = "" . $pmid_temp;
    $printcount++;
    
    if ( $printcount < 1000 ) {
	    say "pmid2gene $pmid";
    }

    # does the gene have a PMID associated with it?
    if ( exists $pmid2gene->{$pmid} ) {
        if ( $printcount < 10 ){
            say $pmid ." -> exists";
        }
        
        # Get the genes and mesh terms for a given PMID
        my @terms = @{ $pmid2mesh->{$pmid} };
        my @genes = @{ $pmid2gene->{$pmid} };

        foreach my $desc ( @terms ) {

            if ( $printcount < 10 ){
                say "  --- $desc";
            }

            foreach my $gene ( @genes ) {

                if ( $printcount < 10 ){
                    print "  --- - -  $gene";
                }

                if ( exists $final->{$desc}{$gene} ) {
                    push @{$final->{$desc}{$gene}}, $pmid;
                } else {
                    $final->{$desc}{$gene} = [$pmid];
                }
                if ( $CHILD and exists $children->{$desc} ) {
                    foreach my $parent ( @{ $children->{$desc} } ) {
                        if ( exists $final->{$parent}{$gene} ) {
                            push @{$final->{$parent}{$gene}}, $pmid;
                        }
                        else {
                            $final->{$parent}{$gene} = [$pmid];
                        }
                    }
                }
            }
        }
    }
}

# Print results for upload into file for later import into database.
my $output = $CHILD ? 'mesh2gene_parent.txt' : 'mesh2gene.txt';
$output = $output_dir . $output;
say "output file " . $output;

open( OUTPUT, '>', $output ) or die $!;
foreach my $desc ( keys %$final ) {
    if (ref $final->{$desc} eq 'HASH'){

	foreach my $gene (keys  %{$final->{$desc}}) {
	    my ( $taxon, $id ) = split ',', $gene;

	    my @pmids = @{ $final->{$desc}{$gene} };
	    @pmids = uniq ( sort { $b <=> $a } @pmids );
	    my $pmids = join( ', ', @pmids );
	    my $count = () = $pmids =~ /,/g;
	    $count++;

	    # UI is only showing, at most, 10 recent publications. Truncate if needed.
	    my $recent = $pmids;
	    $recent = join( ', ', @pmids[0..9] ) if $count > 10;

	    # Only print mesh2gene mappings with MeSH terms we want, i.e. 
	    # D057229 ("Poverty") is not relevant so will not print.
	    if ( exists $gene_info->{$id}{paper_count} and scalar keys %{ $mesh_info->{$desc} } == 2 ) {
	    
            # Calculate score. 
            my $gene_freq = ( $count / $gene_info->{$id}{paper_count} );
            my $mesh_freq = ( $count / $mesh_info->{$desc}{paper_count} );
            my $score = sprintf( '%.2f', log10( $gene_freq * $mesh_freq ) * -1 );
        
            say OUTPUT join( "\t", 
                     $taxon, $desc, $mesh_info->{$desc}{term}, $id, 
                     ( $gene_info->{$id}{symbol} // '' ), $recent, 
                     $pmids, $count, $score 
                );
            }
        }
    }
}
close OUTPUT;


#-----------------------
# HELPER FUNCTIONS 
#-----------------------

sub trim($)
{
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}
