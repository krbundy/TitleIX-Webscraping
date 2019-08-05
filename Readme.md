# Title IX Webscraping

This file was developed for webscraping all of the public comments on title IX rules changes by the Department of Education.  The file uses R Selenium to pull the comments sequentially. 

## Getting Started

The script is designed to run on R version 3.1.4 and above.  It requires RSelenium, tidyverse, tidytext, xml2, and httr packages.  

The file uses Firefox by default, but another web browser can be used by changing 

```
rd <- rsDriver(port = 4472L, browser = "firefox")
remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4472L, browserName = "firefox")
```
 and replacing "firefox" with any other browser supported by Selenium.  

Once the dependencies are installed, simply run the file.  


## Development Notes

Since the wesites are rendered via Javascript, PhantomJS is the natural candidate.  However the PhantomJS is built on an old version of Javascript, meaning that the website does not render properly.  This file uses Firefox as a work around, as Firefox is able to 



## Authors

* **Kenneth R. Bundy** 

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* 