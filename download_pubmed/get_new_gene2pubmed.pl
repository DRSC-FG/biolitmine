#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';
use Getopt::Long;
use Pod::Usage;

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Downloads gene2pubmed File from NCBI
#
# One required parameter: a destination directory for the file download
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


my $DIR;
my $usage = "EXAMPLE USAGE
$0 -dir <destination directory to save file> ";

GetOptions(
    'dir=s' => \$DIR,
    help     => sub { pod2usage($usage); },
) or pod2usage(2);

unless ( $DIR ) {
    pod2usage($usage);
    pod2usage(2);
}

download_file( $DIR );
unzip_file();
say "Done.";


#-----------------------
# HELPER FUNCTIONS 
#-----------------------

sub download_file {
    my ( $dir ) = @_;

    chdir("$dir/") or 
        say "Please enter valid directory name for dir" and exit;
    system("rm -f wget_g2p.log");

    #  -N: turn on time-stamping; only download if local timestamps are older
    # -nv: show basic information (and error messages) only; no verbosity
    my $cmd = 'wget -N -nv '
        . 'ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2pubmed.gz '
        . '2>> wget_g2p.log';
    system( $cmd );
}

sub unzip_file  {
    my $file =  "gene2pubmed.gz";
    say "Unzipping and moving step $file";

    my $cp_cmd = "cp -p $file $file.bak";
    my $gz_cmd = "gunzip -f $file";
    my $mv_cmd = "mv  $file.bak $file";

    system( $cp_cmd );
    system( $gz_cmd );
    system( $mv_cmd );
}
