library(dplyr)
library(readr)
library(lubridate)

temp_file <- "weather_proj/daily_LA_temp.csv"
aq_file   <- "weather_proj/daily_LA_aq.csv"
clean_file <- "weather_proj/daily_clean_aqTemp.csv"

# 1. Read temperature & assign dates (assuming newest last)
temp <- read.csv(temp_file) %>%
  mutate(Date = Sys.Date() - rev(seq_len(n())) + 1)

# 2. Read AQI & filter PM2.5
aq <- read.csv(aq_file) %>%
  filter(ParameterName == "PM2.5") %>%
  select(DateObserved, AQI, CategoryNumber) %>%
  mutate(DateObserved = as.Date(DateObserved))

# 3. Join temp and AQI by date
clean_temp_aq <- aq %>%
  left_join(temp, by = c("DateObserved" = "Date")) %>%
  mutate(temp = temperature * 9/5 + 32) %>%
  select(DateObserved, AQI, CategoryNumber, temp)

# 4. Save cleaned file
dir.create("weather_proj", showWarnings = FALSE)

if (file.exists(clean_file)) {
  write_csv(clean_temp_aq, clean_file, append = TRUE)
} else {
  write_csv(clean_temp_aq, clean_file)
}
