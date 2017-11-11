# PREPROCESSING BUS DATA

library(dplyr)
library(lubridate)

# TODO
# check for more than one row for only a single bus stop -> we only want one row

hstID = "43901" # sophienstrasse 
# TODO create more haltestellen csvs

# LOAD DATA
# TODO save in UTF-8
df <- read.csv(paste0("data/processed/all_" , hstID,  ".csv"),
               fileEncoding = "ISO-8859-1")
bank_holidays <- 
  read.csv("data/raw/holidays/feiertage151617.csv") %>%
  mutate(date = as.Date(date))
event_send <- 
  read.csv("data/raw/events/event_send.csv") %>%
  mutate(date = as.Date(date))

# remove "Ein" outliers (we are generous: more than 10 * SD):
df_no_outlier <-
  df %>%
  filter(Ein <= 10*sd(Ein))

# time features: month, weekday, weekend
df2 <- 
  df_no_outlier %>%
  # date related features
  mutate(date = as.Date(DatumAn, format = "%d.%m.%Y")) %>%
  mutate(weekday = wday(date, abbr = F, label = T, locale = "en_US.UTF-8")) %>%
  mutate(weekend = (weekday %in% c('Saturday', 'Sunday'))) %>%
  mutate(month = as.character(lubridate::month(date))) %>%
  mutate(year = as.character(lubridate::year(date))) %>%
  # time related features
  mutate(date_time = paste(date, ZeitAn)) %>%
  mutate(timestamp = as.POSIXct(date_time, format = "%Y-%m-%d %H:%M:%S")) %>%
  mutate(hour = lubridate::hour(timestamp)) %>%
  # adding bank holidays
  left_join(., bank_holidays, by = 'date') %>%
  mutate(bank_holiday = ifelse(is.na(bank_holiday), 0, bank_holiday)) %>%
  mutate(bank_holiday = as.logical(bank_holiday)) %>%
  # rush hour
  mutate(rush_hour = ifelse((weekend == F & bank_holiday == F & hour > 6 
                             & hour < 10), 
                            T, F)) %>%
  # event: send
  left_join(., event_send, by = 'date') %>%
  mutate(event_send = ifelse(event_send == 1, T, F))

# weather features: temp, rain, wind
# TODO

# events: carneval, ...
# TODO

# remove deprecated columns from data.frame
df2 <-
  df2 %>%
  dplyr::select(-DatumAn)

# SAVE DATA
write.csv(df2, paste0("data/processed/all_", hstID, "_enhanced.csv"))
