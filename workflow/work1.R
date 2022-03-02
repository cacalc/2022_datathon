

# TEAM 3 -  DATA 

library(tidyverse) # functions
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












# ===================== care mgmt

careMgnt = careMgnt %>% drop_na()



# separate the phone & email contact
careMgnt %>% 
        select(assistance_category) %>% 
        mutate(phoneEmail = str_detect(assistance_category, pattern = "(phone, email)")) %>% 
        count(phoneEmail) %>%
        ggplot(
                aes(x= n,
                    y= phoneEmail,
                    fill= n)
        )+
        geom_col() + 
        scale_fill_gradientn(colours = c('#df9fdf','#993399') )+
        labs(
          title = "\nElderNet Clients assistance category count",
          subtitle = "Clients contacted by Phone & Email vs not ",
          x="Client Count",
          y= "Contact by Phone & Email"

        ) + theme
        
 


careMgnt %>% 
        select(CommType, Party) %>% 
        group_by(CommType) %>% 
        mutate(Texts = case_when(CommType == 'Text Message' ~ 'Text', TRUE ~ '') ,
               Email = case_when(CommType =='Email' ~ 'Email', TRUE ~ ''),
               PhoneCall = case_when(CommType =='Call' ~ 'Call', TRUE ~ ''),
               VoiceMail = case_when(CommType =='Voice Message' ~ 'VoiceMail', TRUE ~ '')
               ) %>%
        
        count() %>% 
        filter(CommType > 2) %>% 
        ggplot(
                aes(x= n,
                    y= fct_reorder(CommType,n),
                    fill= n)
        )+
        scale_fill_gradientn(colours = c('#df9fdf','#993399') )+
        geom_col() + 
        theme +
        labs(title = "\nElderNet Client Care count by type of communication",
             y="Communication Type", x= 'Count')





careMgnt %>% 
        select(amount, unit, CommType) %>% 
        group_by(CommType) %>% 
        arrange( desc(amount)) %>% 
        mutate(Max_amnt = max(amount),
               Percent = amount/max(amount)
               ) %>% 
        unique()


        ggplot(
                aes(x= amount,
                    y= unit)
        )+
        geom_point( )+
        theme




careMgnt$Benefit_1 = factor(careMgnt$Benefit_1)

careMgnt$CommType = factor(careMgnt$CommType)

careMgnt$assistance_category = factor(careMgnt$assistance_category)

careMgnt$Party = factor(careMgnt$Party)








careMgnt %>% 
        select(Party, Benefit_1) %>%  
        drop_na() %>%  
        filter(Benefit_1 != "", Party !="") %>% 
        group_by(Benefit_1) %>%
        count( Benefits = n()) %>% 
        mutate(Prct = n/ Benefits*100) %>% 
        arrange( desc(Prct)) %>% 
        ggplot(
                aes(x= n,
                    y= fct_reorder(Benefit_1, n),
                    fill= n)
        )+
        geom_col()+
        scale_fill_gradientn(colours = c('#df9fdf','#993399') )+
        theme+
        labs(title = "\nElderNet Care Mgmt Counts by Benefit_1",
             subtitle = "empty benefit variables dropped",
             y="Benefit_1 Categories",
             x="Count"
             )








careMgnt$Assistance_1 = factor(careMgnt$Assistance_1)

careMgnt %>% select(Assistance_1) %>% 
        filter(Assistance_1 != "") %>% 
        group_by(Assistance_1) %>% 
        count() %>% 
        arrange( desc(n)) %>% 
        ggplot(
                aes(x= n,
                    y= fct_reorder(Assistance_1, n),
                    fill= n)
        )+
        geom_col()+
        scale_fill_gradientn(colours = c('#df9fdf','#993399') )+
        theme+
        labs(title = "\nElderNet Care Mgmt Assistance_1 Counts",
             subtitle = "empty variables dropped",
             y="Assistance_1 Categories",
             x="Count"
        )
        





# ---


careMgnt %>% 
        select(assistance_category) %>% 
        group_by(assistance_category) %>% 
        filter(assistance_category != "") %>% 
        mutate(Remote = str_detect(assistance_category,pattern = "Remote")) %>% 
        count(Remote) %>% 
        arrange( desc(n))










# =========================== client info

clientInfo %>% 
        select(anon_ID) %>% unique() 

clientInfo %>% 
        select(county) %>% 
        tabyl(county)
        # drop_na() %>% 
        # group_by(poverty)


# county        n       percent
# Montgomery    908     0.95780591
# Other         40      0.04219409

clientInfo %>% 
        select(county, poverty) %>% 
        group_by(poverty) %>% 
        tabyl(poverty)

# poverty       n       percent         valid_percent
# No            339     0.35759494      0.373348
# Yes           569     0.60021097      0.626652
# <NA>          40      0.04219409      NA










# =================== donations

donations  = donations %>% drop_na()


donations %>% 
        select(organisation) %>% 
        tabyl(organisation)

# organisation    n     percent
# N             1973    0.96056475
# Y             81      0.03943525

donations %>% 
        select(form) %>% 
        tabyl(form)

# form    n      percent
# Cash    3     0.0014605648
# Check   2050  0.9980525803
# InKind  1     0.0004868549


# target is 100% gifts


donationsCount = donations %>% 
        select(amount) %>% 
        count(amount) %>% 
        arrange( desc(n))

donations %>% 
        select(amount) %>% 
        count(amount) %>% 
        arrange( desc(n)) %>% 
        # top_n(30) %>% 
        ggplot( aes(x=amount, y= n, col= amount))+
        geom_point(size=6, alpha=0.65) +
        scale_x_continuous(labels = dollar_format())+
        scale_color_gradientn(colours = c('#df9fdf','#993399') )+
        theme+
        labs(title = "\nElderNet Donations by count and amount",
             y="Number of Donations"
             )

# tabyl(amount)










# ===================== pantry
library(lubridate)

pantry$assistance_date = mdy_hm(pantry$assistance_date)

pantry$assistance_date = lubridate::force_tz(pantry$assistance_date, tzone = "EST")

pantry$assistance_date = as.Date(pantry$assistance_date )


min(pantry$assistance_date)
max(pantry$assistance_date)

pantry %>% 
        select(amount) %>% 
        tabyl(amount)

# amount        n      percent
# 1             1       0.0001594134
# 4             12      0.0019129603
# 10            13      0.0020723737
# 15            7       0.0011158935
# 20            3       0.0004782401
# 25            5873    0.9362346565
# 30            338     0.0538817153
# 40            1       0.0001594134
# 50            22      0.0035070939
# 75            2       0.0003188267
# 100           1       0.0001594134


pantry %>% 
        select(assistance_date) %>% 
        count(assistance_date) %>% 
        arrange( desc( n))

# assistance_date     n
#       <date>       <int>
# 1 2020-11-20        108
# 2 2020-03-16         83
# 3 2020-12-22         81
# 4 2019-11-22         70
# 5 2020-11-24         53
# 6 2019-11-15         51
# 7 2020-12-08         51
# 8 2021-01-05         46
# 9 2020-05-19         44
# 10 2020-05-12        42
# … with 318 more rows




pantry %>% 
        select(assistance_date) %>% 
        count(assistance_date) %>% 
        # tabyl(assistance_date) %>% 
        ggplot( aes(x= assistance_date,
                    y= n,
                    col= n))+
                geom_line()+
        geom_point(size= 2)+
        # scale_color_gradientn(colours = c('#df9fdf','#993399') )+
        scale_color_paletteer_c("ggthemes::Gold-Purple Diverging", direction = -1)+
        scale_x_date(date_labels = "%Y - %B", date_breaks = "month", 
                     limits = c(as.Date("2019-01-01"),as.Date("2021-09-09")) ) +
        theme(axis.text.x = element_text(vjust = 0, angle = 90)
              )+
                theme +
        labs(title = "\nElderNet pantry counts by assistance date (by month)",
             subtitle = "dates range from 2019-01-03 to 2021-09-09",
             y="count")



pantry$assistance_category = factor(pantry$assistance_category)

pantry$unit = factor(pantry$unit)

pantry %>% 
        select(assistance_category) %>% 
        tabyl(assistance_category)

# assistance_category                   n       percent
# Food Pantry: Easter Outreach          19      0.003028854
# Food Pantry: Food Pantry Poundage     5817    0.927307508
# Food Pantry: Holiday Baskets          437     0.069663638

pantry %>% 
        select(unit) %>% 
        tabyl(unit)

# unit          n       percent
# Boxes/Bags    13      0.002072374
# Dollars       99      0.015781923
# Pounds        6161    0.982145704








# ====================== volunteer

volunteerServ$rider_first_ride_date = ymd(volunteerServ$rider_first_ride_date)
volunteerServ$rider_last_ride_date = ymd(volunteerServ$rider_last_ride_date)
volunteerServ$appt_date = mdy(volunteerServ$appt_date)

volunteerServ$category = factor(volunteerServ$category)

min(volunteerServ$rider_first_ride_date) # "2015-04-20"
max(volunteerServ$rider_first_ride_date) # "2021-09-07"

volunteerServ %>% 
        select(rider_first_ride_date) %>% 
        count(rider_first_ride_date) %>% 
        arrange( desc( n)) 
        # tabyl(rider_first_ride_date)

# rider_first_ride_date     n
# <date>                    <int>
# 1 2015-05-06              548
# 2 2015-05-02              326
# 3 2015-04-20              295
# 4 2015-04-27              226
# 5 2015-05-04              154
# 6 2015-04-23              120
# 7 2015-04-21              118
# 8 2015-05-08              111
# 9 2016-01-13              104
# 10 2016-01-15             102
# # … with 137 more rows

volunteerServ %>% 
        select(rider_first_ride_date) %>% 
        count(rider_first_ride_date) %>% 
        # arrange( desc( n)) %>% 
        ggplot( aes(x= rider_first_ride_date,
                    y= n,
                    col= n))+
        geom_line()+
        geom_point()+
        scale_x_date(date_labels = "%Y - %b", date_breaks = "month", 
                     limits = c(as.Date("2020-05-01"),as.Date("2021-05-01")) ) +
        theme(axis.text.x = element_text(vjust = 0, angle = 90)
        )+
        scale_color_paletteer_c("ggthemes::Gold-Purple Diverging", direction = 1)+
        theme+
        labs(title = "\nElderNet Volunteer Service first rides counts by date",
             subtitle = "dates range from May 2020 to May 2021",
             y="count")






max(volunteerServ$appt_duration)
mean(volunteerServ$appt_duration)
volunteerServ %>% 
        select(appt_duration) %>% 
        count(appt_duration) %>% 
        filter(appt_duration <= 4) %>% 
        ggplot( aes(y=n, x= appt_duration, col=n))+
        geom_jitter(size=4)+
        scale_color_paletteer_c("ggthemes::Gold-Purple Diverging", direction = 1)+
        scale_x_binned(n.breaks = 7)+
        scale_y_binned(n.breaks = 5)+
        theme+
        labs(title = "\nElderNet Volunteer Service appt durations",
             subtitle = "appointments less than 4 hours",
             x="duration (hrs)",
             y="count")


# 







# tabyl(appt_duration)

volunteerServ %>% 
        select(category) %>% 
        tabyl(category)

# category                      n       percent
# Board or Committee Mtg        586     0.1189847716
# Doctor Appt                   2102    0.4268020305
# Errands                       79      0.0160406091
# Friendly Visit                571     0.1159390863
# Odd Jobs                      43      0.0087309645
# Pantry                        273     0.0554314721
# Pantry Delivery               30      0.0060913706
# Shopping                      1158    0.2351269036
# Skilled Work                  20      0.0040609137
# Special Projects              56      0.0113705584
# Telephone Reassurance         3       0.0006091371
# Yard Work                     4       0.0008121827


























