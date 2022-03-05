


library(tidyverse)
library(scales)    # scale format
library(janitor)   # clean data column names & functions
library(ggplot2)   # data visual
library(here)      # data file management
library(paletteer)
library(showtext)


font_add_google('Lato','Lato')
showtext_auto()




# ----- read in the data
careMgnt = read.csv('data/care_management_anonymized.csv')

clientInfo = read_csv('data/client_info_anonymized.csv')

donations = read_csv('data/donations_anonymized.csv')

pantry = read_csv('data/pantry_anonymized.csv')

volunteerServ = read_csv('data/volunteer_services_anonymized.csv')




# ============== set theme colors for ElderNet

#  ElderCare colors c('#5D5177','#410A45') 

theme = theme(
        plot.title = element_text(color = 'white',size = 14, hjust = 0.5, face = 'bold'),
        plot.subtitle = element_text(color = 'white', hjust = 0.5),
        text = element_text(family = 'Lato'),
        panel.grid.major = element_line(colour = "mediumorchid4"),
        panel.grid.minor = element_line(colour = "mediumorchid4"),
        panel.background = element_rect(fill = "#410A45", colour = "mediumorchid4"), 
        plot.background = element_rect(fill = "#410A45"),
        axis.text = element_text(colour = "white", size = 12),
        legend.text = element_text(colour = "white"),
        legend.title = element_text(colour = "white", size = 14),
        legend.key = element_rect(fill = "white",
                                  colour = "white"), 
        legend.background = element_rect(fill = NA),
        axis.title = element_text(colour = 'white', size = 12)
)





# scatter plots of donations by splitting it up by donating event type.
# event type in a bar chart (like summing donations by month or fiscal quarter)

# donations df has NAs 

# returns whole df with completed cases, a drop of 136 rows
donations2 = donations[complete.cases(donations),]

# get date data into date format
donations$date = mdy(donations$date)

# donations$campaign   returns 2180 rows , factor these 
donations$campaign = factor(donations$campaign)

# get campaign counts
donations2 %>% 
        select(campaign) %>% 
        count(campaign) %>% 
        arrange( desc(n)) %>% 
        ggplot( aes(x= n, y= fct_reorder(campaign,n)    ))+
        geom_col()+
        theme+
        labs(title = "total number of each campaign type",
             y="campaign types",
             x="count")
        

#  top donors by amount / fundraiser 


# fundraising 
# pantry 



# get donation amount, campaign 

donations2 %>% 
        select(amount, campaign, date) %>% 
        arrange( desc(amount) ) %>% 
        mutate(Max_ = max(amount),
               Min_ = min(amount),
               Avg = mean(amount)
               ) %>% 
        mutate(amount = str_remove_all(amount,"[:punct:]"),
               campaign = str_replace_all(campaign,pattern = 'Corporatio', 
                                          replacement = 'Corporation'))



donations2 %>% 
        select(amount, campaign, date) %>% 
        arrange( desc(amount) ) %>% 
        mutate(amount = str_remove_all(amount,"[:punct:]"),
               campaign = str_replace_all(campaign,pattern = 'Corporatio', 
                                          replacement = 'Corporation')
               ) %>% 
        filter(amount >20000) %>% 
        ggplot( aes(x= date, y= amount, col= campaign))+
        geom_point()+theme











