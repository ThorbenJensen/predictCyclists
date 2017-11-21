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
  # TODO remove NA's from hour way earlier ...
  filter(!is.na(hour)) %>%
  mutate(month = as.factor(month)) %>%
  mutate(hour = as.factor(hour)) %>%
  mutate(bank_holiday = as.factor(bank_holiday)) %>%
  mutate(event_send = as.factor(event_send)) %>%
  mutate(rush_hour = as.factor(rush_hour)) %>%
  mutate(weekend = as.factor(weekend)) %>%
  mutate(weekday = factor(weekday, 
                          ordered = TRUE,
                          levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")))


# train model
model <- glm.nb(Ein ~ hour #* weekday + month
                # + bank_holiday + event_send 
                # + rush_hour
                ,
                data = df)

# plot model using sjPlot package

# marginal effects
sjp.glm(model, show.ci = TRUE, facet.grid = TRUE, type = "pred")#,  vars = c("month"))
sjp.int(model, show.ci = TRUE, facet.grid = TRUE, type = "eff")#,  vars = c("month"))

# predictions compared to data
sjp.glm(model, type = "pred", vars = c("month"))
sjp.glm(model, type = "pred", vars = c("weekday"))


# measure RMSE
mse <- cv.glm(df, model, K = 7)$delta
mse
sqrt(mse)

# forecasting
# TODO
