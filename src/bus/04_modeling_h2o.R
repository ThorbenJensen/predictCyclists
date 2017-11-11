# TRAIN MODELS, MEASURE ACCURACY

library(dplyr)
library(h2o)

# CONNECT TO H2O
h2o.init()

# LOAD DATA
df <- 
  read.csv("data/processed/bus2.csv")


features = c("weekday", "weekend", "month", "hour",
      "bank_holiday", "event_send", "rush_hour")

# import to h2o
df2 <- as.h2o(df)

complete_h2o_split <- h2o.splitFrame(data = df2, ratios = 0.75)

train <- complete_h2o_split[[1]]
test <- complete_h2o_split[[2]]

rf1 <- h2o.randomForest(training_frame = train,
                        validation_frame = test,
                        ,
                        y = "Ein")
summary(rf1)

# predForest <- h2o.predict(object = rf1, newdata = test)

aml <- h2o.automl(x = features,
                  y = "Ein",
                  training_frame = train,
                  validation_frame = test,
                  max_runtime_secs = 60*30)

prediction <- h2o.predict(object = aml, newdata = test)

# compare prediction with train data
mean_prediction <- 
  prediction %>%
  as.data.frame() %>%
  .$predict %>%
  mean

mean_train <- 
  train %>%
  as.data.frame() %>%
  .$Ein %>%
  mean

percentage_error <- (mean_prediction - mean_train) / mean_train
