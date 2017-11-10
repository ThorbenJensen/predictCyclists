# PREPROCESSING BUS DATA

library(dplyr)
library(lubridate)

# LOAD DATA
df <- read.csv("data/processed/bus.csv")
bank_holidays <- 
  read.csv("data/raw/holidays/feiertage151617.csv") %>%
  mutate(date = as.Date(date))
event_send <- 
  read.csv("data/raw/events/event_send.csv") %>%
  mutate(date = as.Date(date))

# time features: month, weekday, weekend
df2 <- 
  df %>%
  # date related features
  mutate(date = as.Date(Datum, format = "%d.%m.%Y")) %>%
  mutate(weekday = wday(date, abbr = F, label = T)) %>%
  mutate(weekend = (weekday %in% c('Saturday', 'Sunday'))) %>%
  mutate(month = as.character(month(date))) %>%
  mutate(year = as.character(year(date))) %>%
  # time related features
  mutate(date_time = paste(date, Zeit)) %>%
  mutate(timestamp = as.POSIXct(date_time, format = "%Y-%m-%d %H:%M:%S")) %>%
  mutate(hour = hour(timestamp)) %>%
  # adding bank holidays
  left_join(., bank_holidays, by = 'date') %>%
  mutate(bank_holiday = ifelse(is.na(bank_holiday), 0, bank_holiday)) %>%
  mutate(bank_holiday = as.logical(bank_holiday)) %>%
  # rush hour
  mutate(rush_hour = ifelse((weekend == F & hour > 6 & hour < 10), 
                            T, F)) %>%
  # event: send
  left_join(., event_send, by = 'date') %>%
  mutate(event_send = ifelse(event_send == 1, T, F))

# weather features: temp, rain, wind
# TODO

# events: sendt, carneval, ...
# TODO

# remove deprecated columns from data.frame
df2 <-
  df2 %>%
  select(-Datum)

# SAVE DATA
write.csv(df2, "data/processed/bus2.csv")
