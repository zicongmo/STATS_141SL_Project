rm(list = ls())

# Read in the JHU data for updated case counts
jhu_date <- "5.7.20" # Date of the JHU data that we want to use
jhu_file_name <- sprintf("data/jhu_dataset_%s.csv", jhu_date)
jhu_data <- read.csv(jhu_file_name)

# Read in the kolko data for socio data
kolko_file_name <- "data/kolko_covid_shareable.csv"
kolko_data <- read.csv(kolko_file_name)
kolko_names <- colnames(kolko_data)
kolko_names[1] <- "FIPS"
colnames(kolko_data) <- kolko_names

# Read in US Agriculture data on income 
income_file_name <- "data/unemployment_median_income_cleaned.csv"
income_data <- read.csv(income_file_name)
# This dataset already has its FIPS column named FIPS

# Read in US Agriculture data on poverty
poverty_file_name <- "data/poverty.csv"
poverty_data <- read.csv(poverty_file_name)
poverty_names <- colnames(poverty_data)
poverty_names[1] <- "FIPS"
colnames(poverty_data) <- poverty_names

# Merge all four datasets on FIPS
# Note that these merges drop data since not every dataset has info on every county!
jhu_kolko <- merge(jhu_data, kolko_data, by = "FIPS") # 3131 rows
jhu_kolko_income <- merge(jhu_kolko, income_data, by = "FIPS") # 3130 rows
jhu_kolko_income_poverty <- merge(jhu_kolko_income, poverty_data, by = "FIPS") # 3130 rows

# Write merged data to csv
write.csv(jhu_kolko_income_poverty, "data/dataset.csv")
