library(ggplot2)
library(tidyr)
library(dplyr)
library(readr)

df <- read.csv("weather_proj/daily_clean_aqTemp.csv")
df$DateObserved <- as.Date(df$DateObserved)

aqi_bands <- data.frame(
  xmin = min(df$DateObserved) - 1,
  xmax = max(df$DateObserved) + 1,
  ymin = c(0, 51, 101, 151, 201, 301),
  ymax = c(50, 100, 150, 200, 300, 500),
  category = factor(
    c("Good", "Moderate", "Unhealthy for Sensitive Groups", "Unhealthy", "Very Unhealthy", "Hazardous"),
    levels = c("Good", "Moderate", "Unhealthy for Sensitive Groups", "Unhealthy", "Very Unhealthy", "Hazardous")
  )
)

# Map colors for each category
aqi_colors <- c(
  "Good" = "green",
  "Moderate" = "yellow",
  "Unhealthy for Sensitive Groups" = "orange",
  "Unhealthy" = "red",
  "Very Unhealthy" = "purple",
  "Hazardous" = "maroon"
)

# Plot
aqi_plot <- ggplot() +
  geom_rect(data = aqi_bands, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = category), alpha = 0.2) +
  geom_line(data = df, aes(x = DateObserved, y = AQI), color = "black", size = 1.5) +
  geom_point(data = df, aes(x = DateObserved, y = AQI), color = "black", size = 3) +
  scale_fill_manual(name = "AQI Category", values = aqi_colors) +
  scale_y_continuous(limits = c(0, 500), breaks = seq(0, 500, 50)) +
  scale_x_date(date_labels = "%b %d", date_breaks = "1 day") +
  labs(
    title = "Daily PM2.5 AQI in Los Angeles",
    subtitle = "Colored by AQI category",
    x = "Date",
    y = "AQI"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray40"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major = element_line(color = "gray90"),
    panel.grid.minor = element_blank()
  )

aqi_plot <- aqi_plot +
  theme(
    plot.background = element_rect(fill = "white", color = NA)
  )

dir.create("weather_proj/plots", showWarnings = FALSE)
ggsave(
  filename = "weather_proj/plots/aqi_plot.png",
  plot = aqi_plot,
  width = 8,        # width in inches
  height = 5,       # height in inches
  dpi = 300,         # resolution
  bg = "white"
)


