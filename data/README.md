# data/

This directory contains the raw CSV files used for our analysis.
A brief description of each file is presented below:

## Raw Datasets
* `data/kolko_covid_shareable.csv`: CSV file from CCLE containing coronavirus cases/deaths data per US county, as long as other SES data on US counties.
* `data/unemployment_median_income_cleaned.csv`: CSV file from [U.S. Department of Agriculture](https://www.ers.usda.gov/data-products/county-level-data-sets/download-data/) containing median incomes and unemployment rates for US counties from 2010-2018.
* `data/poverty.csv`: CSV file from [U.S. Department of Agriculture](https://www.ers.usda.gov/data-products/county-level-data-sets/download-data/) containing poverty rates for US counties in 2018.


## Merged Datasets
* `data/project_data.csv`: Combination of `data/kolko_covid_shareable.csv` and `data/unemployment_median_income_cleaned.csv` merged on county ID code (column `county` in kolko dataset and column `FIPS` in unemployment dataset). DEPRECATED, don't use!
* `data/cases_income_poverty_data.csv`: Combination of all three raw datasets.
* `data/dataset.csv`: Final dataset used for Milestone One. 
