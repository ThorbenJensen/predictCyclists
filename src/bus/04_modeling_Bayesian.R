# TRAIN MODELS, MEASURE ACCURACY

# TODO
# center predictors? 
library(brms)

# load data
passengers = read.csv("data/processed/bus2.csv")
passengers$month = as.factor(passengers$month)
# ordered factors don't survive .csv storing, so, re-order weekdays:
passengers$weekday = factor(passengers$weekday, 
                            ordered = TRUE,
                            levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))


noOfCores <- parallel::detectCores()

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
             data = passengers[!is.na(passengers$hour),])

monthm <- brm(Ein ~ month,
              cores = noOfCores,
              family = negbinomial,
              data = passengers)

sendm <- brm(Ein ~ event_send,
             cores = noOfCores,
             family = negbinomial,
             data = passengers)

hour_weekdaym <- brm(Ein ~ poly(hour, 3) * weekday,
                     cores = noOfCores,
                     family = negbinomial,
                     data = passengers)

hour_weekday_sendm <- brm(Ein ~ poly(hour, 3) * weekday * event_send,
                          cores = noOfCores,
                          family = negbinomial,
                          data = passengers)

weekday_month_rushm <- brm(Ein ~ weekday * month,
                           cores = noOfCores,
                           family = negbinomial,
                           data = passengers[passengers$rush_hour == TRUE,])

hour_weekday_month_sendm <- brm(Ein ~ poly(hour, 3) * weekday * month * event_send,
                                cores = noOfCores,
                                family = negbinomial,
                                data = passengers)

save(weekdaym, file = "weekday.RData")
save(weekday_rushm, file = "weekday_rush.RData")
save(hourm, file = "hourl.RData")
save(monthm, file = "month.RData")
save(sendm, file = "send.RData")
save(hour_weekdaym, file = "hour_weekday.RData")
save(hour_weekday_sendm, file = "hour_weekday_send.RData")
save(weekday_month_rushm, file = "weekday_month_rush.RData")
save(hour_weekday_month_sendm, file = "hour_weekday_month_send.RData")

#####
## pick the model you are interested in
m = weekday_month_rushm

# plots
pp_check(m)
plot(marginal_effects(m), points = F)
plot(marginal_effects(m), points = T, point_args = list(alpha = 0.025, width = 0.25, height = 0.25))

######## goodness-of-fit measures
# loo, leave-one-out criterion, see loo package
# lower LOO is better,
# negbinomial is better (poisson models were tested bud deleted from this file due to a cleaner code)
loo(m)
