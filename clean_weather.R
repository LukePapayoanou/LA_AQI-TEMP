library(dplyr)
library(readr)

temp_file <- "weather_proj/daily_LA_temp.csv"
aq_file   <- "weather_proj/daily_LA_aq.csv"

# -------------------------
# 1. Read data
# -------------------------
temp <- read.csv(temp_file)
aq   <- read.csv(aq_file)

# -------------------------
# 2. Keep only PM2.5 for AQI
# -------------------------
aq <- aq %>%
  select(DateObserved, ParameterName, AQI, CategoryNumber) %>%
  filter(ParameterName == "PM2.5") %>%
  mutate(DateObserved = as.Date(DateObserved))

# -------------------------
# 3. Add today's temperature
# -------------------------
temp_today <- temp %>%
  slice_tail(n = 1) %>%        # last row appended
  mutate(DateObserved = Sys.Date())

# -------------------------
# 4. Combine safely
# -------------------------
clean_temp_aq <- left_join(aq, temp_today, by = "DateObserved")

# Convert Celsius → Fahrenheit
clean_temp_aq <- clean_temp_aq %>%
  mutate(temp_f = (temperature * 9/5) + 32)

# -------------------------
# 5. Save cleaned file
# -------------------------
clean_file <- "weather_proj/daily_clean_aqTemp.csv"
dir.create("weather_proj", showWarnings = FALSE)

if (file.exists(clean_file)) {
  write_csv(clean_temp_aq, clean_file, append = TRUE)
} else {
  write_csv(clean_temp_aq, clean_file)
}
