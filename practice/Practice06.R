# 미국 나스닥 데이터 분석

## 주제: 확정해야 됨.

## 0. 패키지 불러오기
library(tidyverse)
library(lubridate)
library(scales)
library(patchwork)
library(corrr)
library(rstatix)
# 위의 라이브러리 중 하나를 사용하니 top bottom 나옴
library(prophet)
library(astsa)
library(forecast)
library(sysfonts)
library(showtext)

## 1. 데이터 프레임 작성
# 파일 목록을 다 들고 와야 됨.
files <- list.files(path = "data/nasdaq_stock/")

# 들고온 파일 목록을 다 읽어서, 데이터 프레임
# for i ...? # 일반적인 데이터분석은 for문을 선호하지 않음. / 메모리 터질 가능성이 있음.
stocks <- read_csv(paste0("data/nasdaq_stock/", files), id = "name") %>%
  mutate(name = gsub("data/nasdaq_stock/", "", name),
         name = gsub("\\.csv", "", name)) %>%
  rename_with(tolower)

# 데이터 프레임을 결합
df <- read_csv("data/nasdaq_stock_names.csv")

stocks <-
  stocks %>%
  inner_join(df, by = c("name" = "stock_symbol"))

stocks

(stocks %>%
  group_by(company) %>%
  filter(date == max(date)) %>%
  arrange(-open) %>%  # 개장가 기준으로
  select(open, company))[c(1:3, 12:14),]

# 전체 데이터 보기
stocks %>%
    group_by(company) %>%
    filter(date == max(date)) %>%
    arrange(-open) %>%  # 개장가 기준으로
    select(open, company)

end_labels <- (stocks %>%
  group_by(company) %>%
  filter(date == max(date)) %>%
  arrange(-open) %>%  # 개장가 기준으로
  select(open, company))
# 142는 페이스북

## 2. 시계열 데이터 시각화

end_labels <- (stocks %>%
                 group_by(company) %>%
                 filter(date == max(date)) %>%
                 arrange(-open) %>%  # 개장가 기준으로
                 select(open, company))[c(1:3, 12:14),]

# 좀 더 해봐여!
stocks %>%
  ggplot(aes(date, open)) +
  geom_line(aes(color = company))

# 좀 더 해봐여!
stocks %>%
  ggplot(aes(date, open)) +
  geom_line(aes(color = company)) +
  scale_y_continuous(sec.axis = sec_axis(~., breaks = end_labels$open,
                                         labels = end_labels$company)) + 
  scale_x_date(expand = c(0, 0)) +
  labs(x = "", y = "Open", color = "", title = "주요 회사의 시작 가격") +
  theme(legend.position = "none")

# top3 & bottom3를 보여줌으로써 극명한 대비를 보여줌.
(stocks %>%
    filter(company %in% end_labels$company[1:3]) %>%
    ggplot(aes(date, open)) +
    geom_line(aes(color = company)) +
    facet_wrap(~company) +
    theme_bw() +
    theme(legend.position = "none") +
    labs(title = "Top 3", x = "")) /
(stocks %>%
   filter(company %in% end_labels$company[-(1:3)]) %>%
   ggplot(aes(date, open)) +
   geom_line(aes(color = company)) +
   facet_wrap(~company) +
   theme_bw() +
   theme(legend.position = "none") +
   labs(title = "Bottom 3", x = ""))

# 시계열
# Apple 정보 보기
# 시계열의 단점: x가 고정
aapl <- stocks %>%
  filter(name == "AAPL") %>%
  select(ds = date, y = open)

(aapl %>%
    mutate(diff = c(NA, diff(y))) %>%
    ggplot(aes(diff)) +
    geom_point(color = "steelblue4", alpha = 0.7) +
    labs(y = "Difference", x = "Date",
         title = "One Day Returns")
) /
(aapl %>%
     mutate(diff = c(NA, diff(y))) %>%
     ggplot(aes(diff)) +
     geom_histogram(bins = 50, fill = "steelblue4", color = "black")
)



## 3. 시계열 데이터 분리

## 4. 종가를 예측