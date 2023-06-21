# tidyverse
library("tidyverse")
library("palmerpenguins")
install.packages("palmerpenguins")  # css 파일 두 개?

## 1. 데이터 확인
glimpse(penguins)

penguins

penguins %>% 
  drop_na()

plot_data <- penguins %>% 
  drop_na()

t(map_df(plot_data, ~sum(is.na(.))))

## 2. 데이터 구성 (이미지 표현, 종)
plot_data %>% 
  group_by(species)

# 묶인 값을 원해!
count_data <- plot_data %>% 
  group_by(species) %>% 
  tally()

count_data

ggplot(count_data) +
  aes(x = species, fill = species, weight = n) +
  geom_bar()
  # 













