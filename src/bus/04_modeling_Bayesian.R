# TRAIN MODELS, MEASURE ACCURACY

# TODO
# center predictors? 
library(brms)
library(boot)
library(dplyr)

#hstID = "43901" # sophienstraße
hstID = "41000" # hauptbahnhof

# load data
passengers = read.csv(paste0("data/processed/all_", hstID, "_enhanced.csv")) %>%
  # TODO remove NA's from hour way earlier ...
  filter(!is.na(hour)) %>%
  filter(hour >= 7 & hour <= 22) %>% # TODO: just for presentation and quicker model convergence
  filter(Ein != 0) %>%
  filter(Aus != 0) %>%
  filter(weekend == FALSE) %>%
  filter(month == 3) %>%
  filter(year == 2017) %>%
  mutate(month = as.factor(month)) %>%
  mutate(bank_holiday = as.factor(bank_holiday)) %>%
  mutate(event_send = as.factor(event_send)) %>%
  mutate(rush_hour = as.factor(rush_hour)) %>%
  mutate(weekend = as.factor(weekend)) %>%
  mutate(weekday = factor(weekday, 
                          ordered = TRUE,
                          levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")))



noOfCores <- parallel::detectCores()

# stunde, wochentag, monat, wetter?

weekdaym <- brm(Ein ~ weekday,
                cores = noOfCores,
                family = negbinomial,
                data = passengers)

weekday_rushm <- brm(Ein ~ weekday,
                     cores = noOfCores,
                     family = negbinomial,
                     data = passengers[passengers$rush_hour == TRUE,])

hourm <- brm(Ein ~ poly(hour, 3),
             cores = noOfCores,
             family = negbinomial,
             data = passengers)

hour_weekdaym <- brm(Ein ~ poly(hour, 3) * weekday,
             cores = noOfCores,
             family = negbinomial,
             data = passengers)

monthm <- brm(Ein ~ month,
              cores = noOfCores,
              family = negbinomial,
              data = passengers)

sendm <- brm(Ein ~ event_send,
             cores = noOfCores,
             family = negbinomial,
             data = passengers)

hour_weekdaym <- brm(Ein ~ poly(hour, 3) + weekday,
                     cores = noOfCores,
                     family = negbinomial,
                     data = passengers[!is.na(passengers$hour),])

hour_weekday_sendm <- brm(Ein ~ poly(hour, 3) * weekday * event_send,
                          cores = noOfCores,
                          family = negbinomial,
                          data = passengers)

weekday_month_rushm <- brm(Ein ~ weekday * month,
                           cores = noOfCores,
                           family = negbinomial,
                           data = passengers[passengers$rush_hour == TRUE,])

hour_weekday_monthm <- brm(Ein ~ poly(hour, 3) + weekday + month,
                                cores = noOfCores,
                                family = negbinomial,
                                data = passengers[!is.na(passengers$hour),])

hour_weekday_month_sendm <- brm(Ein ~ poly(hour, 3) * weekday * month * event_send,
                                cores = noOfCores,
                                family = negbinomial,
                                data = passengers)

save(weekdaym, file = "weekdayhbf.RData")
save(hourm, file = "hourhbf.RData")
save(hour_weekdaym, file = "hourWeekdayhbf.RData")

save(weekday_rushm, file = "weekday_rush.RData")


save(hourm, file = "hour.RData")
save(monthm, file = "month.RData")
save(sendm, file = "send.RData")
save(hour_weekdaym, file = "hour_weekday.RData")
save(hour_weekday_sendm, file = "hour_weekday_send.RData")
save(weekday_month_rushm, file = "weekday_month_rush.RData")
save(hour_weekday_month_sendm, file = "hour_weekday_month_send.RData")

#####
## pick the model you are interested in
m = hourm
  
# plots
pp_check(m)
plot(marginal_effects(m), points = F)
plot(marginal_effects(m), points = T, point_args = list(alpha = 0.025, width = 0.25, height = 0.25))


load("results/hourhbf.RData")
library(brms)
## hour plot
plot(marginal_effects(hourm), points = F, plot = F)[[1]] + 
  labs(title = "Tagesverlauf Einstiege, Hbf, März 2017, Modellvorhersage", x = "Stunde", y = "Einstiege") + 
  scale_x_continuous(breaks = 7:22) + 
  coord_cartesian(ylim = 0:18) +
  scale_y_continuous(breaks = seq(0, 18, by = 2)) + 
  theme_light() # change to whatever looks best

load("results/weekdayhbf.RData")
## hour plot
plot(marginal_effects(weekdaym), points = F, plot = F)[[1]] + 
  labs(title = "Wochenverlauf Einstiege, Hbf, März 2017, Modellvorhersage", x = "Stunde", y = "Einstiege") + 
 # scale_x_continuous(breaks = 7:22) + 
  coord_cartesian(ylim = 0:18) +
  scale_y_continuous(breaks = seq(0, 18, by = 2)) + 
  theme_light() # change to whatever looks best



######## goodness-of-fit measures
# loo, leave-one-out criterion, see loo package
# lower LOO is better,
# negbinomial is better (poisson models were tested bud deleted from this file due to a cleaner code)
loo(m)
# measure RMSE
mse <- cv.glm(df, m, K = 7)$delta
mse
sqrt(mse)
