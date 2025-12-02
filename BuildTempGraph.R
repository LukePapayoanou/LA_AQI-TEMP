library(ggplot2)
library(tidyr)
library(dplyr)
library(readr)

df <- read.csv("weather_proj/daily_clean_aqTemp.csv")
df$DateObserved <- as.Date(df$DateObserved)


temp_plot <- ggplot(df, aes(x = DateObserved, y = temp)) +
  geom_line(color = "#1f78b4", size = 1.5, linetype = "solid") +  # thicker line
  geom_point(color = "#e31a1c", size = 3, shape = 21, fill = "white", stroke = 1.2) +  # styled points
  scale_x_date(date_labels = "%b %d", date_breaks = "1 day") +
  scale_y_continuous(limits = c(0, max(df$temp, na.rm = TRUE) + 10)) +
  labs(
    title = "Daily Temperature in Los Angeles",
    subtitle = "Temperature (°F) recorded daily",
    x = "Date",
    y = "Temperature (°F)"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray40"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major = element_line(color = "gray90"),
    panel.grid.minor = element_blank()
  )

dir.create("weather_proj/plots", showWarnings = FALSE)

ggsave(
  filename = "weather_proj/plots/temp_plot.png",
  plot = temp_plot,
  width = 8,        # width in inches
  height = 5,       # height in inches
  dpi = 300,         # resolution
  bg = "white"
)
