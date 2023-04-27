set.seed(123)
library(randomForest)
library(tidyverse)
library(tidymodels)
library(vip)

##load the data from http://lib.stat.cmu.edu/datasets/
colnames <- c("median_house_value","median_income","housing_median_age","total_rooms","total_bedrooms","population","households","latitude","longitude")
housing <- read_table(file="./cadata.txt",col_names=colnames)

attach(housing)
df_1 <- data.frame(median_house_value, median_income, total_rooms)
df_1$ind <- ifelse(df_1$median_income > 3.870671, 1, 0)
df_1$room <- ifelse(df_1$total_rooms > 2635.763, 1, 0)
df_1 %>% group_by(ind,room) %>% summarise(m = mean(median_house_value))

cube <- function(x, y) {
  if(x > 3.870671 & y > 2635.763) {
    286255
  } 
  else 
    if(x > 3.870671 & y <= 2635.763) {
      273525
    }
  else
    if(x <= 3.870671 & y > 2635.763) {
      168813
    }
  else 
    if(x <= 3.870671 & y <= 2635.763) {
      149080
    }
}

my_simple <- function(p1, p2) {
  
  x <- cbind(sample(housing %>% select(-median_house_value), 2), median_house_value)
  
  z <- x %>% colMeans() %>% as_tibble()
  mean_1 <- z[1,1] %>% as.numeric()
  mean_2 <- z[2,1] %>% as.numeric()
  
  col <- names(x)[1:2]
  
  x$ind_1 <- ifelse(x[1] > mean_1, 1, 0)
  x$ind_2 <- ifelse(x[2] > mean_2, 1, 0)
  
  m <- x %>% 
    group_by(col[1], col[2]) %>% 
    summarise(avg = mean(median_house_value))
  
  if(p1 > mean_1 & p2 > mean_2) {
    m[4,3]
  } 
  else 
    if(p1 > mean_1 & p2 <= mean_2) {
      m[3,3]
    }
  else
    if(p1 <= mean_1 & p2 > mean_2) {
      m[2,3]
    }
  else 
    if(p1 <= mean_1 & p2 <= mean_2) {
      m[1,3]
    }
}