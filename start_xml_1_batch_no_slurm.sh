#!/usr/bin/env bash

#
# This is the first step  Extract the xml files using R
# Places them in the data_extracted directory
# Configuration files in rscripts/
#    rscript/config_baseline.R    and  rscript/config_update.R

#
# Default Directories, create if needed
#

mkdir -p data_extracted/baseline


mkdir -p data_extracted/baseline/detail/
mkdir -p data_extracted/baseline/author
mkdir -p data_extracted/baseline/mesh
mkdir -p data_extracted/baseline/brief

mkdir -p data_extracted/updatefiles
mkdir -p data_extracted/updatefiles/detail
mkdir -p data_extracted/updatefiles/author
mkdir -p data_extracted/updatefiles/mesh
mkdir -p data_extracted/updatefiles/brief


#
# Run R script.
#
#
run_xml_extractions_1_no_slurm.sh
 run_xml_extractions_1_no_slurm.sh detail rscripts/config_update.R 1 1
 run_xml_extractions_1_no_slurm.sh mesh rscripts/config_update.R 1 1
 run_xml_extractions_1_no_slurm.sh brief rscripts/config_update.R 1 1
 run_xml_extractions_1_no_slurm.sh author rscripts/config_update.R 1 8
 run_xml_extractions_1_no_slurm.sh author rscripts/config_update.R 2 8
 run_xml_extractions_1_no_slurm.sh author rscripts/config_update.R 3 8
 run_xml_extractions_1_no_slurm.sh author rscripts/config_update.R 4 8
 run_xml_extractions_1_no_slurm.sh author rscripts/config_update.R 5 8
 run_xml_extractions_1_no_slurm.sh author rscripts/config_update.R 6 8
 run_xml_extractions_1_no_slurm.sh author rscripts/config_update.R 7 8
 run_xml_extractions_1_no_slurm.sh author rscripts/config_update.R 8 8
 run_xml_extractions_1_no_slurm.sh author rscripts/config_update.R 9 9


# Baseline  (the number at the end are process #, total number processes)

 run_xml_extractions_1_no_slurm.sh detail rscripts/config_baseline.R 1 2
 run_xml_extractions_1_no_slurm.sh detail rscripts/config_baseline.R 2 2
 run_xml_extractions_1_no_slurm.sh mesh rscripts/config_baseline.R 1 2
 run_xml_extractions_1_no_slurm.sh mesh rscripts/config_baseline.R 2 2
 run_xml_extractions_1_no_slurm.sh brief rscripts/config_baseline.R 1 2
 run_xml_extractions_1_no_slurm.sh brief rscripts/config_baseline.R 2 2
 run_xml_extractions_1_no_slurm.sh author rscripts/config_baseline.R 1 8
 run_xml_extractions_1_no_slurm.sh author rscripts/config_baseline.R 2 8
 run_xml_extractions_1_no_slurm.sh author rscripts/config_baseline.R 3 8
 run_xml_extractions_1_no_slurm.sh author rscripts/config_baseline.R 4 8
 run_xml_extractions_1_no_slurm.sh author rscripts/config_baseline.R 5 8
 run_xml_extractions_1_no_slurm.sh author rscripts/config_baseline.R 6 8
 run_xml_extractions_1_no_slurm.sh author rscripts/config_baseline.R 7 8
 run_xml_extractions_1_no_slurm.sh author rscripts/config_baseline.R 8 8
