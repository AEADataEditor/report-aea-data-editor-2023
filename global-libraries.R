
####################################
# global libraries used everywhere #
####################################


ppm.date <- "2023-11-01"
options(repos=paste0("https://packagemanager.posit.co/cran/",ppm.date,"/"))


global.libraries <- c("dplyr","here","tidyr","tibble","stringr",
                      "readr",
                      "splitstackshape","digest","remotes","readxl","writexl",
                      "ggplot2","ggthemes","janitor","dataverse","xtable")

########################################################
# Functions
########################################################

pkgTest <- function(x)
{
  if (!require(x,character.only = TRUE))
  {
    install.packages(x,dep=TRUE)
    if(!require(x,character.only = TRUE)) stop("Package not found")
  }
  return("OK")
}

pkgTest.github <- function(libname,source,pkgname=libname)
{
  if (!require(libname,character.only = TRUE))
  {
    if ( pkgname == "" ) { pkgname = libname }
    message(paste0("installing from ",source,"/",pkgname))
    remotes::install_github(paste(source,pkgname,sep="/"))
    if(!require(libname,character.only = TRUE)) stop(paste("Package ",x,"not found"))
  }
  return("OK")
}

results <- sapply(as.list(global.libraries), pkgTest)

#pkgTest.github("data.table","Rdatatable")

## Non-standard - install of a page with same name
pkgTest.github("stargazer","markwestcott34","stargazer-booktabs")
#install_github("markwestcott34/stargazer-booktabs")

