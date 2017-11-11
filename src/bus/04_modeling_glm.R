# MODELING WITH CLASSICAL GLM

library(dplyr)
library(glm)
library(MASS)
library(boot)

# LOAD DATA
df <- 
  read.csv("data/processed/bus2.csv") %>%
  mutate(month = as.factor(month)) %>%
  mutate(hour = as.factor(hour))

# train model
model <- glm.nb(Ein 
                ~ month + weekday + month + weekend
                + bank_holiday 
                + event_send 
                # + rush_hour
                ,
                data = df)

# measure MSE
mse <- cv.glm(df, model, K = 7)$delta
mse
sqrt(mse)

# forecasting
# TODO
