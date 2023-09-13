library(countrycode)
library(readr)
library(dplyr)

## This script is to clean the Adults dataset before use

adults_raw_test <- read.csv(
  "http://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.test", 
  header = TRUE,
  sep = ",",
  col.names = c("age",
                "workclass",
                "final_weight",
                "education",
                "education_num",
                "marital_status",
                "occupation",
                "relationship",
                "race",
                "sex",
                "capital_gain",
                "capital_loss",
                "hours_per_week",
                "native_country",
                "income_status"),
  skip = 1) %>%
  as_tibble()

adults_raw_validation <- read.csv(
  "http://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data", 
  header = TRUE,
  sep = ",",
  col.names = c("age",
                "workclass",
                "final_weight",
                "education",
                "education_num",
                "marital_status",
                "occupation",
                "relationship",
                "race",
                "sex",
                "capital_gain",
                "capital_loss",
                "hours_per_week",
                "native_country",
                "income_status")) %>%
  as_tibble()

df_raw <- union(adults_raw_test, adults_raw_validation)

adults_train <- adults_raw_test %>%
  mutate(isGT50K = ifelse(income_status == " >50K.", 1, 0)) %>%
  filter(native_country != " ?") %>%
  filter(occupation != " ?") %>%
  filter(workclass != " ?") %>%
  mutate_if(is.character, stringr::str_trim) %>%
  select(-income_status)

adults_validation <- adults_raw_validation %>%
  mutate(isGT50K = ifelse(income_status == " >50K", 1, 0)) %>%
  filter(native_country != " ?") %>%
  filter(occupation != " ?") %>%
  filter(workclass != " ?") %>%
  mutate_if(is.character, stringr::str_trim) %>%
  select(-income_status)

values <- c("Columbia", "England", "Scotland", "Hong", "South", "Yugoslavia")
replacements <- c("Colombia", "United Kingdom", "United Kingdom", "China", "China", "Germany")

adults_train$native_country <- ifelse(adults_train$native_country == "Columbia", "Colombia",  adults_train$native_country)
adults_train$native_country <- ifelse(adults_train$native_country == "England", "United Kingdom",  adults_train$native_country)
adults_train$native_country <- ifelse(adults_train$native_country == "Scotland", "United Kingdom",  adults_train$native_country)
adults_train$native_country <- ifelse(adults_train$native_country == "Hong", "China",  adults_train$native_country)
adults_train$native_country <- ifelse(adults_train$native_country == "South", "China",  adults_train$native_country)
adults_train$native_country <- ifelse(adults_train$native_country == "Yugoslavia", "Germany",  adults_train$native_country)
adults_train$native_country <- countrycode(sourcevar = adults_train$native_country,
                                       origin = "country.name",
                                       destination = "continent")

adults_validation$native_country <- ifelse(adults_validation$native_country == "Columbia", "Colombia",  adults_validation$native_country)
adults_validation$native_country <- ifelse(adults_validation$native_country == "England", "United Kingdom",  adults_validation$native_country)
adults_validation$native_country <- ifelse(adults_validation$native_country == "Scotland", "United Kingdom",  adults_validation$native_country)
adults_validation$native_country <- ifelse(adults_validation$native_country == "Hong", "China",  adults_validation$native_country)
adults_validation$native_country <- ifelse(adults_validation$native_country == "South", "China",  adults_validation$native_country)
adults_validation$native_country <- ifelse(adults_validation$native_country == "Yugoslavia", "Germany",  adults_validation$native_country)
adults_validation$native_country <- countrycode(sourcevar = adults_validation$native_country,
                                            origin = "country.name",
                                            destination = "continent")

adults <- dplyr::union(adults_train, adults_validation)

adults_numeric <- dplyr::union(adults_raw_test, adults_raw_validation) %>%
  mutate(isGT50K = as.numeric(income_status == " >50K")) %>%
  filter(native_country != " ?") %>%
  filter(occupation != " ?") %>%
  filter(workclass != " ?") %>%
  mutate_if(is.character, stringr::str_trim) %>%
  select(-income_status) %>%
  select(age, final_weight, education_num, capital_gain, capital_loss, hours_per_week, isGT50K)

# write_csv(adults_validation, file="adults_validation")
# write_csv(adults_train, file="adults_train")
# write_csv(adults_numeric, file="adults_numeric")
# write_csv(adults, file="adults.csv")
