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

# using R defaults
rf_regression <- randomForest(median_house_value ~ ., data=housing_training)
rf_pred <- predict(rf_regression, newdata=housing_testing)
rmse <- sqrt(sum((rf_pred - housing_testing$median_house_value)^2)/length(rf_pred))
paste("RMSE:", rmse) # RMSE: 50719.3875768653
plot(rf_regression)

# using default parameters of scikit learn
rf_regression_default <- randomForest(median_house_value ~ ., data=housing_training, ntrees=100)
rf_pred_default <- predict(rf_regression_default, newdata=housing_testing)
rmse_default <- sqrt(sum((rf_pred_default - housing_testing$median_house_value)^2)/length(rf_pred_default))
paste("RMSE:", rmse_default) # RMSE: 50974.7547537137
plot(rf_regression_default)

# using hypertuned parameters from Python
rf_regression_opt <- randomForest(median_house_value ~ ., data=housing_training, ntrees=500, mtry=5, nodesize=10)
rf_pred_opt <- predict(rf_regression_opt, newdata=housing_testing)
rmse_default <- sqrt(sum((rf_pred_opt - housing_testing$median_house_value)^2)/length(rf_pred_opt))
paste("RMSE:", rmse_default) # RMSE: 48336.0260963631
plot(rf_regression_opt)

# regression timings for randomForest
times_regression <- vector(mode="double", length=25L)
size_regression <- vector(mode="double", length=25L)
for (i in 1:25) {
  start_regression <- Sys.time()
  t <- randomForest(median_house_value ~ ., data=housing_training, ntrees=100)
  end_regression <- Sys.time()
  times_regression[i] <- end_regression - start_regression
  size_regression[i] <- lobstr::obj_size(t)
  rm(t)
}

r_regression_times <- tibble(times=times_regression, size=size_regression)
write_csv(r_regression_times, "./metrics/r_regression_times.csv")

# get model to explain specific example from validation set
python_explainer_regression <- explain_scikitlearn("python_regression.pkl",
                                                   data=housing_training[-1],
                                                   y=housing_training$median_house_value)

r_explainer_regression <- explain_tidymodels(rf_regression_opt,
                                             data=housing_training[-1],
                                             y=housing_training$median_house_value)

python_shap_boost <- predict_parts(explainer=python_explainer_regression,
                                   new_observation=housing_testing[1,-1],
                                   type="shap",
                                   B=50)

r_shap_boost <- predict_parts(explainer=r_explainer_regression,
                              new_observation=housing_testing[1,-1],
                              type="shap",
                              B=50)

# variable importance plots
python_vip_boost <- model_parts(python_explainer_regression)
r_vip_boost <- model_parts(r_explainer_regression)
plot(r_vip_boost, python_vip_boost) +
  ggtitle("Mean variable-importance over 50 permutations", "") +
  theme(text = element_text(size = 18))

########################################################################################

# Using tidymodels
# rf_recipe <- 
#   recipe(median_house_value ~ ., data = housing_training)
# 
# rf_mod <- 
#   rand_forest(mtry = tune(), min_n = tune(), trees = tune()) %>% 
#   set_engine("randomForest") %>% 
#   set_mode("regression")
# 
# rf_workflow <- 
#   workflow() %>% 
#   add_model(rf_mod) %>% 
#   add_recipe(rf_recipe)
# 
# rf_folds <- vfold_cv(housing_training)
# rf_grid <- expand.grid(mtry = c(3,4,5), min_n = c(10,20,30), trees = c(100, 250, 500))
# 
# fn <- "./rf_workflow_regression.rds"
# if (file.exists(fn)) {
#   tt <- readRDS(fn)
# } else {
#   system.time(rf_res <-
#                 (tune_grid(
#                     object = rf_workflow,
#                     grid = rf_grid,
#                     resamples = rf_folds,
#                     metrics   = metric_set(rmse),
#                     control = control_grid(verbose = TRUE, save_pred = TRUE))
#                  )
#               )
#   saveRDS(tt, fn)
# }
# cm <- collect_metrics(rf_res)
# cp <- collect_predictions(rf_res)
# 
# best_rmse <- select_best(rf_res, "rmse")
# final_rf <- finalize_model(rf_mod, best_rmse)
# 
# write to a csv file
# write_csv(cm, file="./rf_res_regression_cm.csv")