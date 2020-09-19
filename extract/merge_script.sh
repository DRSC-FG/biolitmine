#!/usr/bin/env bash


############ Block 0 ############
# Remove headers and combine files
tail -q -n +2 data_extracted/baseline/brief/*brief_* > data_extracted/combined/combinedBrief.txt
tail -q -n +2 data_extracted/updatefiles/brief/*brief_* >> data_extracted/combined/combinedBrief.txt

tail -q -n +2  data_extracted/baseline/author/*author_* >  data_extracted/combined/combinedAuthor.txt
tail -q -n +2  data_extracted/updatefiles/author/*author_* >>  data_extracted/combined/combinedAuthor.txt

tail -q -n +2 data_extracted/baseline/mesh/*mesh_* >  data_extracted/combined/combinedMesh.txt
tail -q -n +2 data_extracted/updatefiles/mesh/*mesh_* >>  data_extracted/combined/combinedMesh.txt

tail -q -n +2 data_extracted/baseline/detail/*detail_* >  data_extracted/combined/combinedDetail.txt
tail -q -n +2 data_extracted/updatefiles/detail/*detail_* >>  data_extracted/combined/combinedDetail.txt


############ Block 1 ############
# Removing Duplicates in each file
# Output files stored in "uniq_records" folder
for eachfile in `ls -a  data_extracted/combined/combined*.txt`
do
    echo first $eachfile

    newfile=uniq.$(basename $eachfile)
    echo firstoutput $newfile

    # pos[$1] will store the record number of each record when was last seen
    # reverse[] uses record number as keys 
    # print in ascending order of the indices
    awk '{
        pos[$0] = NR; lines[$0] = $0
    }
    END{
        for(key in pos) reverse[pos[key]] = key
        for(nr=1; nr<=NR; nr++)
            if(nr in reverse) print lines[reverse[nr]]
    }' $eachfile > "data_extracted/combined/unique_records/"$newfile
done


############ Block 2 ############
# Increasing size of PMID column in each file
# Output files stored in "after_increase" folder
mkdir -p data_extracted/combined/after_increase/

for tempfile in `ls -a data_extracted/combined/unique_records/uniq.*`
do
    echo second $tempfile
    sub="uniq"
        awk '{$1=sprintf("%10d",$1)}7' FS='\t' OFS='\t' $tempfile > "data_extracted/combined/after_increase/"new.${tempfile/*$sub/$sub}
done


############ Block 3 ############
# Sorting the final file with column 1
mkdir -p  data_extracted/combined/sorted
sort -b -n -k1 "data_extracted/combined/after_increase/new.uniq.combinedAuthor.txt" > data_extracted/combined/sorted/authors2pubmed.txt 
sort -b -n -k1 "data_extracted/combined/after_increase/new.uniq.combinedBrief.txt" > data_extracted/combined/sorted/brief_info.txt
sort -b -n -k1 "data_extracted/combined/after_increase/new.uniq.combinedMesh.txt" > data_extracted/combined/sorted/mesh2pubmed.txt
sort -b -n -k1 "data_extracted/combined/after_increase/new.uniq.combinedDetail.txt" > data_extracted/combined/sorted/detail2pubmed.txt
echo "+-------------------------+"
echo "Done"


############ Print Summary Report ############ 
echo "+-------------------------+ Results"
tree --du -hD data_extracted/combined

echo "+-------------------------+ Counts"
wc -l data_extracted/combined/*.txt
mkdir -p data_extracted/combined/unique_records/
echo "... /unique_records"
wc -l data_extracted/combined/unique_records/*.txt
echo "... /after_increase"
wc -l data_extracted/combined/after_increase/*.txt
echo "... /sorted"
wc -l data_extracted/combined/sorted/*.txt
