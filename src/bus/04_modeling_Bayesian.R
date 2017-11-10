# TRAIN MODELS, MEASURE ACCURACY

# TODO
# center predictors? 
library(brms)

# load data
passengers = read.csv("data/processed/bus2.csv")

# ordered factors don't survive .csv storing, so, re-order weekdays:
passengers$weekday = factor(passengers$weekday, 
                       ordered = TRUE,
                       levels = c("Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"))

# 

noOfCores <- parallel::detectCores()

weekday_negbinomial <- brm(Ein ~ weekday,
                    cores = noOfCores,
                    family = negbinomial,
                     data = passengers)

weekday_poisson <- brm(Ein ~ weekday,
                    cores = noOfCores,
                    family = poisson,
                     data = passengers)

hour_negbinomial <- brm(Ein ~ hour,
                    cores = noOfCores,
                    family = negbinomial,
                     data = passengers)

hour_poisson <- brm(Ein ~ hour,
                    cores = noOfCores,
                    family = poisson,
                     data = passengers)

month_negbinomial <- brm(Ein ~ month,
                    cores = noOfCores,
                    family = negbinomial,
                     data = passengers)

month_poisson <- brm(Ein ~ month,
                    cores = noOfCores,
                    family = poisson,
                     data = passengers)

hour_weekday_negbinomial <- brm(Ein ~ hour * weekday,
                    cores = noOfCores,
                    family = negbinomial,
                     data = passengers)

hour_weekday_poisson <- brm(Ein ~ hour * weekday,
                    cores = noOfCores,
                    family = poisson,
                     data = passengers)

save(weekday_negbinomial, file = "weekday_negbinomial.RData")
save(weekday_poisson, file = "weekday_poisson.RData")
save(hour_negbinomial, file = "hour_negbinomial.RData")
save(hour_poisson, file = "hour_poisson.RData")
save(month_negbinomial, file = "month_negbinomial.RData")
save(month_poisson, file = "month_poisson.RData")
save(hour_weekday_negbinomial, file = "hour_weekday_negbinomial.RData")
save(hour_weekday_poisson, file = "hour_weekday_poisson.RData")

######## goodness-of-fit measures
# loo, leave-one-out criterion, see loo package
# lower LOO is better,
loo(weekday_negbinomial)
loo(weekday_poisson)
loo(hour_negbinomial)
loo(hour_poisson)
loo(month_negbinomial)
loo(month_poisson)
loo(hour_weekday_negbinomial)
loo(hour_weekday_poisson)
# negbinomial is better (for now)

m = weekday_negbinomial

plot(marginal_effects(m), points = T, point_args = list(alpha = 0.025, width = 0.25, height = 0.25))
