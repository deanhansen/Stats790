set.seed(1) ## reproducibility
library(randomForest)
library(tidyverse)
library(tidymodels)
library(vip)
library(DALEXtra)
library(stringi)
library(lobstr)

# adults <- read_csv(file="./data/adults.csv")
# adults$isGT50K <- factor(adults$isGT50K)
# adults_splits <- initial_split(adults)
# adults_training <- training(adults_splits)
# adults_testing  <- testing(adults_splits)

adults_training <- read_csv(file="./data/adults_training.csv")
adults_testing  <- read_csv(file="./data/adults_testing.csv")
adults_training$isGT50K <- factor(adults_training$isGT50K)
adults_testing$isGT50K <- factor(adults_testing$isGT50K)

# using R defaults
rf_classification <- randomForest(isGT50K ~ ., data=adults_training)
rf_pred <- predict(rf_classification, newdata=adults_testing)
accuracy <- sum(rf_pred == adults_testing$isGT50K)/length(rf_pred)
paste("Accuracy:", accuracy) # Accuracy: 0.865668998494643
plot(rf_classification)

# using default parameters of scikit learn
rf_classification_default <- randomForest(isGT50K ~ ., data=adults_training, ntrees=100)
rf_pred_default <- predict(rf_classification_default, newdata=adults_testing)
accuracy_default <- sum(rf_pred_default == adults_testing$isGT50K)/length(rf_pred_default)
paste("Accuracy:", accuracy_default) # Accuracy: 0.864606393341008
plot(rf_classification_default)

# using hypertuned parameters from Python
rf_classification_opt <- randomForest(isGT50K ~ ., data=adults_training, ntrees=200, mtry=5)
rf_pred_opt <- predict(rf_classification_opt, newdata=adults_testing)
accuracy_opt <- sum(rf_pred_opt == adults_testing$isGT50K)/length(rf_pred_opt)
paste("Accuracy:", accuracy_opt) # Accuracy: 0.863366687328434
plot(rf_classification_opt)

# classification timings for randomForest
times_classification <- vector(mode="double", length=25L)
size_classification <- vector(mode="double", length=25L)
for (i in 1:25) {
  start_classification <- Sys.time()
  t <- randomForest(isGT50K ~ ., data=adults_training, ntrees=100)
  end_classification <- Sys.time()
  times_classification[i] <- end_classification - start_classification
  size_classification[i] <- lobstr::obj_size(t)
  rm(t)
}

r_classification_times <- tibble(times=times_classification, size=size_classification)
write_csv(r_classification_times, "./metrics/r_classification_times.csv")

# get model to explain specific example from validation set
adults_training_dummies <- read_csv("./data/adults_training_dummies.csv") %>% select(-"...1")
adults_testing_dummies <- read_csv("./data/adults_testing_dummies.csv") %>% select(-"...1")
python_explainer_rf_fit <- explain_scikitlearn("python_classification.pkl",
                                               data=adults_training_dummies,
                                               y=ifelse(adults_training$isGT50K=="1",1,0))

r_explainer_rf_fit <- explain_tidymodels(rf_fit_classification, 
                                         data=select(adults_training, -isGT50K),
                                         y=ifelse(adults_training$isGT50K=="1",1,0))

python_shap_boost <- predict_parts(explainer=python_explainer_rf_fit,
                                   new_observation=adults_testing_dummies[1,],
                                   type="shap",
                                   B=10)

r_shap_boost <- predict_parts(explainer=r_explainer_rf_fit,
                              new_observation=select(adults_testing, -isGT50K)[1,],
                              type="shap",
                              B=10)
plot(python_shap_boost)
plot(r_shap_boost)

# variable importance plots
python_vip_boost <- model_parts(python_explainer_rf_fit)
plot(python_vip_boost)

r_vip_boost <- model_parts(r_explainer_rf_fit)
plot(r_vip_boost)

################################################################################

# Using tidy models
# rf_recipe <- 
#   recipe(isGT50K ~ ., data = adults_training)
# 
# rf_mod <- 
#   rand_forest(mtry = tune(), min_n = tune(), trees = tune()) %>% 
#   set_engine("randomForest") %>% 
#   set_mode("classification")
# 
# rf_workflow <- 
#   workflow() %>% 
#   add_model(rf_mod) %>% 
#   add_recipe(rf_recipe)
# 
# rf_folds <- vfold_cv(adults_training)
# rf_grid <- expand.grid(mtry = c(3,4,5), min_n = c(10,20,30), trees = c(100, 250, 500))
# 
# fn <- "./rf_workflow_classification.rds"
# if (file.exists(fn)) {
#   tt <- readRDS(fn)
# } else {
#   system.time(rf_res <-
#                 (tune_grid(
#                   object = rf_workflow,
#                   grid = rf_grid,
#                   resamples = rf_folds,
#                   metrics   = metric_set(accuracy, roc_auc),
#                   control = control_grid(verbose = TRUE, save_pred = TRUE))
#                 )
#   )
#   saveRDS(rf_res, fn)
# }
# 
# cm <- collect_metrics(rf_res)
# cp <- collect_predictions(rf_res)
# 
# best_accuracy <- select_best(rf_res, "accuracy")
# best_roc_auc <- select_best(rf_res, "roc_auc")
# final_rf_accuracy <- finalize_model(rf_mod, best_accuracy)
# final_rf_roc_auc <- finalize_model(rf_mod, best_roc_auc)
# 
# write to a csv file
# write_csv(cm, file="./metrics/rf_res_classification_cm.csv")
# write_csv(cp, file="./metrics/rf_res_classification_cp.csv")