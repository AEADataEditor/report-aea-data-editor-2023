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


library(stargazer)

# let's get the noncompliant 
# JIRA extract: select Task, Noncompliant = Yes. Verify and cleanup any pending. Download Excel file.
# Columns will depend on view. At a minimu, AEAREP number, Manuscript Number, Journal, openICPSR ID
# .... Key	Summary	Manuscript Central identifier	Status	Journal	openICPSRDOI	openICPSR Project Number	Assignee
# Summary and Assignee will be removed here. 
# ============ THIS IS TEMPORARY AND SHOULD BE HANDLED IN PROCESSING =================
# The xlsx files are treated as confidential.

if ( file.exists(jira.noncompliance.name) ) {
  jira.noncompliance <- read_excel(jira.noncompliance.name,
                              sheet = 2) 
  message(paste0("File ",jira.noncompliance.name," read"))
} else {
  stop(paste0("Missing noncompliance file ",jira.noncompliance.name))
}

# get the updates. Similar to above, but filter on MCStatus = Update.

if ( file.exists(jira.updates.name) ) {
  jira.updates <- read_excel(jira.updates.name,
                             sheet = 2) 
  message(paste0("File ",jira.updates.name," read"))
} else {
  stop(paste0("Missing updates file ",jira.updates.name))
}


# get the ndas 

if ( file.exists(jira.nda.name) ) {
  jira.nda <- read_excel(jira.nda.name,
                             sheet = 2) 
  message(paste0("File ",jira.nda.name," read"))
} else {
  stop(paste0("Missing nda file ",jira.nda.name))
}


# get the externals 

if ( file.exists(jira.external.name) ) {
  jira.external <- read_excel(jira.external.name,
                         sheet = 2) 
  message(paste0("File ",jira.external.name," read"))
} else {
  stop(paste0("Missing external file ",jira.external.name))
}

# Summarize various extra statuses

# For non-compliance and updates, we do not try to unduplicate by MC, since some are
# pre-Data Editor, and do not have a MC Number.

jira.noncompliance %>% 
  group_by(`Manuscript Central identifier`) %>%
  summarize(n=n()) %>%
  ungroup() %>%
  # we ignore the n because it is just a trick to get distinct char vars
  summarize(`Non-compliant`=n())  -> summary_compliance


update_latexnums("mcpubnoncompl",summary_compliance$`Non-compliant`)


# Summarize updates - same thing

jira.updates %>% 
  group_by(`Manuscript Central identifier`) %>%
  summarize(n=n()) %>%
  ungroup() %>%
  summarize(`Updates`=n()) %>%
  ungroup()  -> summary_updates


update_latexnums("mcpubupdates",summary_updates$`Updates`)


# removed "n_compliance_manuscript.tex"

# create table by update type

jira.updates %>% 
  separate_longer_delim(`Update type`,delim=";") %>%
  group_by(`Update type`,`Manuscript Central identifier`) %>%
  summarize(n=n()) %>%
  ungroup() %>%
  group_by(`Update type`) %>%
  # here we actually allow for multiple updates per MC
  summarize(`Manuscripts`=sum(n)) %>%
  rename(Origin = `Update type`) %>%
  ungroup() -> update_types



# create table by journal
update_types %>%
  mutate(Manuscripts =replace_na(as.character(Manuscripts),"")) %>%
  stargazer(style = "aer",
            summary = FALSE,
            out = file.path(tables,"n_updates_manuscript.tex"),
            out.header = FALSE,
            float = FALSE,
            rownames = FALSE

  )

# now for information on NDAs


jira.nda %>% 
  mutate(mc_number = sub('\\..*', '',`Manuscript Central identifier`)) -> jira.nda.clean

# get at the total count 
jira.nda.clean %>%
  group_by(`Agreement signed`,mc_number) %>%
  summarize(n=n()) %>%
  ungroup() %>%
  group_by(`Agreement signed`) %>%
  # here we do not allow for multiple nda per MC
  summarize(`Manuscripts`=n()) %>%
  mutate(Type = case_match(`Agreement signed`,
                           "DUA" ~ "Data Use Agreement",
                           "NDA" ~ "NDA (formal)",
                           "NDA;Implicit" ~ "NDA (informal)")) %>%
  ungroup() -> nda_types


update_latexnums("mcpubnda",sum(nda_types$Manuscripts))

# create table by type
nda_types %>%
  mutate(Manuscripts =replace_na(as.character(Manuscripts),"")) %>%
  select(Type,Manuscripts) %>%
  stargazer(style = "aer",
            summary = FALSE,
            out = file.path(tables,"n_ndas_manuscript.tex"),
            out.header = FALSE,
            float = FALSE,
            rownames = FALSE
  )

# Information by external

jira.external %>% 
  mutate(mc_number = sub('\\..*', '',`Manuscript Central identifier`)) -> jira.external.clean

# get at the total count 
jira.external.clean %>%
  group_by(`External party name`,mc_number) %>%
  summarize(n=n()) %>%
  ungroup() %>%
  group_by(`External party name`) %>%
  # here we do not allow for multiple externals per MC
  summarize(`Manuscripts`=n()) -> jira.external.details

jira.external.details %>%
  mutate(`External party name` = if_else(grepl("tudent",`External party name`,fixed=TRUE),
                                         "Graduate Student",
                                         `External party name`)) %>%
  group_by(`External party name`) %>%
  summarize(`Manuscripts` = sum(Manuscripts)) -> external_types

update_latexnums("mcpubexternal",sum(external_types$Manuscripts))

# create table by type
external_types %>%
  mutate(Manuscripts =replace_na(as.character(Manuscripts),"")) %>%
  stargazer(style = "aer",
            summary = FALSE,
            out = file.path(tables,"n_externals_manuscript.tex"),
            out.header = FALSE,
            float = FALSE,
            rownames = FALSE
  )
