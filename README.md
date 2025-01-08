# The Cyclistic Project

## About Me
Welcome to the Cyclistic bike-share analysis case study! My name is Amit Bhaskar. I am from India. At the time of completing this project (Dec 2024) I am working as an operations manager in an ed tech company. I have been self learning the core principles, techniques and tech stack of data analysis for 4 months now and this project officially is a capstone project of Google's data analysis professional certificate on Coursera.

## About Cyclistic
Cyclistic is a bike sharing company based in Chicago. Operating since 2016, currently the company has a fleet of 5,824 bicycles that are geotracked and locked into a network of 692 stations across the city. Customers can choose among three bike types: classic bikes, electric bikes and electric scooters. It offers a variety of pricing plans: single-ride passes, full-day passes, and annual memberships.
Customers who purchase single-ride or full-day passes are referred to as casual riders while customers who purchase annual memberships are Cyclistic members.

## Business objectives
The company's overarching goal is to convert their casual riders into annual members. The management believes that this is the way-forward to achieve long term stability and success. To help actualise this goal, my task is to analyse the company's recent rental record and figure out how the casual riders use the bikes differently than members. The marketing team can then use these insights to tailor out sound marketing strategies.

## About the data
The data used for this project was made available online by [Motivate International Inc.](https://divvy-tripdata.s3.amazonaws.com/index.html) under the [license](https://divvybikes.com/data-license-agreement). The data is provided on a first-party basis indicating a high level of integrity. I have used the latest ride data available. It consists of 11 csv files containing ride data for each month from January 2024 to November 2024 and comprises of approximately 5.6 million data points.

## Tool used
I have done the necessary ETL, analysis and visualisations in R using R Studio. Both pragmatic and personal reason informed this choice. Prgamatic reason being the sheer size of the dataset. With each sheet having anywhere between 400-800 thousand records, I estimated my final dataset to have almost 4-5 million rows. Personal reason being I wanted to enforce the concepts I learned in the course which will enable me to deal with bulky datasets in future too.

## An outline of my approach
- Load individual sheets in R studio and ensure data consistency in all sheets.
- Bind the sheets in one big dataframe.
- Create additional calculated columns like month, day, ride duration etc.
- Plot the comparisons on the usage of bikes
- Gather insights and provide recommendations.

  
## Phase 1: Setting up the consolidated dataframe
Here I loaded the datasets into R, checked for column consistency and stacked the CSVs into one consolidated dataframe called Trips2024.
  
```r
install.packages("tidyverse")
library("tidyverse")
library(lubridate)
library(ggplot2)

#Reading the dataset CSVs
Jan<- read_csv("C:/Users/Tnluser/Desktop/Cyclist Project/202401-divvy-tripdata.csv")
Feb<- read_csv("C:/Users/Tnluser/Desktop/Cyclist Project/202402-divvy-tripdata.csv")
Mar<- read_csv("C:/Users/Tnluser/Desktop/Cyclist Project/202403-divvy-tripdata.csv")
Apr<- read_csv("C:/Users/Tnluser/Desktop/Cyclist Project/202404-divvy-tripdata.csv")
May<- read_csv("C:/Users/Tnluser/Desktop/Cyclist Project/202405-divvy-tripdata.csv")
Jun<- read_csv("C:/Users/Tnluser/Desktop/Cyclist Project/202406-divvy-tripdata.csv")
Jul<- read_csv("C:/Users/Tnluser/Desktop/Cyclist Project/202407-divvy-tripdata.csv")
Aug<- read_csv("C:/Users/Tnluser/Desktop/Cyclist Project/202408-divvy-tripdata.csv")
Sep<- read_csv("C:/Users/Tnluser/Desktop/Cyclist Project/202409-divvy-tripdata.csv")
Oct<- read_csv("C:/Users/Tnluser/Desktop/Cyclist Project/202410-divvy-tripdata.csv")
Nov<- read_csv("C:/Users/Tnluser/Desktop/Cyclist Project/202411-divvy-tripdata.csv")

#Inspecting column names and their datatypes for each sheet
str(Jan)
str(Feb)
str(Mar)
str(Apr)
str(May)
str(Jun)
str(Jul)
str(Aug)
str(Sep)
str(Oct)
str(Nov)
```
It turned out that all 11 sheets had the same column names of the same datatype as that in Jan 2024 sheet.
Appended the csv sheets into one dataframe
```r
#Consolidated Dataset
Trips2024 <- bind_rows(Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov)
View(Trips2024)
```

Trips2024 at this stage had the following 13 columns
|S.No|Column_Name|Datatype|
|-|------------|-------|
|1|ride_id|character|
|2|rideable_type|character|
|3|started_at|datetime|
|4|ended_at|datetime|
|5|start_station_name|character|
|6|start_station_id|character|
|7|end_station_name|character|
|8|end_station_id|character|
|9|start_lat|double|
|10|start_lng|double|
|11|end_lat|double|
|12|end_lng|double|
|13|member_casual|character|

## Phase 2: Transforming the dataset and getting additional columns
1. For my purposes, information about latitudes and longitudes did not hold that much value, so I decided to drop off the related columns.
2. Renamed "rideable_type" to "bike_type" and "member_casual" to "customer_type" for better readability.
3. Got the weekday and month and ride duration in separate columns from the started_at column and ended_at columns.

```{r}
#Removing start_lat, end_lat, start_lng, end_lng columns
Trips2024 <- Trips2024 %>%
  select(-start_lat, -end_lat, -start_lng, -end_lng)

#Renaming rideable_type column name to "bike_type" and "member_casual" to "customer_type" for better readability
Trips2024 <- Trips2024 %>%
  rename(`bike_type` = rideable_type)
Trips2024 <- Trips2024 %>%
  rename(`customer_type` = member_casual)

#Getting day,month in separate columns using lubridate package of tidyverse
Trips2024 <- Trips2024 %>%
  mutate(
    day_of_ride = wday(started_at, label = TRUE, abbr = TRUE),  # Extract day of the week
    month = month(started_at, label = TRUE, abbr = TRUE),# Extract month
  )

#Getting duration of rides in minutes
Trips2024 <- Trips2024 %>%
  mutate(duration = round(as.numeric(difftime(ended_at, started_at, units = "mins")), 1))
```

After these transformations at this stage, Trips2024 had the following structure:
|S.No|Column_Name|Datatype|
|-|------------|-------|
|1|ride_id|character|
|2|rideable_type|character|
|3|started_at|datetime|
|4|ended_at|datetime|
|5|start_station_name|character|
|6|start_station_id|character|
|7|end_station_name|character|
|8|end_station_id|character|
|9|start_lat|double|
|10|start_lng|double|
|11|end_lat|double|
|12|end_lng|double|
|13|member_casual|character|
