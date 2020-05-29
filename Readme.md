# Title IX Data Mining

In 2018, the US Department of Education proposed rules changes to related to Title IX implementation at Universities across the United States.  These changes, in my opinion, reduce the scope of protections for students and make the process more traumatic for those filing a complaint.  I heard of a group of researchers hand-cataloguing the comments, so I offered to help download the comments for their analysis.  

This file was developed for mining (webscraping) all of the public comments on title IX rules changes by the Department of Education in 2018.  The file uses R Selenium to pull the comments sequentially. Data cleaning was done separately.

## Getting Started

The script is designed to run on R version 3.1.4 and above.  It requires RSelenium, tidyverse, tidytext, xml2, and httr packages.  

The file uses Firefox by default, but another web browser can be used by changing 

```
rd <- rsDriver(port = 4472L, browser = "firefox")
remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4472L, browserName = "firefox")
```
 and replacing "firefox" with any other browser supported by Selenium.

Once the dependencies are installed, simply run the file.  

If you need to restart the scraping after it crashes, you can change the 'offset' variable to the index of the last page that completed successfully (should still be open in Firefox).


## Development Notes

Since the websites are rendered via JavaScript, PhantomJS is the natural candidate.  However PhantomJS is built on an old version of JavaScript and the website does not render properly.  This file uses Firefox as a work around, as Firefox is able to render the website via a more updated JavaScript engine.  Chrome would also work well (fastest JS engine, actually).

Furthermore, the load time for the site is quite long (slow REST endpoint?) so adding some delay between page loads was necessary.  Also, a handful of pages did not render properly and were skipped (17 in over 120000, to wit).  

## Authors

This code was written by Kenneth R. Bundy


