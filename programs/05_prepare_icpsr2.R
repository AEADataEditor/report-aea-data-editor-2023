# Tabulate statistics and make graphs for the AEA data editor report
# Harry Son
# 2/18/2021

# Inputs
#   - file.path(jiraanon,"jira.anon.RDS") 
#   - file.path(temp,"jira.others.RDS)
# Outputs


### Load libraries 
### Requirements: have library *here*
source(here::here("global-libraries.R"),echo=TRUE)
source(here::here("programs","config.R"),echo=TRUE)

## Non-standard - install of a page with same name
library(stargazer)

# Get the data
# Read in data extracted from openICPSR,
# This varies from year to year

icpsr.custom <- read_excel(file.path(icpsrbase,icpsr.custom.xlsx)) %>%
  separate(Created,c("Created.Date","Created.Time"),sep="T") %>%
  mutate(date=parse_date(Created.Date)) %>%
  filter(date >= firstday & date <= lastday )

icpsr.actual_lastday <- icpsr.custom %>% 
  summarize(lastday=max(date)) %>%
  pull(lastday) %>% as.character()

# QA
summary(icpsr.custom)


update_latexnums("pkgcount",nrow(icpsr.custom))
update_latexnums("pkglastday",icpsr.actual_lastday)

         

# cleanup
icpsr <- icpsr.custom %>%
  select(Project.ID              = Project,
         openICPSR.title         = Title,
         fileCount               = Files,
         Total.File.Size         = "Bytes",
         Created.Date            ,
         date
  ) 

## Distribution of replication packages
icpsr.file_size <- icpsr %>% 
  distinct(Project.ID,.keep_all = TRUE) %>%
  mutate(date_created=as.Date(substr(Created.Date, 1,10), "%Y-%m-%d")) %>%
  filter(date_created >= as.Date(firstday)-30, date_created <= lastday) %>%
  transform(filesize=Total.File.Size/(1024^3)) %>% # in GB
  transform(filesizemb=Total.File.Size/(1024^2)) %>% # in MB
  transform(intfilesize=round(filesize))

# get some stats
icpsr.file_size %>% 
  summarize(n   = n(),
            files=sum(fileCount),
            mean=round(mean(filesize),2),
            median=round(median(filesize),2),
            q75=round(quantile(filesize,0.75),2),
            sum=round(sum(filesize),2)) -> icpsr.stats.gb

icpsr.file_size %>% 
    summarize(n   = n(),
              files=sum(fileCount),
              mean=round(mean(filesizemb),2),
            median=round(median(filesizemb),2),
            q75=round(quantile(filesizemb,0.75),2),
            sum=round(sum(filesizemb),2)) -> icpsr.stats.mb

saveRDS(icpsr.file_size,file=file.path(temp,"icpsr.file.size.Rds"))
saveRDS(icpsr.stats.mb,file=file.path(temp,"icpsr.stats.mb.Rds"))
saveRDS(icpsr.stats.gb,file=file.path(temp,"icpsr.stats.gb.Rds"))

icpsr.file_size %>% 
  group_by(intfilesize) %>% 
  summarise(n=n()) %>% 
  ungroup() %>% 
  mutate(percent=100*n/sum(n)) -> icpsr.stats1

update_latexnums("pkgsizetwog",icpsr.stats1 %>% 
                             filter(intfilesize > 2) %>% 
                             summarize(percent=sum(percent)) %>% round(0))
update_latexnums("pkgsizetwentyg",icpsr.stats1 %>% 
                              filter(intfilesize >19) %>% 
                              summarize(percent=sum(percent)) %>% round(0))


update_latexnums("pkgsizetotalgb",icpsr.stats.gb$sum)
update_latexnums("pkgsizetotaltb",round(icpsr.stats.gb$sum/1024,0))
update_latexnums("pkgsizemean",icpsr.stats.mb$mean)
update_latexnums("pkgsizemedian",icpsr.stats.mb$median)
update_latexnums("pkgsizeqsvntyfv",icpsr.stats.mb$q75)
update_latexnums("pkgfilesT",round(icpsr.stats.mb$files/1000,0))
update_latexnums("pkgfiles",icpsr.stats.mb$files)
