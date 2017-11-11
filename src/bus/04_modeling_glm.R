# MODELING WITH CLASSICAL GLM

library(dplyr)
library(glm2)
library(MASS)
library(boot)
library(sjPlot)

# LOAD DATA
#hstID = "43901" # sophienstraße
hstID = "41000" # hauptbahnhof

# load data
df <- 
  read.csv(paste0("data/processed/all_", hstID, "_enhanced.csv")) %>%
  mutate(month = as.factor(month)) %>%
  mutate(hour = as.factor(hour)) %>%
  mutate(bank_holiday = as.factor(bank_holiday)) %>%
  mutate(event_send = as.factor(event_send)) %>%
  mutate(rush_hour = as.factor(rush_hour))

# train model
model <- glm.nb(Ein 
                ~ month + weekday + month + weekend
                + bank_holiday 
                + event_send 
                # + rush_hour
                ,
                data = df)

# plot model
plot(model)
# predictions compared to data
sjp.glm(model, type = "pred", vars = c("month"))
sjp.glm(model, type = "pred", vars = c("weekday"))
# marginal effects
sjp.glm(model, type = "eff",  vars = c("month"))

# measure RMSE
mse <- cv.glm(df, model, K = 7)$delta
mse
sqrt(mse)
