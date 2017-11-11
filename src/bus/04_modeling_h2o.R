# TRAIN MODELS, MEASURE ACCURACY

library(dplyr)
library(h2o)

# CONNECT TO H2O
h2o.init()

# LOAD DATA
# hstID <- "43901" # sophienstra
hstID <- "41000" # hauptbahnhof
df <- 
  read.csv(paste0("data/processed/all_" , hstID,  "_enhanced.csv"))

features = c("weekday", "month", "hour", "minute",
      "bank_holiday", "event_send", "rush_hour",
      "apparentTemperature", "windSpeed", "precipProbability")

# import to h2o
df2 <- as.h2o(df)

complete_h2o_split <- h2o.splitFrame(data = df2, ratios = 0.75)

train <- complete_h2o_split[[1]]
test <- complete_h2o_split[[2]]

# rf1 <- h2o.randomForest(training_frame = train,
#                         validation_frame = test,
#                         ,
#                         y = "Ein")
# summary(rf1)

# predForest <- h2o.predict(object = rf1, newdata = test)

aml <- h2o.automl(x = features,
                  y = "Ein",
                  training_frame = train,
                  validation_frame = test,
                  max_runtime_secs = 60)

prediction <- h2o.predict(object = aml, newdata = test)

# compare prediction with train data
ein_predicted <- 
  prediction %>%
  as.data.frame() %>%
  .$predict

ein_test <- 
  test %>%
  as.data.frame() %>%
  .$Ein

residuals <- ein_predicted - ein_test

df3 <- as.data.frame(test)
df3$ein_predicted <- ein_predicted

df3 %>%
  dplyr::select(timestamp, Ein, ein_predicted,
                weekday, hour,
                bank_holiday, event_send, rush_hour) %>%
  View()


percentage_error <- (mean_prediction - mean_train) / mean_train
