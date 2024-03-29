#bolker - pipeline2

library(tidyverse); theme_set(theme_bw())
library(tidymodels)
library(spatialsample)
library(DALEX)
library(DALEXtra)
library(vip)
library(GGally)
## wd: /code
source("../code/utils.R")

do_plots <- interactive()

## https://www.kaggle.com/datasets/camnugent/california-housing-prices
## https://github.com/ageron/handson-ml/tree/master/datasets/housing
## A block group is the smallest geographical unit for which the U.S. Census Bureau publishes sample data (a block group typically has a population of 600 to 3,000 people

housing <- (read_csv("/Users/deanhansen/Grad School/Courses/winter_2023/stat790/assignments_me/stats790/Assignment #4/housing.csv")
            |> group_by(ocean_proximity)
            |> filter(n() >= 10)
            |> ungroup()
            |> mutate(across(ocean_proximity, ~ factor(., levels = c("INLAND", "<1H OCEAN", "NEAR BAY", "NEAR OCEAN"))))
)

summary(housing)

if (do_plots) {
  ## take at least a **brief** look at the data
  pairs(select(housing, where(is.numeric)), gap = 0, pch = ".")
  GGally::ggpairs(housing,
                  lower = list(continuous = wrap("points", alpha = 0.1, size = 0.1),
                               combo = "facethist", discrete = "facetbar", na =  "na"))
  GGally::ggpairs(housing,
                  lower = list(continuous = "hexbin", combo = "facethist", discrete = "facetbar", na =  "na"))
}

ggplot(housing, aes(longitude, latitude)) + geom_point(alpha = 0.5)

data_split <- initial_split(housing, prop = 3/4)
train_data <- training(data_split)
testing_data <- testing(data_split)

b_recipe  <- (
  recipe(median_house_value ~ ., data = train_data)
  |> step_string2factor(all_nominal())
  |> step_dummy(all_nominal(), one_hot = TRUE)
  |> step_center(all_numeric())
  |> step_scale(all_numeric())
  |> step_nzv(all_numeric())
  |> prep()
)

boost_mod <- (
  boost_tree(mode = "regression",
             tree_depth = tune(),
             learn_rate = tune(),
             trees = tune())
  |> set_engine(engine = "xgboost")
)
print(boost_mod)
## Bayesian tuning?

boost_wflow <- (
  workflow()
  |> add_model(boost_mod)
  |> add_recipe(b_recipe)
)

fn <- "/Users/deanhansen/Grad School/Courses/winter_2023/stat790/assignments_me/stats790/Assignment #4/boost_tune_grid_1.rds"
if (file.exists(fn)) {
  tt <- readRDS(fn)
} else {
  system.time(tt <-
                (
                  ## n.b. changing from 'tuning a model' ('object = boost_mod')
                  ##  to 'tuning a workflow ('boost_wflow |>') will change
                  ##  downstream extraction methods
                  tune_grid(
                    object = boost_wflow,
                    grid = 5,
                    resamples = vfold_cv(train_data),
                    metrics   = metric_set(huber_loss),
                    control = control_grid(verbose = TRUE)
                  ))
  )
  saveRDS(tt, fn)
}
cc <- collect_metrics(tt)


show_best(tt)
ss <- select_best(tt)

bm <- finalize_model(boost_mod, select_best(tt))
bm_fit <- fit(bm, median_house_value ~ ., data = train_data)

vip(bm_fit)

explainer_boost <- 
  explain_tidymodels(
    bm_fit, 
    data = train_data,
    y = train_data$median_house_value
  )

set.seed(101)
shap_boost <- predict_parts(explainer = explainer_boost, new_observation =
                              train_data[120,],
                            type = "shap",
                            B = 1)
plot(shap_boost)

vip_boost <- model_parts(explainer_boost)
plot(vip_boost)

plot(vip(bm_fit))

## via fastshap package (fussy)
X <- model.matrix(median_house_value ~ . - 1, train_data)
plot(vip(bm_fit, method = "shap", train = X, pred_wrapper = predict))

pdp_age <- model_profile(explainer_boost, N = 500,
                         variables = "median_income")

plot(pdp_age, geom = "profiles")
