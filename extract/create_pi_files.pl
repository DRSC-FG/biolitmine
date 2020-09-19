#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Extract Information about PIs
#
# In addition to contact information, keep a tally on number of genes studied 
# in each publication.
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

my $base_dir = 'data_extracted/combined/sorted/';
my $gene2pubmed_dir = 'data_extracted/gene2pubmed/';

# Get brief info of each PMID (publication/medline year, publication type).
my %details;
open( BRIEF, '<', $base_dir . 'brief_info.txt' ) or die $!;
while (<BRIEF>) {
    chomp;

    # Skip header line (if any).
    next if /^pmid\t/;
    my ( 
        $pmid, $title, $pub_date, $pub_year,
        $med_date, $med_year, $type
    ) = split "\t";
    $pmid = trim($pmid);
    $details{$pmid} = join( "\t", $pub_year, $med_year, $type );
}
close BRIEF;

# Get PI info (last author) of each PMID.
my %authors;
open( AUTHOR, '<', $base_dir . 'authors2pubmed.txt' ) or die $!;
while (<AUTHOR>) {
    chomp;

    # Skip header line (if any).
    next if /^pmid\t/;
    my (
        $pmid, $lname, $fname,   $initials, $order, 
        $last, $email, $address, $new_addr, $id
    ) = split '\t';
    if ( $last eq 'Y' ) {
	    $pmid = trim($pmid);
        $authors{$pmid} = join( "\t",   $lname, $fname, $initials,
                                $email, $address );
    }
}
close AUTHOR;

# Process the files to find information about the authors.
my ( %papers, %pis, %counts );
open( G2P, '<', $gene2pubmed_dir. 'gene2pubmed_modified.txt' ) or die $!;
while (<G2P>) {
    chomp;
    my ( $taxon, $gene, $pmid, $gene_count ) = split "\t";

    # Only consider publications that study 100 genes or less.
    next if $gene_count > 100;
    
    $pmid = trim($pmid);
    
    # Check if author data is available for the given PMID
    if ( $authors{$pmid} and $details{$pmid} ) {
        my ( $lname, $fname, $initials, $email, $addr ) = split "\t", $authors{$pmid};
        my ( $pub_date, $med_date ) = split "\t", $details{$pmid};
        my $composite_key = $gene . $lname . $initials;

        # Keep list of PMIDs regarding gene for each PI.
        if ( exists $papers{$composite_key} ) {
            push @{$papers{$composite_key}}, $pmid;
        }
        else {
            $papers{$composite_key} = [$pmid];
        }

        # Get most recent PMID of each PI, and its address and pub/med date. If there
        # is no recent PMID, then this must be the first publication.
        if ( exists $pis{$composite_key} ) {
            my $recent_pmid = $pis{$composite_key}{recent};

            if ( $pmid > $recent_pmid ) {
                $pis{$composite_key}{recent} = $pmid;
                $pis{$composite_key}{info} = join( "\t",
                    $taxon, $gene, $lname, $initials, $addr, $pmid,
                    ( $pub_date eq 'NA' ? $med_date : $pub_date )
                );
            }
        }
        else {
            $pis{$composite_key} = {
                recent => $pmid,
                info => join( "\t", 
                    $taxon, $gene, $lname, $initials, $addr, $pmid,
                    ( $pub_date eq 'NA' ? $med_date : $pub_date )
                )
            };
        }
    }

    # Keep record of each PMID's gene count.
    $counts{$pmid} = $gene_count unless exists $counts{$pmid};
}
close G2P;

# Print authors information of each publication, along with its gene count.
open( REPORT, '>', $base_dir. 'pi2pubmed.txt' ) or die $!;
say REPORT join( "\t",      'pmid',     'lname',    'fname',    'initials', 'email',
                 'address', 'pub_year', 'med_year', 'pub_type', 'gene_count' );
foreach my $pmid ( sort{ $a <=> $b } keys %counts ) {
    next unless ( $authors{$pmid} and $details{$pmid} );
    say REPORT join( "\t", $pmid, $authors{$pmid}, $details{$pmid}, $counts{$pmid} );
}
close REPORT;


# Print PI information with precomputed list of PMIDs.
open( REPORT, '>', $base_dir. 'pi_info.txt' ) or die $!;
say REPORT join( "\t",         'tax_id', 'gene_id', 'lname', 'initials', 'address',
                 'recent_pub', 'year',    'pmids',   'paper_count' );
foreach my $pi ( keys %papers ) {
    my @pmids = sort { $b <=> $a } @{ $papers{$pi} };
    say REPORT $pis{$pi}{info}, "\t", join( ', ', @pmids ), "\t", scalar @pmids;
}
close REPORT;


#-----------------------
# HELPER FUNCTIONS 
#-----------------------

sub trim($) {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}