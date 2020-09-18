#get the config file name from the command line args
#
# Run:
#
#
#
# Rscript rscripts/briefExtraction.R  <rscripts/config_baseline.R> <process #>  <number processes>
#
# rscripts/config_baseline.R  :  The Config file
# process # :
# number of processes :


print ("Brief Extraction - start")

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
nodes <- matrix(c("PubDate/Year", "PubDate/MedlineDate", "Title", "PublicationType"))
# date
dates <- matrix(c("PubDate/Month", "PubDate/Day"))

####################################################################################
# Function    : extract_xml
# Description : Finds the value for the different xml nodes
# Args        : XML file
# Returns     : Dataframe containing values specific to each PMID
####################################################################################
extract_xml <- function(theFile) {

    tryCatch({

        library(XML)

        theFile2 = paste (drsc_input_dir, "/", theFile , sep = "")

        newData <- xmlParse(theFile2)

        records <- getNodeSet(newData, "//PubmedArticle")
        pmid <- as.numeric(xpathSApply(newData, "//MedlineCitation/PMID", xmlValue))

        for (i in 1 : length(nodes)) {
            # for pubDate node : concatenate year/month/day to form a date
            if (nodes[i] == "PubDate/Year") {
                year <- lapply(records, xpathSApply, paste(".//", nodes[i]), xmlValue)
                year[sapply(year, is.list)] <- NA
                month <- lapply(records, xpathSApply, paste(".//", dates[1]), xmlValue)
                if (is.numeric(month)) {
                    month <- month.abb[month] # convert to abbreviation
                }
                day <- lapply(records, xpathSApply, paste(".//", dates[2]), xmlValue)
                pubDate <- mapply(paste, year, month, day) # concatenate
                pubDate_year <- ifelse(is.na(year), 'NA', year)
                pubDate <- unlist(pubDate)
                pubDate_year <- unlist(pubDate_year)
            }
            # rest of the nodes
            else {
                temp <- lapply(records, xpathSApply, paste(".//", nodes[i]), xmlValue)
                temp[sapply(temp, is.list)] <- NA
                temp <- sapply(temp, paste, collapse = "|")
                temp <- unlist(temp)

                if (nodes[i] == "PubDate/MedlineDate")
                medlineDate <- temp
                medlineDate_year <- substr(medlineDate, 1, 4)
                if (nodes[i] == "Title")
                journalTitle <- temp
                if (nodes[i] == "PublicationType")
                ptype <- temp
            }
        }
        # create data frame with the found values as columns
        Brief <- data.frame(pmid, journalTitle, pubDate, pubDate_year, medlineDate, medlineDate_year, ptype, stringsAsFactors = FALSE)

        # sort the data frame in ascending order of the pmid
        Brief <- arrange(Brief, pmid)

        # return data frame
         return(Brief)
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
print ("Start Main - Brief  Extraction")
print ("")


library(plyr)


filenames <- list.files(path = drsc_input_dir, full.names = FALSE, pattern = "*.xml$")
files <- matrix(filenames)
pmidfilename <- paste(drsc_download_root__dir, "/all_pmids.txt", sep = "");

# Load PMIDS, used to filter results.

if (file.exists(pmidfilename)) {
  print (paste("loading valid pmids" , pmidfilename));
  pmid_df <- read.table(pmidfilename , header = FALSE, sep = "\t", quote = "\"")
  allpmids <- as.list(pmid_df)[[1]]
} else {
  #let it crash,  we need this file to run.
  #allpmids = list();
  print (paste("*** pmid file not found, including all results" , pmidfilename));
}




for (j in 1 : length(files)) {

    filebase = paste (drsc_output_dir, "/brief/brief_", gsub(".xml", ".txt", files[j], fixed = TRUE), sep = "")


    if (!(j %% numberProcesses == processMatch)){
        print (paste("skip: match file/process: ", j ," - ", numberProcesses ))
        next
    }


    if(!file.exists(filebase)){

        # calling function
        Brief <- extract_xml(files[j])

        if (length(Brief) > 0 ) {

            if (length(allpmids) > 0) {
                BriefClean <- Brief[Brief$pmid %in% allpmids,]
            } else {
                BriefClean <- Brief;
            }

            if (length(BriefClean) > 0 ) {

                #output informational results
                print (paste("--- brief: size before filtering:", dim(Brief)[1]))
                print (paste("--- brief: size after filtering:", dim(BriefClean)[1]))

                write.table(BriefClean, filebase, row.names = FALSE, sep = "\t", quote = FALSE)
            }
        }
    } else {

        print (paste ("file already exists:", filebase))

    }

}

print ("done.")
