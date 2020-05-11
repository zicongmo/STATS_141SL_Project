require(dplyr)

# Reads directly from updated John Hopkins sources
time_series_confirmed <- read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv")
time_series_deaths <- read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv")

# Clean up a bit, since we only care about the most recent column and the FIPS 
# Pull the county name from one of the datasets
confirmed_cleaned <- time_series_confirmed[,c(5, 11, ncol(time_series_confirmed))]
deaths_cleaned <- time_series_deaths[,c(5, ncol(time_series_deaths))]

# Store the date of the data, use it to identify the name of the generated dataset
date <- substring(colnames(confirmed_cleaned)[3], 2)

# Rename the columns
colnames(confirmed_cleaned) <- c("FIPS", "Name", "confirmed")
colnames(deaths_cleaned) <- c("FIPS", "deaths")

# Merge the two dataset on FIPS and write to file
file_name <- sprintf("data/jhu_dataset_%s.csv", date)
deaths_confirmed <- merge(confirmed_cleaned, deaths_cleaned, by = "FIPS")
write.csv(deaths_confirmed, file_name)
