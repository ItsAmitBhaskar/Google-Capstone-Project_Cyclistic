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

#Consolidated Dataset
Trips2024 <- bind_rows(Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov)
View(Trips2024)

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

# Prepare data
ride_share <- Trips2024 %>%
  group_by(customer_type) %>%
  summarise(total_rides = n()) %>%
  mutate(percentage = total_rides / sum(total_rides) * 100)

# Calculate total rides in 2024
total_rides_2024 <- sum(ride_share$total_rides)

# Create the pie chart
ggplot(ride_share, aes(x = "", y = percentage, fill = customer_type)) +
geom_bar(stat = "identity", width = 1, color = "white") +
coord_polar(theta = "y") +
labs(title = "Percentage Share of Casuals and Members in 2024 Rides", x = NULL, y = NULL) +
theme_void() +
theme(legend.title = element_blank())+
geom_text(aes(label = paste0( total_rides, "\n",
          round(percentage, 1), "%")),  # Add ride count and percentage labels
          position = position_stack(vjust = 0.5), size = 5, color = "white")+
  annotate("text", x = 1, y = 0.5, 
           label = paste("Total Rides:", total_rides_2024), 
           hjust = 0.5, vjust = 0, 
           size = 4, color = "black")

# Prepare the data: count rides by customer type and month
rides_by_month <- Trips2024 %>%
  group_by(customer_type, month) %>%
  summarise(no_of_rides = n(), .groups = "drop")  # Avoids grouping warning

# Create the plot
ggplot(rides_by_month, aes(x = factor(month), y = no_of_rides, fill = customer_type)) +
  geom_bar(stat = "identity", position = "dodge",width = 0.7  ) +
  labs(title = "Number of Rides by Customer Type Across Months",
       x = "Month", y = "Number of Rides") +
  scale_x_discrete(labels = month.abb) + # Use scale_x_discrete() for months
  scale_y_continuous(labels = function(x) format(x, big.mark = ",", scientific = FALSE)) +
  theme_minimal() +
  theme(legend.title = element_blank())  # Removes legend title

# Prepare the data: count rides by customer type and weekday
rides_by_weekday <- Trips2024 %>%
  group_by(customer_type, day_of_ride) %>%
  summarise(no_of_rides = n(), .groups = "drop")  # Avoids grouping warning

# Create the plot
ggplot(rides_by_weekday, aes(x = factor(day_of_ride, levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")),
                             y = no_of_rides, fill = customer_type)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +  # Decrease width for more space between bars
  labs(title = "Number of Rides by Customer Type Across Weekdays",
       x = "Weekday", y = "Number of Rides") +
  scale_x_discrete(labels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")) +  # Abbreviated weekday names
  scale_y_continuous(labels = function(x) format(x, big.mark = ",", scientific = FALSE)) +  # Format y-axis labels as commas
  theme_minimal() +
  theme(legend.title = element_blank())+  # Removes legend title
  geom_text(aes(label = no_of_rides), position = position_dodge(width = 0.7), vjust = -0.3, size = 2.9)  # Show number above bars

# Prepare the data: calculate average duration by customer type and weekday
avg_duration_by_weekday <- Trips2024 %>%
  group_by(customer_type, day_of_ride) %>%
  summarise(avg_duration = round(mean(duration), 1), .groups = "drop")  # Calculate average duration and round to 1 decimal place

# Create the plot
ggplot(avg_duration_by_weekday, aes(x = factor(day_of_ride, levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")),
                                    y = avg_duration, fill = customer_type)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +  # Bar chart with dodged bars
  labs(title = "Average Duration of Rides by Customer Type Across Weekdays",
       x = "Weekday", y = "Average Duration (minutes)") +
  scale_x_discrete(labels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")) +  # Abbreviated weekday names
  scale_y_continuous(labels = function(x) format(x, big.mark = ",", scientific = FALSE)) +  # Format y-axis labels as commas
  theme_minimal() +
  theme(legend.title = element_blank()) +  # Removes legend title
  geom_text(aes(label = avg_duration), position = position_dodge(width = 0.7), vjust = -0.3, size = 3)  # Show average duration above bars

   # Ensure 'started_at' is in the correct datetime format
Trips2024 <- Trips2024 %>%
  mutate(started_at = as.POSIXct(started_at))  # If not already in POSIXct format
  # Extract the hour of the day from 'started_at'
Trips2024 <- Trips2024 %>%
  mutate(hour_of_day = format(started_at, "%H"))

# Group by 'customer_type' and 'hour_of_day', then count the number of rides
ride_count_by_time <- Trips2024 %>%
  group_by(customer_type, hour_of_day) %>%
  summarise(ride_count = n(), .groups = 'drop')

# Plot the line graph
ggplot(ride_count_by_time, aes(x = as.numeric(hour_of_day), y = ride_count, color = customer_type)) +
  geom_line() +
  labs(
    title = "Rides Start Time Across Time of Day",
    x = "Hour of Day",
    y = "Number of Rides",
    color = "Customer Type"
  ) +
  scale_x_continuous(breaks = seq(0, 23, by = 2)) + 
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +  # Prevent scientific notation on y-axis
  theme_minimal()

   ggplot(data = Trips2024, aes(x = bike_type, fill = customer_type)) +
  geom_bar(position = "dodge", stat = "count") +
  geom_text(
    stat = "count",
    aes(label = after_stat(count)),
    position = position_dodge(width = 0.9),
    vjust = -0.5
  ) +
  labs(
    title = "Number of Rentals by Members and Casuals by Bike Type",
    x = "Bike Type",
    y = "Number of Rentals",
    fill = "Customer Type"
  ) +
  theme_minimal()           
