# PLOT DATA

library(dplyr)
library(ggplot2)

# LOAD DATA
hstID = "43901"
df <- 
  read.csv(paste0("data/processed/all_" , hstID,  "_enhanced.csv")) %>%
  mutate(timestamp = as.POSIXct(timestamp))

# check for spatial outliers: scatter plot of X and Y
ggplot(df, aes(X, Y)) +
  geom_point(alpha = .2)

# time line
ggplot(df, aes(timestamp, Ein)) +
  geom_line()# +
  # TODO: geom_smooth

# time line, aggregated by hour
ggplot(df, aes(timestamp)) +
  geom_histogram(binwidth = 60*60*24) #+

# histogram of 'Ein' and 'Aus'
df %>%
  filter(hour > 4 & hour < 10) %>% # morning
  # filter(hour > 15 & hour < 21) %>% # afternoon
  ggplot(data = .) +
    geom_histogram(aes(x = Ein, fill = "Ein"), alpha = 0.25, binwidth = 1) + 
    geom_histogram(aes(x = Aus, fill = "Aus"), alpha = 0.25, binwidth = 1)


ggplot(data = df) +
  geom_histogram(aes(x = hour, fill = "stunde"), alpha = 0.25, binwidth = 1)

# at weekdays, how many travellers per hour? -> find out rush hour
# TODO
