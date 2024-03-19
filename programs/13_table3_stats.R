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

# Get an intermediate file
jira.filter.submitted <- readRDS(file.path(temp,"jira.submitted.RDS"))


## response options
jira.response.options.detailed <- jira.filter.submitted  %>%  
  # there was one issue with a bug
  mutate(MCStatus = case_when(
    ticket == "AEAREP-4508" & MCStatus == "" ~ "CA",
    TRUE ~ MCStatus
  )) %>%
  distinct(mc_number_anon, .keep_all=TRUE) %>%
  unite(response,c(MCRecommendationV2,MCRecommendation),remove=FALSE,sep="") %>%
  distinct(response,MCStatus,mc_number_anon) %>%
  mutate(Stage = case_when(
    grepl("CA",MCStatus) ~ "CA",
    grepl("RR",MCStatus) ~ "RandR"
  )) 
  

jira.response.options.detailed %>%
  group_by(response,MCStatus) %>%
  summarise(freq=n_distinct(mc_number_anon)) %>%
  mutate(Stage = case_when(
    grepl("CA",MCStatus) ~ "CA",
    grepl("RR",MCStatus) ~ "RandR"
  )) %>%
  rename(`Response option`=response,`Frequency`=freq) %>%
  group_by(`Response option`,Stage) %>%
  summarize(Frequency = sum(Frequency))

tbl <- xtableFtable(ftable(jira.response.options.detailed$response,
             jira.response.options.detailed$Stage),method="compact")
print.xtableFtable(tbl,file = file.path(tables,"jira_response_options.tex"),
             booktabs = TRUE,method="compact",floating = FALSE)


# cross-check while running:

jira.filter.submitted  %>%  
   distinct(mc_number_anon, .keep_all=TRUE) %>%
   unite(response,c(MCRecommendationV2,MCRecommendation),remove=FALSE,sep="") %>%
   group_by(response) %>% filter(response=="Revise and Resubmit") %>% select(ticket)

# Notes:
# - AEAREP-3846: short report because not compliant, did not come back
# - AEAREP-3933: short report
# - AEAREP-4403: first fully reproducible submission of a comment