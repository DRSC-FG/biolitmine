#!/usr/bin/env bash

#cd /n/groups/flyrnai/scripts/pubmed/

############ Block 0 ##################################
###Remove headers and combine files


#removed temp to save files

tail -q -n +2 data_extracted/baseline/brief/*brief_* > data_extracted/combined/combinedBrief.txt
tail -q -n +2 data_extracted/updatefiles/brief/*brief_* >> data_extracted/combined/combinedBrief.txt

tail -q -n +2  data_extracted/baseline/author/*author_* >  data_extracted/combined/combinedAuthor.txt
tail -q -n +2  data_extracted/updatefiles/author/*author_* >>  data_extracted/combined/combinedAuthor.txt

tail -q -n +2 data_extracted/baseline/mesh/*mesh_* >  data_extracted/combined/combinedMesh.txt
tail -q -n +2 data_extracted/updatefiles/mesh/*mesh_* >>  data_extracted/combined/combinedMesh.txt

tail -q -n +2 data_extracted/baseline/detail/*detail_* >  data_extracted/combined/combinedDetail.txt
tail -q -n +2 data_extracted/updatefiles/detail/*detail_* >>  data_extracted/combined/combinedDetail.txt

############ Block 1 ###################################
### Removing Duplicates in each file
### output files stored in "uniq_records" folder

#mkdir "uniq_records"

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
#########################################################


############## Block 2 ###################################
#### Increasing size of PMID column in each file
#### output files stored in "after_increase" folder

#mkdir "after_increase"

mkdir -p data_extracted/combined/after_increase/

for tempfile in `ls -a data_extracted/combined/unique_records/uniq.*`
do
    echo second $tempfile
    sub="uniq"
        awk '{$1=sprintf("%10d",$1)}7' FS='\t' OFS='\t' $tempfile > "data_extracted/combined/after_increase/"new.${tempfile/*$sub/$sub}
done
#########################################################
#
#  AMC - July 2019 these are commented out.  I'm not sure they work or are useful
#
########################### FUNCTION #####################
#### Compare two input files(file1, file2) and store unique rows from file2 in new file(file3) at "Uniq" folder
#### Compare two input files(file1, file2) and store duplicate rows from file2 in new file(file4) at "Dup" folder
#### Concatenate input file(file1) with file3
#
#merge(){
#        # compare two files with column 1 of both files and print the unique rows of file2 in new file(file3)
#        awk 'NR==FNR{c[$0]++;next};c[$0]==0' $1 $2 > "Uniq/"uniqIn.$((length-j))
#        # compare two files with column 1 of both files and print the duplicate rows of file2 in new file(file4)
#        # extra step just to compare the size of files
#        awk 'NR==FNR{c[$0]++;next};c[$0]>0' $1 $2 > "Dup/"dupIn.$((length-j))
#        # merge file1 and file3
#        cat $1 "Uniq/"uniqIn.$((length-j)) > "Merge/"mergedWith$((length-j))
#
#}
########################### End #######################################


###################### Block 3 ########################################
####Taking 2 input files for Merge function from "afterIncreasingSize" folder
#
## assign filenames of files in the directory with "new.uniq" prefix
#files=("afterIncreasingSize/"new.uniq*)
#
## find the length of array
#length=${#files[@]}
#
## assigning first file1 i.e. the most updated one
#file1=${files[$length-1]}
#
#### file1 is the last file & file2 will be second last and so on...
#
## for loop
#for((i = 2; i<=$length; i++));
#do
#
#    # assigning file2
#    file2=${files[$length-$i]}
#
#    echo third $file1
#    echo fourth $file2
#
#    j=$((i-1))
#
#    # calling function
#    merge $file1 $file2
#    
#    # assigning the merged result as file1 for next processing
#    file1="Merge/"mergedWith$((length-j))
#
#done
##########################################################################


####################### Block 4 ##########################################

## sorting the final file with column 1
#sort -b -n -k1 "Merge/"mergedWith1 > TempArticle2AuthorMapping.txt
mkdir -p  data_extracted/combined/sorted
sort -b -n -k1 "data_extracted/combined/after_increase/new.uniq.combinedAuthor.txt" > data_extracted/combined/sorted/authors2pubmed.txt 
sort -b -n -k1 "data_extracted/combined/after_increase/new.uniq.combinedBrief.txt" > data_extracted/combined/sorted/brief_info.txt
sort -b -n -k1 "data_extracted/combined/after_increase/new.uniq.combinedMesh.txt" > data_extracted/combined/sorted/mesh2pubmed.txt
sort -b -n -k1 "data_extracted/combined/after_increase/new.uniq.combinedDetail.txt" > data_extracted/combined/sorted/detail2pubmed.txt
###########################################################################
echo "+-------------------------+"
echo "done"
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


