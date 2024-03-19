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

message(paste0("Reading from ",icpsr.utilization.file))
utilizationReport <- read_csv(file.path(icpsrbase,icpsr.utilization.file)) %>%
  select(Project.ID = "Study ID",
         Status,
         Views,
         Downloads  = "Download",
         Updated.Date = "Updated Date") %>%
  # blacklist - these are in an ambiguous state
  mutate(exclude = (Project.ID %in% c(109644,110581,110621,110902,111003))) %>%
  filter(exclude == FALSE) %>%
  filter(Status %in% c("PUBLISHED","NEW VERSION IN PROGRESS","SUBMITTED") ) %>%
  mutate(is_published = (Views >0),
         as.of.date   = icpsr.utilization.date)

summary(utilizationReport)

# we save this filtered file
saveRDS(utilizationReport,file=file.path(icpsrbase,"anonUtilizationReport.Rds"))
write_csv(utilizationReport,file=file.path(icpsrbase,"anonUtilizationReport.csv"))

