library(shiny)
library(dplyr)
library(ggplot2)
library(lubridate)
library(readr)


ui <- fluidPage(
  uiOutput("today"),
  titlePanel("LA Weather & Air Quality Dashboard"),
  
  selectInput("range", "Days to Display:",
              choices = c("7" = 7, "30" = 30, "90" = 90, "All" = 9999),
              selected = 30),
  
  tabsetPanel(
    tabPanel("Temperature", plotOutput("tempPlot", height = "500px")),
    tabPanel("AQI", plotOutput("aqiPlot", height = "500px"))
  )
)

server <- function(input, output, session) {
  
  data <- reactive({
    read.csv("../weather_proj/daily_clean_aqTemp.csv") |>
      mutate(Date = as.Date(DateObserved))
  })
  
  filtered <- reactive({
    d <- data()
    if (input$range != 9999) {
      d <- d |> filter(Date >= max(Date) - as.numeric(input$range))
    }
    d
  })
  
  output$tempPlot <- renderPlot({
    df <- filtered()
    temp_plot <- ggplot(df, aes(x = Date, y = temp)) +
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
    temp_plot
  })
  
  output$aqiPlot <- renderPlot({
    df <- filtered()
    aqi_bands <- data.frame(
      xmin = min(df$Date) - 1,
      xmax = max(df$Date) + 1,
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
      geom_line(data = df, aes(x = Date, y = AQI), color = "black", size = 1.5) +
      geom_point(data = df, aes(x = Date, y = AQI), color = "black", size = 3) +
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
    aqi_plot
    
  })
  
  output$today <- renderUI({
    df <- data()
    latest <- df[nrow(df), ]
    
    tagList(
      strong("Today's Temp: "), round(latest$temp,1), "°F", br(),
      strong("Today's AQI: "), latest$AQI
    )
  })
}

shinyApp(ui, server)


