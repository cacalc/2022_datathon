
# -- workflow 3 :: messy data EDA 


library(tidyverse)
library(scales)    # scale format
library(janitor)   # clean data column names & functions
library(ggplot2)   # data visual
library(here)      # data file management
library(paletteer)
library(showtext)


font_add_google('Lato','Lato')
showtext_auto()


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









# ----- read in the data
careMgnt = read.csv('data/care_management_anonymized.csv') %>% janitor::clean_names()

clientInfo = read_csv('data/client_info_anonymized.csv')%>% janitor::clean_names()

donations = read_csv('data/donations_anonymized.csv') %>% janitor::clean_names()

pantry = read_csv('data/pantry_anonymized.csv') %>% janitor::clean_names()

volunteerServ = read_csv('data/volunteer_services_anonymized.csv') %>% janitor::clean_names()


# from 12487 rows to 4728 rows 
# example: anon_id 433 original has 27 rows goes to 21 rows, dropping rows with only NAs
careMgmt2 = careMgnt[complete.cases(careMgnt), ]


# client info from 948 rows to 121 rows
# anon_id 582 originally 2 rows now 1 row
clientInfo2 = clientInfo[complete.cases(clientInfo),]


# pantry has same 6273 rows
pantry2 = pantry[complete.cases(pantry),]

# volunteer services have same 4925 rows
volServ2 = volunteerServ[complete.cases(volunteerServ),]


# scatter plots of donations by splitting it up by donating event type.
# event type in a bar chart (like summing donations by month or fiscal quarter)

# donations df has NAs 

# donations from 2190 rows to 2054 rows
donations2 = donations[complete.cases(donations),]

# get date data into date format
donations$date = mdy(donations$date)

# donations$campaign   returns 2180 rows , factor these 
donations$campaign = factor(donations$campaign)














# care management ---------------------------------------------------------------------

# 5 bullet points for report, 1 min/slide

# careMgnt%>% count(is.na(careMgnt$party))

# --- care mgmt
careMgnt$assistance_date = ymd_hms(careMgnt$assistance_date, tz='EST')
careMgnt$assistance_date


careMgnt$assistance_category = factor(careMgnt$assistance_category)
careMgnt$assistance_category %>% unique()
careMgnt$assistance_category %>% tabyl()


careMgnt$unit = factor(careMgnt$unit)
careMgnt$unit %>% unique()
careMgnt$unit %>% tabyl()


careMgnt %>% 
        select(comm_type) %>% 
        count(comm_type = is.na(comm_type))

careMgnt$comm_type = factor(careMgnt$comm_type)
careMgnt$comm_type %>% tabyl()





careMgnt %>% 
        select(party) %>% 
        count(partyNA = is.na(party))

careMgnt$party = factor(careMgnt$party)
careMgnt$party %>% unique()
careMgnt$party %>% tabyl()


careMgnt %>% 
        select(party) %>% 
        mutate(party = str_replace_all(careMgnt, "Eldernet", replacement = "ElderNet" ))





careMgnt$initiated_by
careMgnt %>% 
        select(initiated_by) %>% 
        count(initNA = is.na(initiated_by))

careMgnt$initiated_by = factor(careMgnt$initiated_by)
careMgnt$initiated_by %>% unique()
careMgnt$initiated_by %>% tabyl()




careMgnt$benefit_1
careMgnt %>% 
        select(benefit_1) %>% 
        count(benefit_1 = is.na(benefit_1))

careMgnt$benefit_1= factor(careMgnt$benefit_1)
careMgnt$benefit_1 %>% unique()
careMgnt$benefit_1 %>% tabyl()




careMgnt$assistance_1
careMgnt %>% 
        select(assistance_1) %>% 
        count(assistance_1 = is.na(assistance_1))

careMgnt$assistance_1= factor(careMgnt$assistance_1)
careMgnt$assistance_1 %>% unique()
careMgnt$assistance_1 %>% tabyl()





# -----------------------
careMgnt$benefit_3
careMgnt %>% 
        select(benefit_3) %>% 
        count(benefit_3 = is.na(benefit_3))

careMgnt$benefit_3= factor(careMgnt$benefit_3)
careMgnt$benefit_3 %>% unique()
careMgnt$benefit_3 %>% tabyl()



careMgnt$assistance_3
careMgnt %>% 
        select(assistance_3) %>% 
        count(assistance_3 = is.na(assistance_3))

careMgnt$assistance_3= factor(careMgnt$assistance_3)
careMgnt$assistance_3 %>% unique()
careMgnt$assistance_3 %>% tabyl()








# client info -------------------------------------------------------------

clientInfo %>% duplicated() %>% tabyl()

clientInfo %>% 
        select(county) %>% count(county = is.na(county))


clientInfo$county = factor(clientInfo$county)
clientInfo$county
clientInfo$county %>% tabyl()



clientInfo$poverty = factor(clientInfo$poverty)
clientInfo$poverty
clientInfo$poverty %>% tabyl()


clientInfo$minority
clientInfo$minority = factor(clientInfo$minority)
clientInfo$minority
clientInfo$minority %>% tabyl()

# careMgnt %>% 
#         select(comm_type) %>% 
#         count(comm_type = is.na(comm_type))
# 
# careMgnt$comm_type = factor(careMgnt$comm_type)
# careMgnt$comm_type %>% tabyl()

clientInfo$age_group = factor(clientInfo$age_group)
clientInfo$age_group
clientInfo$age_group %>% tabyl()





# donations ---------------------------------------------------------------

# donations %>% duplicated() %>% tabyl()
# donations %>% count(is.na(donations$zip))
# donations %>% count(is.na(donations$status))
# donations %>% count(is.na(donations$status))

donations %>% select(anon_donor_id) %>% 
        count( anon_donor_id = is.na(anon_donor_id))


donations$anon_donor_id = factor(donations$anon_donor_id)
donations$anon_donor_id %>% unique()
donations$anon_donor_id %>% unique %>% tabyl()



donations$zip = factor(donations$zip)
donations$zip
donations %>% count(is.na(donations$zip))

donations$do_not_mail= factor(donations$do_not_mail)
donations$do_not_mail %>% unique()
donations$do_not_mail %>% tabyl()
donations %>% count(is.na(donations$do_not_mail))


donations$do_not_call = factor(donations$do_not_call)
donations$do_not_call %>% unique()
donations$do_not_call %>% tabyl()
donations %>% count(is.na(donations$do_not_call))


donations %>% count(is.na(donations$organisation))
donations$organisation = factor(donations$organisation)
donations$organisation %>% unique()
donations$organisation %>% tabyl()


donations$date = mdy(donations$date)
donations$date



donations %>% count(is.na(donations$amount))
donations$amount %>% tabyl() %>% arrange( desc(n))




donations %>% count(is.na(donations$form))
donations$form = factor(donations$form)
donations$form %>% unique()
donations$form %>% tabyl()




donations %>% count(is.na(donations$campaign))
donations$campaign = factor(donations$campaign)
donations$campaign %>% unique()
donations$campaign %>% tabyl() %>% arrange( desc( n))


donations %>% count(is.na(donations$target))
donations$target = factor(donations$target)
donations$target %>% unique()
donations$target%>% tabyl() %>% arrange( desc( n))


# careMgnt %>% 
#         select(comm_type) %>% 
#         count(comm_type = is.na(comm_type))
# 
# careMgnt$comm_type = factor(careMgnt$comm_type)
# careMgnt$comm_type %>% tabyl()



# pantry ------------------------------------------------------------------

pantry$assistance_date = mdy_hm(pantry$assistance_date, tz='EST')
pantry$assistance_date


pantry %>% count(is.na(pantry$assistance_date))
# pantry$ = factor(donations$target)
donations$target %>% unique()
donations$target%>% tabyl() %>% arrange( desc( n))



pantry %>% count(is.na(pantry$assistance_category)) 
pantry$assistance_category = factor(pantry$assistance_category)
pantry$assistance_category %>% unique()
pantry$assistance_category %>% tabyl() #%>% arrange( desc( n))





pantry %>% count(is.na(pantry$amount)) 
pantry$amount
pantry$amount = factor(pantry$amount)
pantry$amount %>% unique()
pantry$amount %>% tabyl() %>% arrange( desc( n))



pantry %>% count(is.na(pantry$unit)) 
pantry$unit
pantry$unit = factor(pantry$unit)
pantry$unit  %>% unique()
pantry$unit %>% tabyl() %>% arrange( desc( n))



# volunteer ---------------------------------------------------------------


volunteerServ %>% count(is.na(volunteerServ$rider_first_ride_date))
volunteerServ$rider_first_ride_date
# pantry$unit = factor(pantry$unit)
# pantry$unit  %>% unique()
# pantry$unit %>% tabyl() %>% arrange( desc( n))



volunteerServ %>% count(is.na(volunteerServ$rider_last_ride_date))
volunteerServ$rider_last_ride_date


volunteerServ %>% count(is.na(volunteerServ$rider_num_rides)) 
volunteerServ$rider_num_rides
volunteerServ$rider_num_rides = factor(volunteerServ$rider_num_rides)
volunteerServ$rider_num_rides %>% unique()
volunteerServ$rider_num_rides%>% tabyl() %>% arrange( desc( n))




volunteerServ %>% count(is.na(volunteerServ$appt_date)) 
volunteerServ$appt_date
volunteerServ$appt_date = mdy(volunteerServ$appt_date)

# volunteerServ$rider_num_rides = factor(volunteerServ$rider_num_rides)
volunteerServ$appt_date %>% unique()
volunteerServ$appt_date %>% tabyl() %>% arrange( desc( n))





volunteerServ %>% count(is.na(volunteerServ$appt_duration)) 
volunteerServ$appt_duration
volunteerServ$appt_duration = factor(volunteerServ$appt_duration)
volunteerServ$appt_duration %>% unique()
volunteerServ$appt_duration %>% tabyl() %>% arrange( desc( n))





volunteerServ %>% count(is.na(volunteerServ$category)) 
volunteerServ$category
volunteerServ$category = factor(volunteerServ$category)
volunteerServ$category %>% unique()
volunteerServ$category %>% tabyl() %>% arrange( desc( n))
















# insights ----------------------------------------------------------------

careMgnt %>% 
        select(assistance_date, comm_type) %>% 
        group_by(comm_type) %>% 
        count(assistance_date) %>% 
        arrange( desc( n)) %>% 
        # filter(  !comm_type %in%  c("","NA"," ")) %>% 
        ggplot( aes(x= as.Date(assistance_date), y= n, color= comm_type))+
        geom_point( size= 5, alpha= 0.5 ) + 
        theme+
        scale_x_date(date_labels = "%Y - %B", date_breaks = "month") +
        theme(axis.text.x = element_text(vjust = 0, angle = 90)
        )+
        # scale_color_viridis_d(option = 'A') + 
        scale_color_paletteer_d(`"calecopal::canary"`)+
        theme(
                legend.text = element_text(colour = "white"),
                legend.title = element_text(colour = "white", size = 12),
                legend.key = element_rect(fill = NA),
                legend.background = element_rect(fill = NA)
    )
       

careMgmt2$assistance_date = ymd_hms(careMgmt2$assistance_date, tz= 'EST')

careMgmt2 %>% 
        select(assistance_date, comm_type) %>% 
        group_by(comm_type) %>% 
        count(assistance_date) %>% 
        arrange( desc( n)) %>% 
        filter(  !comm_type %in%  c("","NA"," ")) %>%
        ggplot( aes(x= as.Date(assistance_date), y= n, color= comm_type))+
        geom_point( size= 5, alpha= 0.7 ) + 
        theme+
        scale_x_date(date_labels = "%Y - %B", date_breaks = "month") +
        scale_y_continuous(breaks = 1:6 )+
        theme(axis.text.x = element_text(vjust = 0, angle = 90)
        )+
        # scale_color_viridis_d(option = 'A') + 
        scale_color_paletteer_d(`"dichromat::BluetoOrange_8"`)+
        theme(
                legend.text = element_text(colour = "white"),
                legend.title = element_text(colour = "white", size = 12),
                legend.key = element_rect(fill = NA),
                legend.background = element_rect(fill = NA)
        )


careMgmt2$assistance_category = factor(careMgmt2$assistance_category)

careMgmt2 %>% 
        select(assistance_category, amount, unit, assistance_date) %>% 
        mutate(unit = factor(careMgmt2$unit) ) %>% 
        arrange( desc( amount)) %>% 
        ggplot( aes(x= as.Date(assistance_date), y= amount, col= assistance_category))+
        geom_point(size= 3)+
        theme+
        theme(
              
                legend.text = element_text(colour = "white"),
                legend.title = element_text(colour = "white", size = 12),
                legend.key = element_rect(fill = NA),
                legend.background = element_rect(fill = NA),
                axis.text.x = element_text(vjust = 0, angle = 90)
        )+
        scale_color_paletteer_d(`"awtools::bpalette"`, direction = -1)+
        scale_x_date(date_labels = "%Y - %B", date_breaks = "month")+
        scale_y_continuous(breaks = pretty_breaks())+
        labs(title = "EldnerNet Assistance counts by category and date",
             x = "Date",
             y="Amount (minutes)"
             ) + theme(legend.position = "top", legend.direction = "horizontal")






careMgnt %>% 
        select(benefit_1, benefit_2, benefit_3) %>% 
        count(benefit_1, benefit_2, benefit_3) %>% 
        arrange( desc( n))
       

careMgnt %>% 
        select(assistance_1, assistance_2, assistance_3) %>% 
        count( assistance_3) %>% 
        arrange( desc( n)) 

.







