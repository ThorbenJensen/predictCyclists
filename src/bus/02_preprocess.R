# PREPROCESSING BUS DATA

library(dplyr)
library(lubridate)
library(sqldf)

# LOAD DATA
df <- read.csv("data/processed/bus.csv")
bank_holidays <- 
  read.csv("data/raw/holidays/feiertage151617.csv") %>%
  mutate(date = as.Date(date))

# time features: month, weekday, weekend
df2 <- 
  df %>%
  mutate(date = as.Date(Datum, format = "%d.%m.%Y")) %>%
  mutate(weekday = wday(date, abbr = F, label = T)) %>%
  mutate(weekend = (weekday %in% c('Saturday', 'Sunday'))) %>%
  mutate(month = month(date)) %>%
  mutate(year = year(date)) %>%
  mutate(date_time = paste(date, Zeit)) %>%
  mutate(timestamp = as.POSIXct(date_time, format = "%Y-%m-%d %H:%M:%S")) %>%
  mutate(hour = hour(timestamp)) %>%
  left_join(., bank_holidays, by = 'date') %>%
  mutate(bank_holiday = ifelse(is.na(bank_holiday), 0, bank_holiday))

# TODO

# TODO: join holidays, rush_hour

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
