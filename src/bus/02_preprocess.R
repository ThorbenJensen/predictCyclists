# PREPROCESSING BUS DATA

library(dplyr)
library(lubridate)

# LOAD DATA
df <- read.csv("data/processed/bus.csv")

# define data types
df %>%
  mutate(date = as.character(Datum))

# check for spatial outliers: scatter plot of X and Y

# time features: month, weekday, weekend, holidays, rush_hour

# weather features: temp, rain, wind

# events: sendt, carneval, ...
