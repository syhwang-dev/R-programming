# 미국 나스닥 데이터 분석

## 주제: 확정해야 됨.

## 0. 패키지 불러오기
library(tidyverse)  # 데이터 분석용

# 유틸리티 - 데이터를 빠르게 표현해주는 것
library(lubridate)
library(scales)
library(patchwork)
library(corrr)
library(rstatix)
# 위의 라이브러리 중 하나를 사용하니 top bottom 나옴

library(prophet)  # 메타에서 만든 시계열 데이터 예측 기반 / 파이썬용도 있음
library(astsa)
library(forecast)  # 제한 조건이 만든 학자용 통계
# 두 개가 병용 prophet forecast

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

## 2. 시계열 데이터 시각화(EDA)
# 시계열은 시각화를 동반해야 함.

end_labels <- (stocks %>%
                 group_by(company) %>%
                 filter(date == max(date)) %>%
                 arrange(-open) %>%  # 개장가 기준으로
                 select(open, company))[c(1:3, 12:14),]

# 좀 더 해봐여!
# stocks %>%
#   ggplot(aes(date, open)) +
#   geom_line(aes(color = company))

# 좀 더 해봐여!
stocks %>%
  ggplot(aes(date, open)) +
  geom_line(aes(color = company)) +
  scale_y_continuous(sec.axis = sec_axis(~., breaks = end_labels$open,
                                         labels = end_labels$company)) + 
  scale_x_date(expand = c(0, 0)) +
  labs(x = "", y = "Open", color = "", title = "주요 회사의 시작 가격") +
  theme(legend.position = "none")

# top3 & bottom3를 보여줌으로써 극명한 대비를 보여줌. - 전체 데이터의 동향
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
    ggplot(aes(ds, diff)) +
    geom_point(color = "steelblue4", alpha = 0.7) +
    labs(y = "Difference", x = "Date",
         title = "One Day Returns")
) /
(aapl %>%
     mutate(diff = c(NA, diff(y))) %>%
     ggplot(aes(diff)) +
     geom_histogram(bins = 50, fill = "steelblue4", color = "black")
)

# Prophet
# facebook/prophet
m_aapl <- prophet(aapl)
forecast <- predict(m_aapl, 
                    make_future_dataframe(m_aapl, periods = 140))
plot(m_aapl, forecast)
prophet_plot_components(m_aapl, forecast)

# ARIMA
ts_aapl <- ts(aapl$y, start = c(2010, 4), frequency = 365)
aapl_fit <- window(ts_aapl, end = 2018)

auto_arima_fit <- auto.arima(aapl_fit)  # 에러 발생
plot(forecast(auto_arima_fit, h = 365), ylim = c(0,200))
lines(window(ts_aapl, start = 2018), col = "red")

ibm <- stocks %>% 
  filter(name == "IBM") %>% 
  select(ds = date, y = open)

m_ibm <- prophet(ibm)
forecast_ibm <- predict(m_ibm, 
                        make_future_dataframe(m_ibm, periods = 140))
plot(m_ibm, forecast_ibm)
prophet_plot_components(m_ibm, forecast_ibm)

plot(forecast(auto.arima(ibm$y), h = 365), ylim = c(0,250))


## 3. 시계열 데이터 분리

(stock_corr <- stocks %>% 
    widyr::pairwise_cor(company, date, open) %>% 
    filter(item1 > item2) %>% 
    mutate(corrstr = ifelse(abs(correlation > 0.5), "Strong", "Weak"),
           type = ifelse(correlation > 0, "Positive", "Negative")) %>% 
    arrange(-abs(correlation)))

stock_corr %>% 
  ggplot(aes(correlation)) +
  geom_histogram(aes(fill = type), 
                 alpha = 0.7, binwidth = 0.05) +
  xlim(c(-1,1)) +
  labs(title = "Distribution of Correlation Values",
       subtitle = "The majority of companies have a strong positive correlation",
       fill = "Positive Correlation") +
  theme(legend.position = c(0.2,0.8),
        legend.background = element_rect(fill = "white", color = "white"))

(stocks %>% 
    widyr::pairwise_cor(name, date, open) %>% 
    rename(var1 = item1, var2 = item2) %>% 
    cor_spread(value = "correlation") %>% 
    rename(term = rowname))[c(14,1:13),] %>% 
  network_plot() +
  labs(title = "Correlation of Tech Stocks") +
  theme(plot.title = element_text(hjust = 0.5),
        text = element_text(family = "Roboto"))

stocks %>% 
  ggplot(aes(date, open, color = name)) +
  geom_line() +
  gghighlight::gghighlight(name == "IBM", use_direct_label = FALSE) +
  labs(x = "", y = "", color = "",
       title = "IBM is an Outlier Among Tech Stocks")

stocks %>% 
  filter(company %in% 
           c(stock_corr[1:5,]$item1, stock_corr[1:5,]$item2)) %>% 
  ggplot(aes(date, open, color = company)) + 
  geom_line() +
  labs(x = "", y = "Open Price", color = "",
       title = "The 6 Most Correlated Stocks Have Nearly Identical Trends") +
  theme(legend.position = c(0.2,0.75),
        legend.background = element_rect(fill = "white",
                                         color = "white"))

stocks %>% 
  filter(company %in% c(stock_corr[1,1:2])) %>% 
  select(date, company, open) %>% 
  pivot_wider(names_from = company, values_from = open) %>% 
  ggplot(aes(`Adobe Inc.`, `Amazon.com, Inc.`)) +
  geom_point(alpha = 0.7, color = "steelblue2") +
  geom_smooth(method = "lm", se = FALSE, color = "black",
              linetype = "dashed") +
  labs(title = "Amazon and Adobe Trend")

stock_corr %>% 
  filter(str_detect(item1, "Netflix") & str_detect(item2, "Machine"))

stocks %>% 
  filter(str_detect(company, "Netflix|Machine")) %>% 
  ggplot(aes(date, open, color = name)) + 
  geom_line() +
  labs(x = "", y = "Open Price", color = "",
       title = "IBM and Netflix Have Very Different Trends") +
  theme(legend.position = c(0.45,0.8))

stocks %>% 
  filter(str_detect(company, "Netflix|Machine")) %>% 
  select(date, name, open) %>% 
  pivot_wider(names_from = name, values_from = open) %>% 
  ggplot(aes(`IBM`, `NFLX`)) +
  geom_point(alpha = 0.7, color = "steelblue2") +
  geom_smooth(method = "lm", se = FALSE, color = "black",
              linetype = "dashed") +
  labs(title = "IBM and Netflix")

## 4. 종가를 예측