# LA_AQI-TEMP
Daily Los Angeles Air quality and temperature data and visualizations.

The sources for my data are [airnowapi](https://docs.airnowapi.org/) and [api.weather.gov](https://api.weather.gov/)

## Latest Daily Visualizations

![Daily Temperature](weather_proj/plots/temp_plot.png)
![Daily AQI](weather_proj/plots/aqi_plot.png)

## Summary/Reflection

I have two sources of data for these visualizations. The first is through an API for weather air quality. This data that is returned is in csv format and it is based on the automatic sensor from where it is located. So, it gives the current air quality at the time it is ran. My second source of data is temperature. This is also updated currently, and I use a specific station to get where the temperature is being read. This source is from an API as well, api.weather.gov. The call returns the data in JSON format. This data could be important for people who live in the area, Los Angeles, to see the temperature and the air quality. The air quality is the important one as during the wildfires that have been going on, the air quality gets very bad. Also, it could be interesting to see if over time the temperature and air quality get better or worse, and if wildfires may have an effect.

### Automated Data Pipeline

For my automated data pipeline I have 4 R scripts that run daily. This is handled in my workflow file where I run each script in a specific order to produce these outputs. The first 
script that runs is my data wrangler script called "weather_gather.R". In this script I have two functions to handle missing data as sometimes these specific stations I am pulling
from return no values. To handle this I make safe reading functions that read in the data and if no values are given back, they are assigned a NULL value. I do this for both sources
one being a safe csv read and another being a safe json read function. I then turn NULL values to NA before writing to a csv. Once written to the csv the data needs to be combined and
cleaned. I first have to add in a data column for my temperature file as it does not include it. Then I have to select the columns I want from the air quality csv. From here I join
the temperature with the air quality data, using the date as my left_join pattern. I then convert my temperature from Celsius to fahrenheit. I then write this cleaned and transformed
data to a csv. This csv is now used in my visualizations. I read in the csv and then make my graphs and visualizations using this cleaned dataframe.

### Interpreting

The temperature graph is a straight forward graph where you can see the daily temperature on the date that it was recorded. The air quality graph shows where the air quality is. The lower is better. The point that is used for the air quality is PM2.5. PM2.5 is fine particulate matter in the air, specifically tiny solid or liquid particles with a diameter of 2.5 micrometers or less. This can be caused from vehicle exhausts, fires, industrial activities... It is used for determining air quality as the health effects of a high PM2.5 can be dangerous.

### Challenges

The hardest part of this challenge was the data wrangling and cleaning portion. This was challenging to deal with the empty values returned. It was also challenging as the data in the temperature source did not return a date. I did not setup up my script correctly the first time I made it so I had to delete my csv with the values and replace it. This made it difficult because as mentioned before both sources did not contain the date column so I had to create a way to add date into the temp file. 


