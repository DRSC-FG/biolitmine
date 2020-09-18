#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Extract Information about Each MeSH Term from MeSH Trees of Interests:
#     A - Anatomy
#     B - Organisms
#     C - Diseases
#     D - Chemicals and Drugs
#     E - Analytical, Diagnostic and Therapeutic Techniques, and Equipment
#     F - Psychiatry and Psychology
#     G - Phenomena and Processes
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

my $tree_numbers = '[ABCDEFG]';

open( BRIEF, ">", 'data_input/mesh_files/mesh_info.txt' ) or die $!;
open( LOOKUP, ">", 'data_input/mesh_files/mesh_lookup.txt' ) or die$!;
local $, = "\t";

my $mesh_data = 'data_input/mesh_files/current_mesh';
open( MESH, "<", $mesh_data ) or die $!;

# Use '*NEWRECORD' as EOL for easier file reading (ignore the "first" line afterward).
local $/ = "*NEWRECORD\n";
my $useless = <MESH>;

my $tree_mapping;
while (<MESH>) {

    # MN - MeSH tree number(s)
    # Note: because each record can have multiple MNs, regex will capture
    #       all lines that contain 'MN =' then processes data accordingly.
    #       It assumes that record format has 'PA' or 'MH_TH' after 'MN'
    #       fields, and will use them as stopping point. Double-check file
    #       if update is needed. 
    my $mn = find_data( $_, '^(MN.*?)\n([^M]|MH_TH)' );
    my $mns = get_list( 'MN = ', $mn );

    # Move on if term is not in our trees of interest.
    next unless scalar grep( /^$tree_numbers/, @$mns );

    # MH - MeSH heading (main term)
    my $mh = find_data( $_, '^MH = (.*?)\n' );

    # UI - descriptor ID
    my $ui = find_data( $_, '^UI = (.*?)\n' );
    say BRIEF $ui, $mh, join( "; ", @$mns );

    # Add tree numbers to do parent-child_mapping.
    foreach my $mn ( @$mns ) {
        $tree_mapping->{$mn} = $ui;
    }

    # ENTRY - entry term(s)
    # Note: similar to MN, there can be multiple ENTRYs per record. Assumes
    #       'MN' comes after 'ENTRY' fields.
    my $entry = find_data( $_, '^(ENTRY.*?\n)^MN' );
    my $entries = get_list( 'ENTRY = ', $entry );

    # PRINT ENTRY - entry term(s), print form
    # Note: again, there can be multiple PRINTs per record. Assumes 'ENTRY'
    #       comes after 'PRINT ENTRY' fields.
    my $print = find_data( $_, '^(PRINT ENTRY.*?\n)^ENTRY' );
    my $prints = get_list( 'PRINT ENTRY = ', $print );

    say LOOKUP $mh, $mh, 'MESH TERM';
    foreach ( @$prints ) {
        say LOOKUP $mh, $_, 'PRINT ENTRY TERM';
    }
    foreach ( @$entries ) {
        say LOOKUP $mh, $_, 'ENTRY TERM';
    } 
}
close MESH;
close BRIEF;
close LOOKUP;

# Create file of parent desc IDs and their children desc IDs. List of children
# also include grandchildren.
open( TREE, '>', 'data_extracted/mesh_files/mesh_tree.txt' ) or die $!;
my @numbers = keys %$tree_mapping;
my %printed;
foreach my $number ( @numbers ) {
    my @children = grep( /^$number\./, @numbers );
    next if @children == 0;

    foreach my $child ( @children ) {
        my $parent_desc = $tree_mapping->{$number};
        my $child_desc = $tree_mapping->{$child};

        # Only print parent-child mapping to output once.
        $printed{$parent_desc . $child_desc}++;
        if ( $printed{$parent_desc . $child_desc} == 1 ) {
            say TREE $tree_mapping->{$number}, $tree_mapping->{$child};
        }
    }
}
close TREE;

#-----------------------
# HELPER FUNCTIONS 
#-----------------------

# Finds given regex in given record. Returns first captured group if 
# pattern found, else returns 'Not found'.
sub find_data {
    my ( $record, $regex ) = @_;
    if ( $record =~ /$regex/ms ) {
        return $1;
    }
    else {
        return 'Not found';
    }
}

# Returns list of data after processing and splitting with given delim.
sub get_list {
    my ( $delim, $data ) = @_;

    # Some entries may have subfields, e.g.
    #     ENTRY = A-23187|T109|T195|LAB|NRW|NLM (1991)|900308|abbcdef
    # so remove them, along with all newlines.
    $data =~ s/\|.*?\n//g;
    $data =~ s/\n//g;
    my @list = split( $delim, $data );
    shift @list; # first element is just '' so remove.
    return \@list;
}

