# biolitmine
**Public Repository for BioLitMine Source Code**

[BioLitMine](https://www.flyrnai.org/tools/biolitmine) is a tool that leverages PubMed literature to find relationships between genes, MeSH terms, pathways, and authors. This repository contains code used to download and extract information from various sources to find these relationships.

## Download Data

To start, all literature on PubMed will be downloaded via the NLM ftp site as zipped XML files. NLM provides two types of PubMed data:

Type | Data | BioLitMine Download Schedule
---- | ---- | ----------------------------
`baseline` | baseline set of MEDLINE/PubMed citation records | End of the year
`updatefiles` | daily file updates that include new, revised, and deleted citations | End of the month

MeSH Descriptor information and MeSH tree numbers are also downloaded on an annual basis.

All data are downloaded into a directory called `data_input`, and the code to download is located in `download`.


## Extract XML Information

XML files are then extracted into tabular format using the R scripts in `rscipts`.

There are two configuration files where the default directories can be inspected and changed: `rscript/config_baseline.R` and `rscript/config_update.R`.

The extraction creates 4 output files that contain different information:

Output Files | Information
------------ | -----------
`brief_*.txt` | Literature overview, including PMID, journal title, publication/MEDLINE date, and publication type
`detail_*.txt` | Literature details, including PMID, journal title, publication/MEDLINE date, and abstract
`mesh_*.txt` | Literature MeSH details, including PMID and MeSH Descriptor name
`tempauthor_*.txt` | Author details, including first name, last name, affiliations, address, email, and associated PMIDs


## Further Data Preparation
 
Finally, the extracted information is further processed by scripts found in `extract`.  Steps taken include filtering out publications not related to the study of model organisms and humans, merging files together, etc.
 
