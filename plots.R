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
path_to_data <- "data/dataset.csv"
data_full <- read.csv(path_to_data)

# Pull out relevant columns
data <- data_full %>% select(Name, # Name of the county
                             confirmed, # Total number of cases
                             deaths.x, # Total number of deaths
                             popestimate2019, # Population (in 2019)
                             Median_Household_Income_2018, # Median Household Income (2018)
                             age60plus, # proportion of people above age 60
                             hospitality_jobs,
                             black_pct,
                             hisp_pct,
                             asian_pct,
                             college,
                             PCTPOVALL_2018,
                             density,
                             Unemployment_rate_2018,
                             wfh_share
                             )

# Add new columns, cast datatypes of existing columns
df <- data %>% mutate(hh_income_2018 = dollar_to_numeric(Median_Household_Income_2018),
                      log_hh_income = log(hh_income_2018),
                      cases_per_capita = confirmed / popestimate2019,
                      mortality_rate = deaths.x / confirmed,
                      deaths = deaths.x
                      )

# dataframe containing only the counties with cases AND deaths
df_with_deaths <- df %>% filter(mortality_rate > 0)
df_deaths_cases100 <- df_with_deaths %>% filter(confirmed > 100)
# There doesn't seem to be a direct need to take log of mortality rate aside from interpretability
df_deaths_cases100 <- df_deaths_cases100 %>% mutate(log_mortality_rate = log(mortality_rate),
                                                    log_college = log(college),
                                                    log_age = log(age60plus),
                                                    log_hisp = log(hisp_pct),
                                                    log_hospitality = log(hospitality_jobs))

# Restricting to 100+ cases makes the distribution of mortality rate much better
# Note that this basically means that we're restricting ourselves to high population counties
# In this case, it may be better to just choose a population cutoff rather than a case cutoff
# df_cases <- df %>% filter(cases >= 100)
# nrow(df_cases) # go from 3301 counties -> 451 counties
# # Compare the average population of this group with average population
# df_cases %>% summarise(avg_pop = mean(popestimate2019)) # ~500k
# df %>% summarise(avg_pop = mean(popestimate2019)) # ~100k
# 
# df_population <- df %>% filter(popestimate2019 > 100000)
# ggplot(df_population, aes(x = mortality_rate)) + geom_histogram(binwidth = 0.01)
# 
# ## Exploratory Plots
# ## 1-Variable Plots
# # Distribution of the mortality rate, VERY skewed
# ggplot(df, aes(x = mortality_rate)) + geom_histogram(binwidth=0.01)
# # ~60% of the counties WITH CASES have no deaths
# quantile(df$mortality_rate, na.rm = T, probs = seq(0, 1, 0.1))
# 
# # We can see from this that mortality rate ends up being quite skewed due to low case counts
# # Might want to restrict our data to the counties with higher case counts
# # Can also look at the state level, since we're more likely to have sufficient data for states
# head(df %>% arrange(desc(mortality_rate)) %>% select(Area_name.x, deaths, cases, mortality_rate), n = 20)
# df %>% filter(mortality_rate > 0.24) %>% summarise(avg_deaths = mean(deaths))
# df %>% filter(mortality_rate <= 0.24) %>% summarise(avg_deaths = mean(deaths))
# 
# # Distribution of the median household income
# ggplot(df, aes(x = hh_income_2018)) + geom_histogram() # non-normal 
# ggplot(df, aes(x = log_hh_income)) + geom_histogram(binwidth = 0.02) # better
# 
# ## 2-Variable Plots
# # Plot cases as a function of household income
# ggplot(df, aes(x = hh_income_2018, y = cases)) + geom_point()
# 
# # Plot cases as a function of log household income
# ggplot(df, aes(x = log_hh_income, y = cases)) + geom_point()
# 
# # Plot per capita cases as a function of household income
# ggplot(df, aes(x = hh_income_2018, y = cases_per_capita)) + geom_point()
# 
# # Plot per capita cases as a function of log household income
# ggplot(df, aes(x = log_hh_income, y = cases_per_capita)) + geom_point()
# 
# # Mortality rate as a function of household income
# ggplot(df, aes(x = hh_income_2018, y = mortality_rate)) + geom_point()
# 
# # Mortality rate as a function of log income
# ggplot(df, aes(x = log_hh_income, y = mortality_rate)) + geom_point()
# 
# # Mortality rate as a function of percentage of people above 60
# ggplot(df, aes(x = age60plus, y = mortality_rate)) + geom_point()
# 
# ## Models
# ## Nothing stands out too much at the moment
# ## R2 ~ 7%, without sqrt is 5%
# model <- lm(sqrt(cases_per_capita) ~ age60plus + log_hh_income, data = df)
# model <- lm(cases_per_capita ~ log_hh_income, data = df)
# model <- lm(mortality_rate ~ log_hh_income, data = df)
# model <- lm(mortality_rate ~ log_hh_income + age60plus, data = df)
# summary(model)
# plot(model)

# look for education level data, median house prices
require(scales)

# Histogram of median household income
hh_income_histogram <- ggplot(df_deaths_cases100, aes(x = hh_income_2018)) +
    geom_histogram() + 
    xlab("2018 Median Household Income") + ylab("Count") + 
    ggtitle("Frequency of 2018 Median Household Income") + 
    scale_x_continuous(labels = comma)
print(hh_income_histogram)
ggsave("plots/hh_income_histogram.png", hh_income_histogram, device = "png")

# Histogram of log median household income
log_hh_income_histogram <- ggplot(df_deaths_cases100, aes(x = log_hh_income)) +
    geom_histogram() + 
    xlab("Log of 2018 Median Household Income") + ylab("Count") + 
    ggtitle("Frequency of Log 2018 Median Household Income") + 
    scale_x_continuous(labels = comma)
print(log_hh_income_histogram)
ggsave("plots/log_hh_income_histogram.png", log_hh_income_histogram, device = "png")

# Histogram of mortality rate
mortality_rate_histogram <- ggplot(df_deaths_cases100, aes(x = mortality_rate)) + 
    geom_histogram(binwidth=0.01) + 
    xlab("Mortality Rate") + ylab("Count") + 
    ggtitle("Frequency of Mortality Rates")
print(mortality_rate_histogram)
ggsave("plots/mortality_rate_histogram.png", mortality_rate_histogram, device = "png")

# Histogram of log mortality rate
log_mortality_rate_histogram <- ggplot(df_deaths_cases100, aes(x = log_mortality_rate)) + 
    geom_histogram(binwidth = 0.1) + 
    xlab("Log Mortality Rate") + ylab("Count") + 
    ggtitle("Frequency of Log Mortality Rate")
print(log_mortality_rate_histogram)
ggsave("plots/log_mortality_rate_histogram.png", log_mortality_rate_histogram, device = "png")

# cases_deaths_income_plot <- ggplot(df_deaths_cases100, aes(x = confirmed, y = deaths, col = log_hh_income)) + 
#     geom_point() 
# print(cases_deaths_income_plot)
# ggsave("plots/cases_deaths_income_scatterplot.png", cases_deaths_income_plot, device = "png")

# Plotting mortality rate as a function of log income
mortality_rate_income_plot <- ggplot(df_deaths_cases100, aes(x = log_hh_income, y = mortality_rate)) + 
    geom_point() + geom_smooth(method = lm, color = "red", fill = "blue") + 
    xlab("Log of 2018 Median Household Income") + ylab("Mortality Rate")
print(mortality_rate_income_plot)
ggsave("plots/mortality_rate_income_scatterplot.png", mortality_rate_income_plot, device = "png")

# Plotting log mortality rate as a function of log income
log_mortality_rate_income_plot <- ggplot(df_deaths_cases100, aes(x = log_hh_income, y = log_mortality_rate)) + 
    geom_point() + geom_smooth(method = lm, color = "red", fill = "blue") + 
    xlab("Log of 2018 Median Household Income") + ylab("Log of Mortality Rate")
print(log_mortality_rate_income_plot)
ggsave("plots/log_mortality_rate_income_scatterplot.png", log_mortality_rate_income_plot, device = "png")


# mortality_rate_income_college_plot <- ggplot(df_deaths_cases100, aes(x = log_hh_income, y = mortality_rate, col = college)) + 
#     geom_point()
# print(mortality_rate_income_college_plot)
# ggsave("plots/mortality_rate_income_college_scatterplot.png", mortality_rate_income_plot, device = "png")

# Plotting mortality rate as a function of pct college educated
mortality_rate_college_plot <- ggplot(df_deaths_cases100, aes(x = college, y = mortality_rate)) + 
    geom_point() + geom_smooth(method = lm, color = "red", fill = "blue") + 
    xlab("Proportion of people with bachelors degree or higher") + ylab("Mortality Rate")
print(mortality_rate_college_plot)
ggsave("plots/mortality_rate_college_scatterplot.png", mortality_rate_college_plot, device = "png")

# Plotting log mortality rate as a function of log pct college educated
log_mortality_rate_log_college_plot <- ggplot(df_deaths_cases100, aes(x = log_college, y = log_mortality_rate)) + 
    geom_point() + geom_smooth(method = lm, color = "red", fill = "blue") +
    xlab("Log of Proportion of people with college education") + ylab("Log of Mortality Rate")
print(log_mortality_rate_log_college_plot)
ggsave("plots/log_mortality_rate_log_college_scatterplot.png", log_mortality_rate_log_college_plot, device = "png")


# Plotting mortality rate as a function of prop of county aged 60+
mortality_rate_age_plot <- ggplot(df_deaths_cases100, aes(x = age60plus, y = mortality_rate)) + 
    geom_point() + geom_smooth(method = lm, color = "red", fill = "blue") + 
    xlab("Proportion of people aged 60+") + ylab("Mortality Rate")
print(mortality_rate_age_plot)
ggsave("plots/mortality_rate_age_scatterplot.png", mortality_rate_age_plot, device = "png")

# Plotting log mortality rate as a function of log prop of county aged 60+
log_mortality_rate_log_age_plot <- ggplot(df_deaths_cases100, aes(x = log_age, y = log_mortality_rate)) + 
    geom_point() + geom_smooth(method = lm, color = "red", fill = "blue") + 
    xlab("Log of Proportion of people aged 60+") + ylab("Log of Mortality Rate")
print(log_mortality_rate_log_age_plot)
ggsave("plots/log_mortality_rate_log_age_scatterplot.png", log_mortality_rate_log_age_plot, device = "png")


# Plotting mortality rate as a function of prop of county hispanic
mortality_rate_hisp_pct_plot <- ggplot(df_deaths_cases100, aes(x = hisp_pct, y = mortality_rate)) + 
    geom_point() + geom_smooth(method = lm, color = "red", fill = "blue") + 
    xlab("Proportion of Hispanic") + ylab("Mortality Rate")
print(mortality_rate_hisp_pct_plot)
ggsave("plots/mortality_rate_hisp_pct_scatterplot.png", mortality_rate_hisp_pct_plot, device = "png")

# Plotting log mortality rate as a function of log prop of county hispanic
log_mortality_rate_log_hisp_pct_plot <- ggplot(df_deaths_cases100, aes(x = log_hisp, y = log_mortality_rate)) + 
    geom_point() + geom_smooth(method = lm, color = "red", fill = "blue") + 
    xlab("Log of Proportion of Hispanic") + ylab("Log of Mortality Rate")
print(log_mortality_rate_log_hisp_pct_plot)
ggsave("plots/log_mortality_rate_log_hisp_pct_scatterplot.png", log_mortality_rate_log_hisp_pct_plot, device = "png")


# Plotting mortality rate as a function of prop of jobs in hospitality
mortality_rate_hospitality_plot <- ggplot(df_deaths_cases100, aes(x = hospitality_jobs, y = mortality_rate)) + 
    geom_point() + geom_smooth(method = lm, color = "red", fill = "blue") + 
    xlab("Proportion of hospitality jobs") + ylab("Mortality Rate")
print(mortality_rate_hospitality_plot)
ggsave("plots/mortality_rate_hospitality_scatterplot.png", mortality_rate_hospitality_plot, device = "png")

# Plotting logmortality rate as a function of log prop of jobs in hospitality
log_mortality_rate_log_hospitality_plot <- ggplot(df_deaths_cases100, aes(x = log_hospitality, y = log_mortality_rate)) + 
    geom_point() + geom_smooth(method = lm, color = "red", fill = "blue") + 
    xlab("Log of Proportion of hospitality jobs") + ylab("Log of Mortality Rate")
print(log_mortality_rate_log_hospitality_plot)
ggsave("plots/log_mortality_rate_log_hospitality_scatterplot.png", log_mortality_rate_log_hospitality_plot, device = "png")


# Really simplistic linear regression 
m <- lm(mortality_rate ~ age60plus + 
               hospitality_jobs + 
               black_pct + 
               hisp_pct + 
               asian_pct + 
               college + 
               PCTPOVALL_2018 + 
               density + 
               Unemployment_rate_2018 + 
               wfh_share + 
               log_hh_income, data = df_deaths_cases100)
# Basically, the only significant things here are age, hospitality, hispanic, and unemployment
# Surprisingly, income is NOT significant
summary(m)
plot(m)

log_m <- lm(log(mortality_rate) ~ log(age60plus) + 
            log(hospitality_jobs) + 
            log(black_pct) + 
            log(hisp_pct) + 
            log(asian_pct) + 
            log(college) + 
            log(PCTPOVALL_2018) + 
            log(density) + 
            log(Unemployment_rate_2018) + 
            log(wfh_share) + 
            log_hh_income, data = df_deaths_cases100)
summary(log_m)
par(mfrow = c(2,2))
plot(log_m)

# Looking at income relationship, place into buckets of size 0.1, starting at 10.1
bucketed_incomes <- df_deaths_cases100 %>% group_by(gr = cut(log_hh_income, breaks = seq(10.1, 12.0, by = 0.1))) %>% 
    summarise(avg_rate = mean(mortality_rate)) %>%
    mutate(bucket = as.numeric(gr) * 0.1 + 10)

