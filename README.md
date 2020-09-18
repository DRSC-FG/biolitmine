# biolitmine
Public Repo of Biolitmine Source Code

MIT Licenenced code

This is code used to generate the data used in the literture mining tool BioLitmine
https://www.flyrnai.org/tools/biolitmine

## Downloading data

The code considers XML downloaded at the end of the year to be "baseline"
and the updated daily updates provided by NCBI to be "updates".

Input data is the "data_input" folder and processed data in the "data_extracted" folder

code for downloading in /download_pubmed folder

## Extracing XML

The pubmed XML files are extracted into table form using R code found in the /rscipts directory.

There are two configuration file where the default directoried can be inspected and changed:  rscript/config_baseline.R and 
rscript/config_update.R.

The extraction deals creates 4 output types;
1. details
2. mesh
3. brief
4. author


 ## Further Data Preperation
 
 The extracted xml files require further processing into tabular form.  Code to do so is found in the extract_pubmed folder.
 
 

