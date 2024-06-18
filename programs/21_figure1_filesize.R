# Tabulate statistics and make graphs for the AEA data editor report
# Harry Son
# 2/18/2021



### Load libraries 
### Requirements: have library *here*
source(here::here("global-libraries.R"),echo=TRUE)
source(here::here("programs","config.R"),echo=TRUE)

# read file back in


icpsr.file_size <- readRDS(file=file.path(icpsrbase,"icpsr.file.size.Rds"))
# graph it all

dist_size <- icpsr.file_size %>%
  transform(intfilesize=pmin(round(filesize),10,na.rm = TRUE)) %>%
  group_by(intfilesize) %>%
  summarise(count=n())


plot_filesize_dist <- ggplot(dist_size, aes(x = intfilesize,y=count)) +
  geom_bar(stat="identity", colour="black", fill="grey")+
  theme_classic() +
  labs(x = "GB",
       y = element_blank(), 
       title = "Size distribution of replication packages")

ggsave(file.path(images,"plot_filesize_dist.png"), 
       plot_filesize_dist  +
         labs(y=element_blank(),title=element_blank()),
       width=7,height=3,units="in")
#plot_filesize_dist
