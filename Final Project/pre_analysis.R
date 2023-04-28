## As part of my writeup, I will perform a series of tests to see how the R and Python implementations
## compare using the randomForest package and scikit-learn package. 
## Further, I will demonstrate these implementations compare on a regression 
## problem using the California Housing dataset (Section 10.14.1 of ESL) and
## a classification problem using the Adults dataset (UCI Machine Learning Repo).

set.seed(123)
library(rpart)
library(randomForest)
library(tidyverse)
library(tidymodels)
library(vip)

## load California housing data from cleaned version
housing <- read_csv(file="./housing.csv")

## load Adults data from cleaned version
adults <- read_csv(file="./adults.csv") 

##perform random forest with tidymodels
housing_splits <- initial_split(housing)
housing_training <- training(housing_splits)
housing_testing  <- testing(housing_splits)

rf_recipe <- 
  recipe(median_house_value ~ ., data = housing_training)

rf_mod <- 
  rand_forest(mtry = tune(), trees = tune()) %>% 
  set_engine("ranger") %>% 
  set_mode("regression")

rf_workflow <- 
  workflow() %>% 
  add_model(rf_mod) %>% 
  add_recipe(rf_recipe)

rf_folds <- vfold_cv(housing_training)

rf_res <- 
  rf_workflow %>% 
  tune_grid(grid = 5,
            control = control_grid(save_pred = TRUE),
            metrics = metric_set(rmse, rsq, ccc),
            resamples = rf_folds)

best_rf_res <- select_best(rf_res, "rmse")

best_rf_res