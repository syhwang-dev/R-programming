library(tidyverse)
library(reshape2)

# 1. 데이터 불러오기
housing = read_csv("data/housing.csv")
housing
## 앞/뒤를 확인해서 해당 데이터 확인
head(housing)
tail(housing)
summary(housing) # pandas > df_info

## 데이터 전체 구조를 확인
str(housing)


hist(housing$longitude)  # 그려는 지지만 10개 넘게 그려야 함.

plot_histo <- ggplot(data = melt(housing), mapping = aes(x = value)) +
  geom_histogram(bins = 30) +
  facet_wrap(~variable, scales = 'free_x')
plot_histo

ggplot(data = housing, mapping = aes(x = longitude, y = latitude,
                                     color = median_house_value)) +
  geom_point(aes(size = population), alpha=0.4)


# 2. 전처리

## 이상치 처리 / 데이터 결측치
bedroom_mean <- mean(housing$total_bedrooms, na.rm = T)
bedroom_median <- median(housing$total_bedrooms, na.rm = T)
bedroom_median
bedroom_mean

ggplot(data = housing, mapping = aes(x = total_bedrooms)) +
  geom_histogram(bins = 30, color="black", fill = "blue") +
  geom_vline(aes(xintercept = bedroom_mean, color = "red"), lwd = 1.5) + 
  geom_vline(aes(xintercept = bedroom_median, color = "yellow"), lwd = 1.5)


bedroom_median <- median(housing$total_bedrooms, na.rm = T)

housing$total_bedrooms[is.na(housing$total_bedrooms)] <- median(housing$total_bedrooms, na.rm = T)
housing$total_bedrooms



housing$mean_bedrooms <- housing$total_bedrooms / housing$households
housing$mean_rooms <- housing$total_rooms / housing$households
housing$mean_rooms

head(housing)

drops <- c('total_bedrooms', 'total_rooms') 
housing <- housing[,!(names(housing) %in% drops)] 
housing

## 범주형
categories <- unique(housing$ocean_proximity)
cat_housing <- data.frame(ocean_proximity = housing$ocean_proximity)
head(cat_housing)

## (전체 데이터에서의) 결측치 처리


# 3. 머신러닝

# 4. 결과 확인