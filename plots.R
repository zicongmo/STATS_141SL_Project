# R Script used to generate explorative plots 
rm(list = ls())

## Libraries
require(dplyr)
require(ggplot2)

## Utility functions
# Returns the numeric value of the dollar amount d
# d: List of dollar values (in the form $XXX,XXX,XXX)
# returns: List of values (XXXXXXXXX)
dollar_to_numeric <- function(d) {
    return(as.numeric(gsub('[$,]', '', d)))
}


## Initial data read
path_to_data <- "data/project_data.csv"
data_full <- read.csv(path_to_data)

## Pull out relevant columns
data <- data_full %>% select(Area_name, # Name of the county
                             cases, # Total number of cases
                             deaths, # Total number of deaths
                             popestimate2019, # Population (in 2019)
                             Median_Household_Income_2018, # Median Household Income (2018)
                             age60plus # proportion of people above age 60
                             )

## Add new columns, cast datatypes of existing columns
df <- data %>% mutate(hh_income_2018 = dollar_to_numeric(Median_Household_Income_2018),
                      log_hh_income = log(hh_income_2018),
                      cases_per_capita = cases / popestimate2019,
                      mortality_rate = deaths / cases
                      )
# dataframe containing only the counties with cases AND deaths
df_with_deaths <- df %>% filter(mortality_rate > 0)

## Exploratory Plots
## 1-Variable Plots
# Distribution of the mortality rate, VERY skewed
ggplot(df, aes(x = mortality_rate)) + geom_histogram(binwidth=0.01)
# ~60% of the counties WITH CASES have no deaths
quantile(df$mortality_rate, na.rm = T, probs = seq(0, 1, 0.1))

# Distribution of the median household income
ggplot(df, aes(x = hh_income_2018)) + geom_histogram() # non-normal
ggplot(df, aes(x = log_hh_income)) + geom_histogram(binwidth = 0.02) # better

## 2-Variable Plots
# Plot cases as a function of household income
ggplot(df, aes(x = hh_income_2018, y = cases)) + geom_point()

# Plot cases as a function of log household income
ggplot(df, aes(x = log_hh_income, y = cases)) + geom_point()

# Plot per capita cases as a function of household income
ggplot(df, aes(x = hh_income_2018, y = cases_per_capita)) + geom_point()

# Plot per capita cases as a function of log household income
ggplot(df, aes(x = log_hh_income, y = cases_per_capita)) + geom_point()

# Mortality rate as a function of household income
ggplot(df, aes(x = hh_income_2018, y = mortality_rate)) + geom_point()

# Mortality rate as a function of log income
ggplot(df, aes(x = log_hh_income, y = mortality_rate)) + geom_point()

# Mortality rate as a function of percentage of people above 60
ggplot(df, aes(x = age60plus, y = mortality_rate)) + geom_point()

## Models
## Nothing stands out too much at the moment
## R2 ~ 7%, without sqrt is 5%
model <- lm(sqrt(cases_per_capita) ~ age60plus + log_hh_income, data = df)
model <- lm(cases_per_capita ~ log_hh_income, data = df)
model <- lm(mortality_rate ~ log_hh_income, data = df)
model <- lm(mortality_rate ~ hh_income_2018, data = df)
summary(model)
plot(model)

