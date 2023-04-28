set.seed(1) ## reproducibility
library(randomForest)
library(tidyverse)
library(tidymodels)
library(vip)
library(DALEXtra)

# housing <- read_csv(file="./data/housing.csv")
# housing_splits <- initial_split(housing)
# housing_training <- training(housing_splits)
# housing_testing  <- testing(housing_splits)

housing_training <- read_csv(file="./data/housing_training.csv")
housing_testing  <- read_csv(file="./data/housing_testing.csv")

# Using default parameters (same as scikit learn)
rf_fit_regression <- randomForest(median_house_value ~ ., data=housing_training, ntrees=100)
rf_pred <- predict(rf_fit_regression, newdata=housing_testing)
rmse <- sqrt(sum((rf_pred - housing_testing$median_house_value)^2)/length(rf_pred))
paste("RMSE:", rmse) # RMSE: 50829.6852708863
plot(rf_fit_regression)
which.min(rf_fit_regression$mse) # 351

# Using tidymodels
rf_recipe <- 
  recipe(median_house_value ~ ., data = housing_training)

rf_mod <- 
  rand_forest(mtry = tune(), min_n = tune(), trees = tune()) %>% 
  set_engine("randomForest") %>% 
  set_mode("regression")

rf_workflow <- 
  workflow() %>% 
  add_model(rf_mod) %>% 
  add_recipe(rf_recipe)

rf_folds <- vfold_cv(housing_training)
rf_grid <- expand.grid(mtry = c(3,4,5), min_n = c(10,20,30), trees = c(100, 250, 500))

fn <- "./rf_workflow_regression.rds"
if (file.exists(fn)) {
  tt <- readRDS(fn)
} else {
  system.time(rf_res <-
                (tune_grid(
                    object = rf_workflow,
                    grid = rf_grid,
                    resamples = rf_folds,
                    metrics   = metric_set(rmse),
                    control = control_grid(verbose = TRUE, save_pred = TRUE))
                 )
              )
  saveRDS(tt, fn)
}
cm <- collect_metrics(rf_res)
cp <- collect_predictions(rf_res)

best_rmse <- select_best(rf_res, "rmse")
final_rf <- finalize_model(rf_mod, best_rmse)

## write to a csv file
## write_csv(cm, file="./rf_res_regression_cm.csv")

final_rf_fit <- fit(final_rf, median_house_value ~ ., data=housing_training)

## variable importance plot
vip(final_rf_fit)

explainer_rf_fit <- 
  explain_tidymodels(
    final_rf_fit, 
    data=housing_training,
    y=housing_training$median_house_value
  )

set.seed(101)
shap_boost <- predict_parts(explainer=explainer_rf_fit, 
                            new_observation=housing_testing,
                            type="shap",
                            B=1)
plot(shap_boost)

vip_boost <- model_parts(explainer_rf_fit)
plot(vip_boost)
