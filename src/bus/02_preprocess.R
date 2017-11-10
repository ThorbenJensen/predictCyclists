# PREPROCESSING BUS DATA

library(dplyr)
library(lubridate)

# LOAD DATA
df <- read.csv("data/processed/bus.csv")

# check for spatial outliers: scatter plot of X and Y
# TODO

# time features: month, weekday, weekend
df2 <- 
  df %>%
  mutate(date = as.Date(Datum, format = "%d.%m.%y")) %>%
  mutate(weekday = wday(date, abbr = F, label = T)) %>%
  mutate(weekend = (weekday %in% c('Saturday', 'Sunday')))
# TODO: holidays, rush_hour

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
