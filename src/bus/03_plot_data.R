# PLOT DATA

library(dplyr)
library(ggplot2)
library(ggthemes)

# LOAD DATA
#hstID = "43901" # sophienstraße
hstID = "41000" # hauptbahnhof
df <- 
  read.csv(paste0("data/processed/all_" , hstID,  "_enhanced.csv")) 
# %>%
#  mutate(timestamp = as.POSIXct(timestamp))

# check for spatial outliers: scatter plot of X and Y
ggplot(df, aes(X, Y, color = Ein)) +
  geom_point(alpha = .1)

# Show spatial density of passengers entering busses
ggplot(df, aes(X, Y, z = Ein)) +
  stat_summary_hex(fun = function(x) sum(x), color = "black")+
  scale_colour_gradient2()+
  theme_economist()+
  theme(legend.position="right", legend.title = element_text(size=9))

# time line
ggplot(df, aes(timestamp, Ein)) +
  geom_line()# +
  # TODO: geom_smooth

# time line, aggregated by hour
ggplot(df, aes(timestamp)) +
  geom_histogram(binwidth = 60*60*24)

# histogram of 'Ein' and 'Aus' -> shiny top right
df %>%
  filter(hour > 4 & hour < 10) %>% # morning
  # filter(hour > 15 & hour < 21) %>% # afternoon
  ggplot(data = .) +
    geom_histogram(position = "dodge", aes(x = Ein, fill = "Einstiege"), 
                   alpha = 0.75, binwidth = 1) + 
    geom_histogram(position = "dodge", aes(x = Aus, fill = "Ausstiege"), 
                   alpha = 0.75, binwidth = 1) +
  labs(title = "Ein- und Ausstiege", 
       x = "Anzahl Ein- / Ausstiege", 
       y = "Häufigkeit im Zeitraum", fill = "Legende") +
  theme_light() # change to whatever looks best


ggplot(data = df) +
  geom_histogram(aes(x = hour, fill = "stunde"), alpha = 0.25, binwidth = 1)

# at weekdays, how many travellers per hour? -> find out rush hour
# TODO
