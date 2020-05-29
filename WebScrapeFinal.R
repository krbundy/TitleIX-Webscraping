library(tidyverse)
library(rvest)
library(RSelenium)
library(httr)
library(xml2)
library(stringr)
library(tidytext)


# Set up test page URLs
testURL <- "https://www.regulations.gov/document?D=ED-2018-OCR-0064-1655"
saveFilePath <- "C:/Users/kenne/Documents/TitleIXComments_part2.csv"


# Open Selenium Server and Navigate to page
rd <- rsDriver(port = 4472L, browser = "firefox")
remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4472L, browserName = "firefox")
remDr$open(silent = TRUE)
remDr$navigate(testURL)


# Create Data Frame to hold the data
# Columns: CommentID, CommentText, URL, Name, Category, Location, Date

scrapedData <- data.frame(matrix(nrow=0, ncol=7 ))
colnames(scrapedData) <- c("CommentID", "CommentText", "URL", "Name", "Category", "Location", "Date")

#read in past data
#scrapedData <- read.csv(saveFilePath)

#Set loop parameters
waitTime <- 3
offset <- 28735#100+number of completed records
skips <- 17

#Start the loop through the webpages

for (i in (offset+skips+length(scrapedData$Name)):124158){
  currentURL <- paste("https://www.regulations.gov/document?D=ED-2018-OCR-0064-", i, sep="", collapse = NULL)
  
  #add leading 0 for 2-digit numbered sites
  if(i<1000 && i>99){
    currentURL <- paste("https://www.regulations.gov/document?D=ED-2018-OCR-0064-", "0", i, sep="", collapse = NULL)
}
  
  remDr$navigate(currentURL)
  Sys.sleep(waitTime) #Wait for the page to load
  try(pageData <- read_html(remDr$getPageSource()[[1]]),silent = TRUE)
  
  # extract the comment from HTML file and convert to text
  
  page_data_html <- html_node(pageData,".GIY1LSJIXD")
  page_data_text <- html_text(page_data_html)

  
  #Extract the Comment Metadata (ID, tracking number)
  pd2<- html_node(pageData, ".GIY1LSJJJD")
  pd2_text <- html_text(pd2)
  
  #Extract the commenter information (Name, location, etc)
  pd3 <- html_nodes(pageData, ".GIY1LSJNTC")
  pd3_text <- html_text(pd3)
  
  
  #DO some NLP (tidytext) to get the information from the strings
  
  #Get the comment text into a tibble (not required)
  
  if(!is_empty(page_data_text)){
  commentData <- tibble(line=c(1), text=page_data_text)
  
  commentData_clean <- commentData %>%
    unnest_tokens(word, text, to_lower = FALSE)
  
  
  # Get the ID number into the correct format for storage
  idData <- tibble(line = c(1), text = pd2_text)
  
  idData_clean <- idData %>% 
    unnest_tokens(word,text, to_lower = FALSE)
  
  commentID <- paste(idData_clean[2,2],idData_clean[3,2],idData_clean[4,2],
                     idData_clean[5,2],idData_clean[6,2], sep = "-")
  
  
  # Extract and format the date
  
  currentDate <- "N/A"
  
  dateData <- tibble(line = 1:length(pd3_text), text = pd3_text)
  
  dateData_clean <- dateData %>% 
    unnest_tokens(word,text, to_lower = FALSE)
  
  year <- "2019"
  if(!is.na(dateData_clean[3,2])){
  if(dateData_clean[3,2] == "Dec"){
    year <- "2018"
  }
  
  currentDate <- paste(dateData_clean[3,2], dateData_clean[4,2], year, sep = " ")
  }else{
    currentDate <- "N/A"
  }
  # Now pull out the name
  nameIndex <- grep("Name", as.character(dateData_clean$word))
  
  lastname <- gsub("City", "", dateData_clean[(nameIndex+2),2])
  fixedName <- paste(dateData_clean[nameIndex+1,2],gsub("Category", "", lastname), sep = " ")
  
  
  #Category
  categoryIndex <- grep("Category", as.character(dateData_clean$word))
  category <- as.character(dateData_clean[categoryIndex+1,2])
  
  #get the address
  
  cityIndex <- grep("City", as.character(dateData_clean$word))
  stateIndex <- grep("Province", as.character(dateData_clean$word))
  
  if(!is_empty(cityIndex)){
    city <- gsub("Country", "", dateData_clean[cityIndex+1,2])
  }else{
    city <- "N/A"
  }
  
  if(!is_empty(stateIndex)){
    state <- gsub("Category", "", dateData_clean[categoryIndex,2])
  }else{
    state <- "N/A"
  }
  
  fixedAddress <- paste(city, state, sep = ", ")
  
  #calculate the proper data frame index
  
  dfIndex <- length(scrapedData$Name)+1
  
  # Add to DF in this order; c("CommentID", "CommentText", "URL", "Name", "Category", "Location", "Date")
  
  scrapedData[dfIndex,] <- c(commentID,page_data_text,currentURL,fixedName, category, fixedAddress, currentDate)
  }
}
 
  


remDr$close()

write.csv(scrapedData,saveFilePath)