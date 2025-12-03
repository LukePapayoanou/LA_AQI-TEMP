library(rvest)
library(tidyr)
library(xml2)
library(jsonlite)
library(dplyr)
library(readr)

# Increase timeout for slow API responses
options(timeout = 120)

# --- Safe CSV read with retries ---
safe_read_csv <- function(url, retries = 3) {
  attempt <- 1
  while (attempt <= retries) {
    tryCatch({
      df <- read.csv(url)
      if (is.null(df) || nrow(df) == 0) {
        message("AirNow returned empty data.")
        return(NULL)
      }
      return(df)
    }, error = function(e) {
      message("Attempt ", attempt, " failed: ", e$message)
      attempt <<- attempt + 1
      Sys.sleep(5)  # wait 5 seconds before retrying
      if (attempt > retries) return(NULL)
    })
  }
}

# --- Safe JSON read ---
safe_fromJSON <- function(url) {
  tryCatch({
    data <- jsonlite::fromJSON(url)
    if (is.null(data)) {
      message("Weather.gov returned NULL JSON.")
      return(NULL)
    }
    return(data)
  }, error = function(e) {
    message("Error reading Weather.gov JSON: ", e$message)
    return(NULL)
  })
}

# -----------------------------
# 1. GET AIRNOW AQ DATA SAFELY
# -----------------------------
aq_url <- paste0(
  "https://www.airnowapi.org/aq/observation/zipCode/current/?format=text/csv&zipCode=90002&distance=25&API_KEY=BD7D054A-5BA5-4637-96D6-A7110E959E8C"
)

aq <- safe_read_csv(aq_url)

# -----------------------------
# 2. GET WEATHER TEMPERATURE SAFELY
# -----------------------------
url <- "https://api.weather.gov/stations/STFC1/observations/latest"

raw_temp <- safe_fromJSON(url)

# Extract temperature safely
if (!is.null(raw_temp) &&
    !is.null(raw_temp$properties$temperature$value)) {
  
  temp <- data.frame(temperature = raw_temp$properties$temperature$value)
  
} else {
  
  message("Temperature field missing or NULL — setting temp = NA.")
  temp <- data.frame(temperature = NA)
}

# -----------------------------
# 3. WRITE CSV FILES SAFELY
# -----------------------------
dir.create("weather_proj", showWarnings = FALSE)

temp_file <- "weather_proj/daily_LA_temp.csv"
aq_file <- "weather_proj/daily_LA_aq.csv"

# Temperature
if (!is.null(temp)) {
  if (file.exists(temp_file)) {
    write_csv(temp, temp_file, append = TRUE)
  } else {
    write_csv(temp, temp_file)
  }
} else {
  message("Temperature data is NULL, skipping write.")
}

# AirNow AQ
if (!is.null(aq)) {
  if (file.exists(aq_file)) {
    write_csv(aq, aq_file, append = TRUE)
  } else {
    write_csv(aq, aq_file)
  }
} else {
  message("AirNow data is NULL, skipping write.")
}
