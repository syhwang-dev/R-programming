library(tidyverse)

data(mpg)
mpg

filter(mpg, manufacturer=="hyundai")
# 사실 단일 객체는 거의 필요 없음.

hyundai_2008 <- filter(mpg, manufacturer=="hyundai", year==2008)
hyundai_2008

slice(hyundai_2008, 1)
arrange(hyundai_2008, model, )


# 파이프라인 함수

