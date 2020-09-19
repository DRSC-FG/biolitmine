# PubMed XML Extraction

Rscript in this folder will convert the initially download files into tablular format.  These scripts typically are run from the parent directory.

### Requires
R verion 3.5 and up
and
        library(XML)
        library(splitstackshape)
        library(stringi)


### Output
Output files are generated, by default, in the following directories:

```
data_extracted/baseline/detail/
data_extracted/baseline/author/
data_extracted/baseline/mesh/
data_extracted/baseline/brief/

data_extracted/updatefiles/
data_extracted/updatefiles/detail/
data_extracted/updatefiles/author/
data_extracted/updatefiles/mesh/
data_extracted/updatefiles/brief/
```

### Config
* Rscripts in the `rscripts` directory
* The current launch configuration uses SLURM scheduling
    
### Running    
To start extraction without Slurm: run_xml_extractions_1_no_slurm.sh, which will run a batch job.
 
`run_xml_extractions_1_no_slurm.sh  (type) (config file) (process #) (total processes)`
        
 eg:
 
 ```
run_xml_extractions_1_no_slurm.sh detail rscripts/config_update.R 1 1
run_xml_extractions_1_no_slurm.sh mesh rscripts/config_update.R 1 1
run_xml_extractions_1_no_slurm.sh brief rscripts/config_update.R 1 1
run_xml_extractions_1_no_slurm.sh author rscripts/config_update.R 1 2
run_xml_extractions_1_no_slurm.sh author rscripts/config_update.R 2 2
```
