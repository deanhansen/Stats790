library(readr)
library(dplyr)

## This script is to clean the California housing dataset before use
## Data is sourced from http://lib.stat.cmu.edu/datasets/

colnames <- c("median_house_value","median_income","housing_median_age","total_rooms","total_bedrooms","population","households","latitude","longitude")
housing <- read_table(file="./cleaned_cadata.txt",col_names=colnames)

write_csv(housing, file="housing.csv")
