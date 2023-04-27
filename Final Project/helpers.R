## create a bootstrap sample
bootstrap_tree <- function(data) {
  boot_index <- sample(x=nrow(data), size=nrow(data), replace=TRUE) 
  boot_data <- housing[boot_index,]
  oob_data <- housing[-boot_index,]
  return(list("boot_index"=boot_index, "boot_data"=boot_data, "oob_data"=oob_data))
}

## grow a single tree using bootstrapped data
grow_tree <- function(formula, data, mtry) {
  
  # get the target variable
  target_name <- all.vars(formula)[1]
  
  boot_df$boot_data[, !names(boot_df$boot_data) %in% target_name]
  
  # create bootstrap sample then get subset of names
  boot_data <- bootstrap_tree(data)$boot_data
  boot_names <- names(boot_data[, !names(boot_data) %in% target_name])
  sample_names <- sample(x=boot_names, size=mtry, replace=FALSE)
  
  # create new formula with subset of features
  formula_new <- as.formula(paste0(target_name, " ~ ", paste0(sample_names, collapse=" + ")))
  
  # fit a regression tree with subset of features - minsplit is 5 to match randomForest settings
  boot_tree <- rpart(formula=formula_new, data=boot_df$boot_data, control=c(minsplit=5L))
  
  return(list("tree"=boot_tree, "data"=boot_df, "names"=sample_names))
}


## get oob error
oob_error <- function(boot_tree, data) {
  oobpredict(boot_tree, boot_df$oob_data)
}

## get the SSE for each variable

## choose variable with smallest value

## split the data using the feature name and split value

## remove the column used to split from name variable


# y <- housing$median_house_value
# var_y <- var(y) * (length(y)-1)
# split_points <- sort(unique(housing$population))
# 
# unique_sort <- function(x){
#   lapply(lapply(x, unique), sort)
# }
# 
# split_points <- unique_sort(housing)
# len <- lapply(split_points, length)
# x <- data.frame(variable=NULL, split=NULL, s=NULL)
# 
# sum(housing[housing$median_income <= split_points[i],]$median_house_value - mean(housing[housing$median_income <= split_points[i],]$median_house_value))^2 + sum(housing[housing$median_income < split_points[i],]$median_house_value - mean(housing[housing$median_income < split_points[i],]$median_house_value))^2
# 
# t <- data.frame(split_points, s)
# t[which.min(t),]


