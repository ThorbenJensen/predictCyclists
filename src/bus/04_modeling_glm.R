# MODELING WITH CLASSICAL GLM

library(dplyr)
library(glm)
library(MASS)

# LOAD DATA
df <- 
  read.csv("data/processed/bus2.csv") %>%
  mutate(month = as.factor(month)) %>%
  mutate(hour = as.factor(hour))

# train model
fit <- glm.nb(Ein 
              ~ month + weekday + weekend + hour + event_send + bank_holiday),
              data = df)
fit

# measure RMSE and MAPE
