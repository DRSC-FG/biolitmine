## `download` Folder

This folder contains two Perl scripts that are responsible for downloading files from the NCBI ftp site.

Script | Description
------ | -----------
`get_new_gene2pubmed.pl` | Downloads a zipped file that contains the mapping relationship between publications and genes
`get_pubmed_xml.pl` | Downloads all the zipped XML files (either from `baseline` or `updatefiles`) in PubMed. If any new zipped files are found, the files will be extracted

This folder also contains a shell script that is responsible for downloading files from the NIH ftp site.

Script | Description
------ | -----------
`download_mesh.sh` | Downloads the current MeSH Descriptor file in ASCII format

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

**Download the latest MeSH Descriptor file**

This script will automatically determine the current year and download that year's MeSH Descriptor file to the `downloads/mesh_files/` directory. It will also remove any previous Descriptor files currently in the directory.

For example, if the following command was run in 2018, it will download `d2018.bin` to the `downloads/mesh_files/` directory:

```
sh download_mesh.sh
```

### Download Sources
* [NCBI Gene Files](ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/)
* [PubMed](ftp://ftp.ncbi.nlm.nih.gov/pubmed/)
* [NIH MeSH Data](https://www.nlm.nih.gov/databases/download/mesh.html)
