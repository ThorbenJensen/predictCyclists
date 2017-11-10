# PLOT DATA

library(dplyr)
library(ggplot2)

# LOAD DATA
df <- 
  read.csv("data/processed/bus2.csv") %>%
  mutate(timestamp = as.POSIXct(timestamp))

# check for spatial outliers: scatter plot of X and Y
ggplot(df, aes(X, Y)) +
  geom_point(alpha = .2)

# time line
ggplot(df, aes(timestamp, Ein)) +
  geom_line() +
  scale_x_datetime(limits = c(as.POSIXct("2017-08-01"), 
                              as.POSIXct("2017-11-15")))

# time line, aggregated by hour
ggplot(df, aes(timestamp)) +
  geom_histogram(binwidth = 60*60*24) +
  scale_x_datetime(limits = c(as.POSIXct("2017-08-01"), 
                              as.POSIXct("2017-11-15")))

# histogram of 'Ein'
# TODO
