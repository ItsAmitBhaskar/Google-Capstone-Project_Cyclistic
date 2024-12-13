# TheCyclistProject
Welcome to the Cyclistic bike-share analysis case study! This was my first unguided data project and also the first time I used GitHub. This project formed a part of final course work for Google's Data Analysis Professional Certificate on Coursera. This work gave me an opportunity to apply the key techniques learned throughout the course into some real world data with real set of challenges.

## Project Background
For this project I played the role of a junior data analyst at a bike share company called Cyclistic. The company had determined that annual membership holders were more profitable than casual riders. They wanted to launch a marketing campaign targeting casual riders in order to persuade more of them to become annual members. As a part of this, my work was to analyse the differences between how casual riders and annual members used the different types of bikes available and to provide key insights that might determine their marketing strategy.

## My Approach
I adopted the six step data analysis process that I learned in the course. 

- **Ask**: Identifying the major business questions
- **Prepare**: Collecting the data and identifying how it’s organized.
- **Process**: Stage of performing the cleaning checks before diving into analysis
- **Analyze**: Organizing and formatting the data, aggregating, performing calculations and identifying trends and relationships.
- **Share**: Presenting the findings with effective visualization.
- **Act**: Sharing the final conclusion and the recommendations.

As for the tool of analysis, I used R programming language for cleaning, manipulation and vizualisations. 

## What was the ASK? 
I began with an intention to explore the data along the lines of a few broad questions:
1. How is the usage by casual riders and annual members on different days of the week? Is there any significant difference?
2. How is the usage throughout the year? Do particular months show increased usage by one group over the other?
3. How the usage differs by different times of day?
4. What are geographical hotspots of usage? How the two groups pan out geographically?
5. Are particular start stations more popular with one group over the other?
6. Of the different types of bikes available for use, do annual members use a different type of bike to casual members?

## Preparation
The data set was made available online by [Motivate International Inc.](https://divvy-tripdata.s3.amazonaws.com/index.html) under the [license](https://divvybikes.com/data-license-agreement). For the purpose of my analysis I used the csv files containing quarterly data for the four quarters of 2019 and the first quarter of 2020. The data was organised into a set of 5 csv files one for each quarter from Jan 2019 to March 2020. To prepare the data for analysis I read the files in R and did a basic inspection of the datasets.

```r
#Reading CSV files into R
q1_2019<- read_csv("C:/Users/Tnluser/Desktop/Google's Capstone Project/Divvy_Trips_2019_Q1.csv")
q2_2019<- read_csv("C:/Users/Tnluser/Desktop/Google's Capstone Project/Divvy_Trips_2019_Q2.csv")
q3_2019<- read_csv("C:/Users/Tnluser/Desktop/Google's Capstone Project/Divvy_Trips_2019_Q3.csv")
q4_2019<- read_csv("C:/Users/Tnluser/Desktop/Google's Capstone Project/Divvy_Trips_2019_Q4.csv")
q1_2020<- read_csv("C:/Users/Tnluser/Desktop/Google's Capstone Project/Divvy_Trips_2020_Q1.csv")

#Inspecting column names
colnames(q1_2019)
colnames(q2_2019)
colnames(q3_2019)
colnames(q4_2019)
colnames(q1_2020)

#Inspecting data sets
View(q1_2019)
View(q2_2019)
View(q3_2019)
View(q4_2019)
View(q1_2020)
```

## Processing the data
The preliminary check revealed files of 2019 had different headers than that of 2020 for the same data. This was the time for our first data consolidation. 
1. I renamed headers in the four quarters of 2019 files to match the headers in the file of 2020.
```r
(q1_2019 <- rename(q1_2019
                   ,ride_id = trip_id
                   ,rideable_type = bikeid
                   ,started_at = start_time
                   ,ended_at = end_time
                   ,start_station_name = from_station_name
                   ,start_station_id = from_station_id
                   ,end_station_name = to_station_name
                   ,end_station_id = to_station_id
                   ,member_casual = usertype
))

(q2_2019 <- rename(q2_2019
                   ,ride_id = '01 - Rental Details Rental ID'
                   ,rideable_type = `01 - Rental Details Bike ID`
                   ,started_at = `01 - Rental Details Local Start Time`
                   ,ended_at = `01 - Rental Details Local End Time`
                   ,start_station_name = `03 - Rental Start Station Name`
                   ,start_station_id = `03 - Rental Start Station ID`
                   ,end_station_name = `02 - Rental End Station Name`
                   ,end_station_id = `02 - Rental End Station ID`
                   ,member_casual = `User Type`
))

(q3_2019 <- rename(q3_2019
                   ,ride_id = trip_id
                   ,rideable_type = bikeid
                   ,started_at = start_time
                   ,ended_at = end_time
                   ,start_station_name = from_station_name
                   ,start_station_id = from_station_id
                   ,end_station_name = to_station_name
                   ,end_station_id = to_station_id
                   ,member_casual = usertype
))

(q4_2019 <- rename(q4_2019
                   ,ride_id = trip_id
                   ,rideable_type = bikeid
                   ,started_at = start_time
                   ,ended_at = end_time
                   ,start_station_name = from_station_name
                   ,start_station_id = from_station_id
                   ,end_station_name = to_station_name
                   ,end_station_id = to_station_id
                   ,member_casual = usertype
))

(q2_2019 <- rename(q2_2019
                   ,tripduration = `01 - Rental Details Duration In Seconds Uncapped`))
```
2. Inspecting the data types of columns revealed that ride_id and rideable_type were in numeric datatypes in 2019 datasets. Since we will eventually be merging all the datasets, it is essential to convert them to character datatype so that they can stack correctly.
```r
#changing data types of ride_id and rideable_type from num to character
q1_2019 <-  mutate(q1_2019, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type))
q2_2019 <-  mutate(q2_2019, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type)) 
q3_2019 <-  mutate(q3_2019, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type)) 
q4_2019 <-  mutate(q4_2019, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type))
```

3. Merged the 5 datasets into one and removed lat, long, birthyear, and gender fields as this data was dropped beginning in 2020
```r
#Consolidated Dataset
all_trips <- bind_rows(q1_2019,q2_2019,q3_2019,q4_2019,q1_2020)

all_trips <- all_trips %>% select(-c(tripduration,gender,birthyear,`Member Gender`,`05 - Member Details Member Birthday Year`,start_lat,start_lng,end_lat,end_lng))
```
