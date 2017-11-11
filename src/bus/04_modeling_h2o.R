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

# import data to h2o
df2 <- as.h2o(df)
complete_h2o_split <- h2o.splitFrame(data = df2, ratios = 0.75)
train <- complete_h2o_split[[1]]
test <- complete_h2o_split[[2]]

# train model
features <- c("weekday", "month", "hour", "minute",
             "bank_holiday", "event_send", "rush_hour",
             "apparentTemperature", "windSpeed", "precipProbability",
             "X", "Y")

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

# compare real data and prediction
df3 <- as.data.frame(test)
df3$ein_predicted <- ein_predicted

df4 <-
  df3 %>%
  dplyr::select(timestamp, Ein, ein_predicted,
                weekday, hour,
                bank_holiday, event_send, rush_hour, X, Y, date) %>%
  mutate(residual = as.numeric(ein_predicted - Ein))

# plot residuals
df4 %>%
  ggplot(.) +
  geom_histogram(aes(residual, fill = event_send))

# scatter plots of errors
df4 %>%
  filter(abs(residual) > 15) %>%
  # filter(residual < 0) %>%
  ggplot(data = ., aes(x = X, y = Y)) +
  geom_point(aes(color = residual, size = 2), alpha = .5) +
  scale_colour_gradient2() +
  theme_dark()

df4 %>%
  ggplot(.) +
  geom_point(aes(Ein, ein_predicted), alpha = .2)

# aggregate prediction to hours
df5 <-
  df4 %>%
  group_by(date, hour) %>%
  summarise(ein_sum = sum(Ein),
            ein_predicted_sum = sum(ein_predicted)) %>%
  mutate(residual = abs(ein_predicted_sum - ein_sum)) %>%
  mutate(percentage_error = abs(ein_predicted_sum - ein_sum) / ein_sum * 100)
  
  
  
  