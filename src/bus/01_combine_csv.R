# COMBINE CSV FILES

library(dplyr)

files <- dir("data/raw/bus/Aktuell/", full.names = T)

target <- data.frame(Datum = character(),
                     Zeit = character(),
                     Ein = numeric(),
                     Aus = numeric(),
                     HstCode = integer(),
                     HstName = character(),
                     Wagen = numeric(),
                     X = numeric(),
                     Y = numeric())

# read file
i <- 1
number_files <- length(files)
for (file in files) {
  # print(paste("file: ", file))
  print(paste("iteration", i, "of", number_files))
  # process dataframe
  df <- read.csv2(file, sep = ";", row.names = NULL, fileEncoding = "ISO-8859-1")
  # TODO: correct encoding
  
  # shift colnames to left
  colnames(df) <- colnames(df)[-1]
  
  # select and filter
  # Linie, Datum, Zeit, Ein, Aus, HstCode, HstName, Wagen, X, Y
  df <-
    df %>% 
    select(Linie, Datum, Zeit, Ein, Aus, HstCode, HstName, Wagen, X, Y) %>%
    filter(HstName == "Sophienstraße") %>%
    filter(complete.cases(.))

  target <- rbind(target, df)
  i <- i + 1
}

write.csv(target, "data/processed/bus.csv")
