# TheCyclistProject

## About Me
Welcome to the Cyclistic bike-share analysis case study! My name is Amit Bhaskar. I am from India. At the time of completing this project (Dec 2024) I am working as an operations manager in an ed tech company. I have been self teaching myself the core principles, techniques and tech stack of data analysis for 4 months now and this project officially is a capstone project of Google's data analysis professional certificate on Coursera.

## Business objectives
As part of this project, I have to analyse a real dataset of bike rentals and help the company find some insights on bike usage to help drive a sound marketing strategy. The company's overarching goal is to convert their casual riders (those who take a single-ride-pass or daily pass) into subscribed members. The management believes that this is the way-to-go to achieve long term stability and success. To help actualise this goal, my task is to analyse the available dataset and figure out how the casual riders use the bikes differently than members.

## About the data
The data used for this project is a real data set of a company called Divvybikes based out of the city of Chicago. The dataset could be found a






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
## Processing the data
