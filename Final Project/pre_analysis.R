##For my project, I will implement the Random Forests algorithm from scratch in R. 
##As part of my writeup, I will perform a series of tests to see how my implementation 
##compares to the popular randomForest package implementation in terms of time, memory usage etc.. 
##Further, I will demonstrate how my implementation compares to randomForest on a regression 
##problem using the California Housing dataset (Section 10.14.1 of ESL).

set.seed(123)
library(rpart)
library(randomForest)
library(tidyverse)
library(tidymodels)
library(vip)

##load the data from http://lib.stat.cmu.edu/datasets/
colnames <- c("median_house_value","median_income","housing_median_age","total_rooms","total_bedrooms","population","households","latitude","longitude")
housing <- read_table(file="./cadata.txt",col_names=colnames)

##perform random forest with tidymodels
splits <- initial_split(housing)
housing_training <- training(splits)
housing_testing  <- testing(splits)

rf_mod <- 
  rand_forest(mtry = tune(), min_n = tune(), trees = tune()) %>% 
  set_engine("ranger") %>% 
  set_mode("regression")

rf_recipe <- 
  recipe(median_house_value ~ ., data = housing_training)

rf_workflow <- 
  workflow() %>% 
  add_model(rf_mod) %>% 
  add_recipe(rf_recipe)

rf_res <- 
  rf_workflow %>% 
  tune_grid(vfold_cv(housing_testing),
            grid = 10,
            control = control_grid(save_pred = TRUE),
            metrics = metric_set(rmse, rsq, ccc))
