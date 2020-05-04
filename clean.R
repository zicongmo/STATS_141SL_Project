# i don'tknow the correct way to do this
# FIRST DELETE THE FIRST THREE ROWS OF THE DEPARTMENT OF AGRICULTURE DATA
income_data <- read.csv("data/unemployment_median_income_cleaned.csv")

# this is really bad
county_data <- read.csv("data/kolko_covid_shareable.csv")
names <- colnames(county_data)
names[1] <- "FIPS"
colnames(county_data) <- names

merged_data <- merge(county_data, income_data, by = "FIPS")
write.csv(merged_data, "data/project_data.csv")
