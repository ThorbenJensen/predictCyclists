# TRAIN MODELS, MEASURE ACCURACY

library(h2o)
h2o.init(nthreads = -1, max_mem_size = "2G")

# LOAD DATA
df <- read.csv("data/processed/bus2.csv")

# START H2O
