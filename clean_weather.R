library(dplyr)
library(readr)

temp_file <- "weather_proj/daily_LA_temp.csv"
aq_file   <- "weather_proj/daily_LA_aq.csv"

temp <- read.csv(temp_file)
aq <- read.csv(aq_file)

aq <- aq |> select(c(DateObserved, ParameterName, AQI,CategoryNumber))
aq <- aq |> filter(ParameterName == "PM2.5")

temp_aq <- cbind(aq, temp)

clean_temp_aq <- temp_aq |> mutate(temp = (temperature * 9/5) + 32 ) |> select(-temperature)
clean_temp_aq$DateObserved <- as.Date(clean_temp_aq$DateObserved)

clean_file <- "weather_proj/daily_clean_aqTemp.csv"

dir.create("weather_proj", showWarnings = F)

if(file.exists(clean_file)){
  write_csv(clean_temp_aq, clean_file, append = T)
} else {
  write_csv(clean_temp_aq, clean_file)
}

