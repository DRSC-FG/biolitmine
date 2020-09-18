#get the config file name from the command line args
#
# Run:
#
#
#
# Rscript rscripts/authorExtraction.R  <rscripts/config_baseline.R> <process #>  <number processes>
#
# rscripts/config_baseline.R  :  The Config file
# process # :
# number of processes :

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



nodes <- matrix(c("Author/LastName", "Author/ForeName", "Author/Initials"))
affNode <- c("Author/AffiliationInfo")

####################################################################################
# Function    : extract_xml
# Description : Finds the value for the different xml nodes
# Args        : XML file
# Returns     : Dataframe containing values specific to each PMID
####################################################################################
extract_xml <- function(theFile) {

    tryCatch({

        library(XML)
        library(splitstackshape)
        library(stringi)

        theFile2 = paste (drsc_input_dir, "/", theFile , sep = "")


        newData <- xmlParse(theFile2)
        records <- getNodeSet(newData, "//PubmedArticle")
        PMID <- as.numeric(xpathSApply(newData, "//MedlineCitation/PMID", xmlValue))

        for (i in 1 : length(nodes)) {
            temp <- lapply(records, xpathSApply, paste(".//", nodes[i]), xmlValue)
            temp[sapply(temp, is.list)] <- NA
            temp <- sapply(temp, paste, collapse = "|")
            temp <- unlist(temp)

            if (nodes[i] == "Author/LastName")
            LastName <- temp
            if (nodes[i] == "Author/ForeName")
            ForeName <- temp
            if (nodes[i] == "Author/Initials")
            Initials <- temp
        }

        for (i in 1 : length(affNode)) {
            temp <- lapply(records, xpathSApply, paste(".//", affNode[i], "[1]"), xmlValue)
            temp[sapply(temp, is.list)] <- NA
            temp <- sapply(temp, paste, collapse = "|")
            temp <- unlist(temp)

            if (affNode[i] == "Author/AffiliationInfo")
            Affiliations <- temp
        }

        # create data frame with the found values as columns
        authorDF <- data.frame(PMID, LastName, ForeName, Initials, Affiliations, stringsAsFactors = FALSE)
        authorDF <- data.frame(cSplit(authorDF, c("LastName", "ForeName", "Initials", "Affiliations"), "|", direction = "long"))

        # remove the rows with missing author last name values
        authorDF <- authorDF[- which(is.na(authorDF$LastName)),]
        # sort the data frame in ascending Order of the PMID
        authorDF <- arrange(authorDF, PMID)
        # set count equal to 1
        count <- 1
        # set default value of authorDF Order to 1
        authorDF$Order[1] <- count

        # iterate through whole authorDF dataframe
        for (i in 2 : nrow(authorDF)) {
            # assign the PMID of the earlier record
            PMID1 <- authorDF$PMID[i - 1][1]
            # assign the PMID of the current record
            PMID2 <- authorDF$PMID[i][1]
            # checks if both PMIDs are both
            if (PMID1 == PMID2)
            # increment the count
            count <- count + 1
            # else
            else
            # set count again to 1
            count <- 1
            # populate the Order for that record to count value
            authorDF$Order[i] <- count
        }

        for (i in 1 : nrow(authorDF)) {
            order1 <- authorDF$Order[i]
            order2 <- authorDF$Order[i + 1]

            if (is.na(order2)) {
                authorDF$LastAuthor[i] <- 'Y'
                break;
            }
            if (order1 < order2)
            authorDF$LastAuthor[i] <- 'N'

            if (order1 == order2)
            authorDF$LastAuthor[i] <- 'Y'

            if (order1 > order2)
            authorDF$LastAuthor[i] <- 'Y'

            if (! is.na(authorDF$Affiliations[i])) {
                temp <- gsub("\\", " ", authorDF$Affiliations[i], fixed = TRUE)
                temp <- gsub("(", " ", temp, fixed = TRUE)
                temp <- gsub(")", " ", temp, fixed = TRUE)
                temp <- gsub("\n", " ", temp, fixed = TRUE)
                temp <- gsub("\t", " ", temp, fixed = TRUE)
                temp <- iconv(temp, to = "ASCII//TRANSLIT")
                temp <- gsub("\"", "", temp, fixed = TRUE)

                str <- matrix(c("Email:", "Email :", "E-mail:", "E-mail :", "Electronic address:"))
                found <- FALSE

                for (j in 1 : length(str)) {
                    len <- nchar(str[j])
                    test <- grepl(str[j], temp, fixed = TRUE)
                    if (test == TRUE) {
                        pos <- regexpr(str[j], temp, ignore.case = FALSE)
                        authorDF$Address[i] <- substr(temp, 0, pos - 1)
                        authorDF$Email[i] <- substr(temp, pos + (len + 1), nchar(temp))
                        found <- TRUE
                        break;
                    }
                    if (test == FALSE)
                    next;
                }


                if (found == FALSE) {

                    #Find all emails in text body

                    #email_addr <- unlist(stri_match_all_regex(as.character(temp, 1), "[a-zA-Z0-9._-]+\\@.[^\\s]*"))
                    email_addr <- unlist(stri_match_all_regex(as.character(temp, 1), "[a-zA-Z0-9._-]+\\@[a-zA-Z0-9._-]*"))

                    l <- length(email_addr)

                    if (is.na(email_addr)) {
                        # extract email address from affiliation column
                        authorDF$Email[i] <- NA
                        # extract the remaining adddress part from affiliation
                        authorDF$Address[i] <- as.character(temp)
                    }
                    else {
                        #print (email_addr)
                        if (l == 1)
                        email <- email_addr

                        if (l > 1) {
                            email <- email_addr[1]
                            for (k in 2 : l) {
                                email <- paste(email, email_addr[k])
                            }
                        }

                        # extract email address from affiliation column
                        authorDF$Email[i] <- email
                        # extract the remaining adddress part from affiliation
                        authorDF$Address[i] <- ifelse(! is.na(authorDF$Email[i]), mapply(gsub, email_addr, '', as.character(temp)), as.character(temp))
                    }
                }
            }
            if (is.na(authorDF$Affiliations[i])) {
                authorDF$Email[i] <- NA
                authorDF$Address[i] <- NA
            }
        }

        pubmed_id1 <- 0

        #
        # Fill in new address.
        #

        for (z in 1 : nrow(authorDF)) {

            # do we need to clear this, incase it doesn't clear on its own.?  amc 2018
            #addr1 ='';

            if (! is.na(authorDF$Address[z])) {
                pubmed_id1 = authorDF$PMID[z]
                addr1 = authorDF$Address[z]
                authorDF$Addr[z] <- addr1
            }

            if (is.na(authorDF$Address[z])) {
                pubmed_id2 = authorDF$PMID[z]
                if (pubmed_id2 == pubmed_id1) {
                    authorDF$Addr[z] <- addr1
                }
                else
                authorDF$Addr[z] <- NA
            }
        }

        # remove unwanted columns
        Article2AuthorMapping <- authorDF[, c("PMID", "LastName", "ForeName", "Initials", "Order", "LastAuthor", "Email", "Address", "Addr")]
        # sort table on PMID
        Article2AuthorMapping <- arrange(Article2AuthorMapping, PMID)
        # return data frame
        return(Article2AuthorMapping)
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
print ("Start Main - Author Extraction")
print ("")

library(plyr)

# print (drsc_input_dir)

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



    filebase = paste (drsc_output_dir, "/author/tempauthor_" , gsub(".xml", ".txt", files[j], fixed = TRUE),   sep = "")

    if (!(j %% numberProcesses == processMatch)){
        print (paste("skip: match file/process: ", j ," - ", numberProcesses ))
        next
    }




    if(!file.exists(filebase)){

         # calling function
         #print ("----- XML Read loop ------ ")
         #print (files[j])

        Article2AuthorMapping <- try(extract_xml(files[j]))

        if (length(Article2AuthorMapping) > 0 ) {

            if (length(allpmids) > 0 ) {
              Article2AuthorMappingClean <- Article2AuthorMapping[Article2AuthorMapping$PMID %in% allpmids,]
            } else {
              Article2AuthorMappingClean <- Article2AuthorMapping;
            }

            #output informational results
            print (paste("--- author:  size before filtering:", dim(Article2AuthorMapping)[1]))
            print (paste("--- author:  size after filtering:", dim(Article2AuthorMappingClean)[1]))


            write.table(Article2AuthorMappingClean, filebase, sep = "\t", row.names = FALSE, quote = FALSE)
        }
    } else {

        print (paste ("file already exists:", filebase))

    }

}

print ("done.")
