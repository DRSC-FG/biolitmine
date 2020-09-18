## `extract_pubmed` Folder

This folder contains 8 Perl scripts that are responsible for extracting information from `gene2pubmed` and the publication XMLs into tabular-formatted files. These output files are used to update/populate the `biolitmine` database.

* `create_mesh_files.pl` - Outputs two files: `mesh_info.txt` which contains information about each MeSH term; and `mesh_lookup.txt` which maps each parent MeSH term to their children.
* `create_pi_files.pl` - Outputs two files: `pi2pubmed.txt` which lists all the authors of each publication; and `pi_info.txt` which contains information about each PI (including their number of total publications).
* `filter_gene2pubmed.pl` - Filters through publications, keeping only those with a focus or is related to the study of model organisms and humans.
* `find_cocitations.pl` - Outputs a file (`gene2gene.txt`) that maps and keeps tally of a gene that has been studied along with another gene in a publication.
* `precompute_gene_pmids.pl` - Outputs a file (`gene_pmids.txt`) that maps a gene to a list of associated publications.
* `precompute_mesh_pmids.pl`- Outputs a file (`mesh_pmids.txt`) that maps a MeSH ID to a list of associated publications. 
* `precompute_mesh2gene.pl` - Outputs a file (`mesh2gene*.txt`) that maps a gene to a list of associated MeSH terms.
* `precompute_path2pi.pl` - Outputs a file (`pathway2pi.txt`)

**Note:**
`precompute_mesh2gene.pl` has one optional parameter: `-child`. If passed, then the script will map a gene to a MeSH term along with all its child MeSH terms.
