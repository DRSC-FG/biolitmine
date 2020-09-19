#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';
use Getopt::Long;
use Pod::Usage;

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Downloads Baseline or Update Files from NCBI
#
# Two required parameters:
#   - a destination directory for the files download
#   - type of XMLs to download, either `baseline` or `updatefiles`
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

my $DIR;
my $TYPE;
my $usage = "EXAMPLE USAGE
$0 -dir <diretory name>  -type <'baseline' or 'updatefiles'>";

GetOptions(
    'dir=s' => \$DIR,
    'type=s' =>\$TYPE,
    help     => sub { pod2usage($usage); },
) or pod2usage(2);

unless ($DIR) {
    pod2usage($usage);
    pod2usage(2);
}

unless ($TYPE eq 'baseline' or $TYPE eq 'updatefiles' ){
    pod2usage($usage);
    pod2usage(2);
}

get_xml_files( $DIR, $TYPE );
my $update_found = read_wget_log();
if ( $update_found ) {
    say "New updates found. Starting workflow to extract data from XMLs."
}
say "Done.";


#-----------------------
# HELPER FUNCTIONS 
#-----------------------

# Checks ftp site for XML files.
sub get_xml_files {
    my ( $dir, $type ) = @_;

    chdir( "$dir/" ) or 
        say "Please enter valid directory name for dir" and exit;
    system("rm -f wget_updatefiles.log");

    #  -N: turn on time-stamping; only download if local timestamps are older
    # -nv: show basic information (and error messages) only; no verbosity
    my $cmd = 'wget -N -nv '
        . 'ftp://ftp.ncbi.nlm.nih.gov/pubmed/' . $type . '/pubmed*.xml.gz '
        . '2>> wget_updatefiles.log';
    system( $cmd );
}


# Read wget_updatefiles.log to see which files are updated, if any.
sub read_wget_log {
    open( LOG, '<', 'wget_updatefiles.log' ) or die $!;
    my $update_found = 0;

    while ( <LOG> ) {
        chomp;

        # Check if older files are same as files in "current_release".
        if ( /(pubmed\w+\.xml\.gz).*-> "(.*)" \[/ ) {
            $update_found = 1;

            my $filename = $1;
            my $status   = $2;
            if ( $filename eq $status ) {
                unzip_file( $filename );
            }
        }
    }
    return $update_found;
}


# Extract file without removing zipped file.
sub unzip_file {
    my ( $file ) = @_;

    print "unzip file $file \n";

    my $cp_cmd = "cp -p $file $file.bak";
    my $gz_cmd = "gunzip -f $file";
    my $mv_cmd = "mv $file.bak $file";

    system( $cp_cmd );
    system( $gz_cmd );
    system( $mv_cmd );
}

