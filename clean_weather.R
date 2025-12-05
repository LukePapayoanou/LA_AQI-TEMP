library(dplyr)
library(readr)
library(lubridate)

temp_file <- "weather_proj/daily_LA_temp.csv"
aq_file   <- "weather_proj/daily_LA_aq.csv"

# -------------------------
# 1. Read data
# -------------------------
temp <- read.csv(temp_file)
aq   <- read.csv(aq_file)

# -------------------------
# 2. Clean AQ data (same variables as before)
# -------------------------
aq <- aq %>%
  select(DateObserved, ParameterName, AQI, CategoryNumber) %>%
  filter(ParameterName == "PM2.5") %>%
  mutate(Date = as.Date(DateObserved))

# -------------------------
# 3. Temp data: keep only newest row but
#    keep the variable name "temperature"
# -------------------------
temp <- temp %>%
  slice_tail(n = 1) %>%
  mutate(Date = Sys.Date())

# -------------------------
# 4. Join AQ + temp by date
# -------------------------
clean_temp_aq <- left_join(aq, temp, by = "Date")

# -------------------------
# 5. Convert C → F using original output variable name "temp"
# -------------------------
clean_temp_aq <- clean_temp_aq %>%
  mutate(temp = (temperature * 9/5) + 32) %>%  # SAME NAME AS BEFORE
  select(DateObserved, ParameterName, AQI, CategoryNumber,
         temperature, temp, Date)

# -------------------------
# 6. Save
# -------------------------
clean_file <- "weather_proj/daily_clean_aqTemp.csv"
dir.create("weather_proj", showWarnings = FALSE)

if (file.exists(clean_file)) {
  write_csv(clean_temp_aq, clean_file, append = TRUE)
} else {
  write_csv(clean_temp_aq, clean_file)
}
