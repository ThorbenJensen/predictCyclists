# TRAIN MODELS, MEASURE ACCURACY

library(dplyr)
library(h2o)

# CONNECT TO H2O
h2o.init()

# LOAD DATA
df <- 
  read.csv("data/processed/bus2.csv")


# import to h2o
df2 <- as.h2o(df)
result <- h2o.randomForest(training_frame = df2, 
                           x = c("weekday", "weekend", "month", "hour",
                                 "bank_holiday", "event_send", "rush_hour"),
                           y = "Ein", nfolds = 7)
summary(result)
