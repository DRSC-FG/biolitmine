# biolitmine
Public Repo of Biolitmine Source Code

MIT Licenenced code

The code considers XML downloaded at the end of the year to be "baseline"
and the updated daily updates provided by NCBI to be "updates".
Files to be extracted available here:
ftp://ftp.ncbi.nlm.nih.gov/pubmed/{type}/pubmed*.xml.gz 
Input data is the "data_input" folder and processed data in the "data_extracted" folder



There are two configuration file where the default directoried can be inspected and changed:  rscript/config_baseline.R and 
rscript/config_update.R.

The extraction deals creates 4 output types;
1. details
2. mesh
3. brief
4. author

1. XML Extraction

R-Scripts in the rscripts directory
    The current launch configuration uses SLURM scheduling.
    
 to start extraction without Slurm: run_xml_extractions_1_no_slurm.sh
 which runs a batch job
 
 run_xml_extractions_1_no_slurm.sh <type> <config file>  <process #> <total processes>
 eg:
 run_xml_extractions_1_no_slurm.sh detail rscripts/config_update.R 1 1
 run_xml_extractions_1_no_slurm.sh mesh rscripts/config_update.R 1 1
 run_xml_extractions_1_no_slurm.sh brief rscripts/config_update.R 1 1
 run_xml_extractions_1_no_slurm.sh author rscripts/config_update.R 1 2
 run_xml_extractions_1_no_slurm.sh author rscripts/config_update.R 2 2

 

