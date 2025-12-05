library(dplyr)
library(readr)
library(lubridate)

temp_file <- "weather_proj/daily_LA_temp.csv"
aq_file   <- "weather_proj/daily_LA_aq.csv"

# --- Read raw files ---
temp <- read.csv(temp_file)
aq   <- read.csv(aq_file)

# --- Clean AirNow data ---
aq <- aq %>%
  select(DateObserved, ParameterName, AQI, CategoryNumber) %>%
  filter(ParameterName == "PM2.5") %>%
  mutate(DateObserved = as.Date(DateObserved)) %>%
  distinct(DateObserved, .keep_all = TRUE)   # <-- ONLY ONE AQ ROW PER DAY

# --- Clean Temperature ---
temp <- temp %>%
  mutate(DateObserved = as.Date(Date)) %>%     # Date column exists in your CSV
  select(DateObserved, temperature) %>%
  distinct(DateObserved, .keep_all = TRUE) %>%
  arrange(DateObserved)

# --- Join by date ---
clean_temp_aq <- left_join(aq, temp, by = "DateObserved")

# --- Convert to Fahrenheit ---
clean_temp_aq <- clean_temp_aq %>%
  mutate(temp = (temperature * 9/5) + 32) %>%
  select(DateObserved, ParameterName, AQI, CategoryNumber, temp)

# --- Save clean file ---
clean_file <- "weather_proj/daily_clean_aqTemp.csv"
dir.create("weather_proj", showWarnings = FALSE)

write_csv(clean_temp_aq, clean_file)
