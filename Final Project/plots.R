library(ggplot2)
library(GGally)
library(readr)
library(dplyr)

# get data
r_regression_times <- read_csv("./metrics/r_regression_times.csv")
r_classification_times <- read_csv("./metrics/r_classification_times.csv")
python_regression_times <- read_csv("./metrics/python_regression_times.csv") %>% select(-1)
python_classification_times <- read_csv("./metrics/python_classification_times.csv") %>% select(-1)
r <- union(cbind(r_regression_times, type="Regression"), cbind(r_classification_times, type="Classification")) %>% mutate(lang="R")
python <- union(cbind(python_regression_times, type="Regression"), cbind(python_classification_times, type="Classification")) %>% mutate(lang="Python")

# plot
df_p1_p2 <- union(r, python)
df_p1_p2$size <- df_p1_p2$size/1024/1024

p1 <- ggplot(df_p1_p2, aes(x=type, y=times, color=lang)) +
  geom_boxplot() +
  labs(x="", y="Time in Seconds",  color="Language") +
  scale_y_continuous(breaks=seq(0,30,5), limits=c(0,30)) +
  theme(text = element_text(size = 18)) +
  facet_wrap(~lang)
p1
ggsave(filename="time_comparison.png", plot=p1, path="./pictures/")

# plot
p2 <- ggplot(df_p1_p2, aes(x=type, y=size, color=lang)) +
  geom_boxplot() +
  scale_y_continuous(breaks=seq(60,180,10), limits=c(60,180)) +
  labs(x="", y="Size in Mb", color="Language") +
  theme(text = element_text(size = 18)) +
  facet_wrap(~lang)
p2
ggsave(filename="size_comparison.png", plot=p2, path="./pictures/")

# plot
df_p3 <- adults %>% select(where(is.numeric)) %>% select(-isGT50K) %>% scale() %>% as_tibble()
p3 <- GGally::ggpairs(df_p3, aes(alpha=0.5))
ggsave(filename="adults_pairs.png", plot=p3, path="./pictures/")

# plot
df_p4 <- housing %>% select(where(is.numeric)) %>% scale() %>% as_tibble() %>% rename(median_value=median_house_value, median_age=housing_median_age)
p4 <- GGally::ggpairs(df_p4, aes(alpha=0.5))
p4
ggsave(filename="housing_pairs.png", plot=p4, path="./pictures/")
