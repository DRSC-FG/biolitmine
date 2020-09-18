## `download_pubmed_` Folder

This folder contains two Perl scripts that are responsible for downloading files from the NCBI ftp site.

* `get_new_gene2pubmed.pl` - Downloads a zipped file that contains the mapping relationship between publications and genes
* `get_pubmed_xml.pl` - Downloads all the zipped XML files (either from `baseline` or `updatefiles`) in PubMed. If any new zipped files are found, the files will be extracted


### Example Usage

**Download the latest gene2pubmed file**
This script requires one parameter to be passed: `dir`. `dir` will tell the script where the file will be downloaded. 

For example, the following command will download `gene2pubmed.gz` to a directory called `downloads`:

```
perl get_new_gene2pubmed.pl -dir downloads
```

**Download the latest PubMed XML files**
This script require two parameters: `dir` and `type`. `dir` will tell the script where the files will be downloaded and extracted, `type` will dictate which XML will be downloaded. 

For example, the following command will download all `/pubmed*.xml.gz` files from `updatefiles` into the `downloads/updatefiles` directory:

```
perl get_pubmed_xml.pl -dir downloads/updatefiles -type updatefiles
```

### Download Sources
* [NCBI Gene Files](ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/)
* [PubMed](ftp://ftp.ncbi.nlm.nih.gov/pubmed/)
