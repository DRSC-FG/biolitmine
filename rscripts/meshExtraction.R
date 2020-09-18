#get the config file name from the command line args
#
# Run:
#
#
#
# Rscript rscripts/meshExtraction.R  <rscripts/config_baseline.R> <process #>  <number processes>
#
# rscripts/config_baseline.R  :  The Config file
# process # :
# number of processes :



print ("Mesh Extraction - start")

args <- commandArgs(TRUE)

configFile <- args[1]
processNumber <- strtoi(args[2])
numberProcesses <- strtoi(args[3])

if (is.na(processNumber) | is.na(numberProcesses)   ){
    processNumber = 1
    numberProcesses =1
}
processMatch = processNumber-1;


source(configFile)


.libPaths(c(.libPaths(), r_library_path))

# nodes we want to extract values from
nodes <- matrix(c("DescriptorName"))

####################################################################################
# Function    : extract_xml
# Description : Finds the value for the different xml nodes
# Args        : XML file
# Returns     : Dataframe containing values specific to each PMID
####################################################################################
extract_xml <- function(theFile, pmid_df) {
    tryCatch({
        library(XML)
        library(splitstackshape)
        library(stringi)

        theFile2 = paste (drsc_input_dir, "/", theFile , sep = "");


        print ("+------------------+<<")
        print (theFile2)
        newData <- xmlParse(theFile2)
        records <- getNodeSet(newData, "//PubmedArticle")
        PMID <- as.numeric(xpathSApply(newData, "//MedlineCitation/PMID", xmlValue))

        for (i in 1 : length(nodes)) {
            temp <- lapply(records, xpathSApply, paste(".//", nodes[i], "/@UI"))
            temp[sapply(temp, is.list)] <- NA
            temp <- sapply(temp, paste, collapse = "|")
            temp <- unlist(temp)

            DescriptorName <- temp
        }


        # create data frame with the found values as columns
        meshDF <- data.frame(PMID, DescriptorName, stringsAsFactors = FALSE)
        # split the column values on "|" longitudinally
        meshDF <- data.frame(cSplit(meshDF, c("DescriptorName"), "|", direction = "long"))
        # remove unwanted columns
        Article2MeshMapping <- meshDF[, c("PMID", "DescriptorName")]
        # sort table on PMID
        Article2MeshMapping <- arrange(Article2MeshMapping, PMID)
        # create a unique ID column
        # Article2MeshMapping$MappingID <- seq(1:nrow(Article2MeshMapping))
        # return data frame
        return(Article2MeshMapping)
    },
    error = function(cond){

        print (paste("*** error in file: ", theFile2))
        write(paste("*** error in file - skipping: ", theFile2), stderr())

        print (cond)
        write(cond, stderr())

        print ("+---skipping that file -----+\n")

        # return empty data frame

        blank_return <- vector();
        return(blank_return);

    },
    finally = function(cond){
    }
    )
}



#########################
# Main
#########################

print ("+--------------------------------+")
print ("Start Main - Mesh Extraction")
print("")

library(plyr)


filenames = list.files(path = drsc_input_dir, full.names = FALSE, pattern = "*.xml$")
files <- matrix(filenames)
pmidfilename <- paste(drsc_download_root__dir, "/all_pmids.txt", sep = "");

# Load PMIDS, used to filter results.

if (file.exists(pmidfilename)) {
    print (paste("loading valid pmids" , pmidfilename));
    pmid_df <- read.table(pmidfilename, header = FALSE, sep = "\t", quote = "\"")
    allpmids <- as.list(pmid_df)[[1]]
} else {
    #let it crash,  we need this file to run.
    #allpmids = list();
    print (paste("*** pmid file not found, including all results" , pmidfilename));
}




for (j in 1 : length(files)) {


    filebase = paste (drsc_output_dir, "/mesh/mesh_", gsub(".xml", ".txt", files[j], fixed = TRUE), sep = "")


    if (!(j %% numberProcesses == processMatch)){
        print (paste("skip: match file/process: ", j ," - ", numberProcesses ))
        next
    }


    if (! file.exists(filebase)) {


        Article2MeshMapping <- try(extract_xml(files[j], pmid_df))

        if (length(Article2MeshMapping) > 0 ) {

            #filter pmids that aren't in file

            if (length(allpmids) > 0) {
                Article2MeshMappingClean <- Article2MeshMapping[Article2MeshMapping$PMID %in% allpmids,]
            } else {
                Article2MeshMappingClean <- Article2MeshMapping;
            }

            #output informational results
            print (paste("--- mesh: size before filtering:", dim(Article2MeshMapping)[1]))
            print (paste("--- mesh: size after filtering:", dim(Article2MeshMappingClean)[1]))


            write.table(Article2MeshMappingClean, filebase, sep = "\t", row.names = FALSE, quote = FALSE)
        }
    } else {
        print (paste ("file already exists:", filebase))
    }
}

print ("done.")
