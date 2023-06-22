### 0. 버전 확인
# R version 4.3.0 에서 진행
version


# 실습: Oracle 데이터베이스에 연결하기 위한 패키지 설치 
# 단계 1: 데이터베이스 연결을 위한 패키지 설치 
install.packages("rJava")

install.packages("DBI")
install.packages("RJDBC")

# 단계 2: 데이터베이스 연결을 위한 패키지 로딩
library(DBI)
Sys.setenv(JAVA_HOME = "C:\\Program Files(x86)\\Java\\jre1.8.0_311")
library(rJava)
library(RJDBC)


# 실습: 드라이버 로딩과 데이터베이스 연동
# 단계 1: Drive 설정
drv <- JDBC("oracle.jdbc.driver.OracleDriver",
            "c:\\app\\vvbhh\\product\\21c\\dbhomeXE\\jdbc\\lib\\ojdbc8.jar")

# 단계 2: 오라클 데이터베이스 연결
conn <- dbConnect(drv,
                  "jdbc:oracle:thin:@//127.0.0.1:1521/xe", "c##scott", "tiger")


# 실습: 데이터베이스로부터 레코드 검색, 추가, 수정, 삭제하기 
# 단계 1: 모든 레코드 검색
query = "SELECT * FROM test_table"
dbGetQuery(conn, query)

# 단계 2: 정렬 조회 - 나이 칼럼을 기준으로 내림차순 정렬
query = "SELECT * FROM test_table order by age desc"
dbGetQuery(conn, query)

# 단계 3: 레코드 삽입(insert)
qeuery = "insert into test_table values('kang', '1234', '강감찬', 45)"
dbSendUpdate(conn, query)

# 단계 4: 조건 검색 - 나이가 40세 이상인 레코드 조회 
query = "select * from test_table where age >= 40"
result <- dbGetQuery(conn, query)
result

# 단계 5: 레코드 수정 - name이 '강감찬'인 데이터의 age를 40으로 수정
query = "update test_table set age = 40 where name = '강감찬'"
dbSendUpdate(conn, query)
# 수정된 레코드 조회
query = "select * from test_table where name = '강감찬'"
dbGetQuery(conn, query)

# 단계 6: 레코드 삭제 - name이 '홍길동'인 레코드 삭제
query = "delete from test_table where name = '홍길동'"
dbSendUpdate(conn, query)

# 전체 레코드 조회 
query = "select * from test_table"
dbGetQuery(conn, query)



# 실습: MariaDB 드라이벼 로딩과 데이터베이스 연동
# 단계 1: Driver 설정
drv <- JDBC(driverClass = "com.mysql.cj.jdbc.Driver", 
            "C:\\Program Files (x86)\\MySQL\\Connector J 8.0\\mysql-connector-java-8.0.19.jar")

# 단계 2: MariaDB 데이터베이스 연결
conn <- dbConnect(drv, "jdbc:mysql://127.0.0.1:3306/work", "scott", "tiger")


# 실습: 데이터베이스롷부터 레코드 검색, 추가, 수정, 삭제하기 
# 단계 1: 모든 레코드 조회
query = "select * from goods"
goodsAll <- dbGetQuery(conn, query)
goodsAll

# 단계 2: 조건 검색 - 수량(su)이 3이상인 데이터 
query = "select * from goods where su >= 3"
goodsOne <- dbGetQuery(conn, query)
goodsOne

# 단계 3: 정렬 ㄱ머색 - 단가(dan)를 내림차순으로 정렬
query = "select * from goods order by dan desc"
dbGetQuery(conn, query)


# 실습: 데이터프레임 자료를 테이블에 저장하기 
# 단계 1: 데이터프레임 자료를 테이블에 저장
insert.df <- data.frame(code = 6, name = '식기세척기', su = 1, dan = 250000)
dbWriteTable(conn, "goods1", insert.df)

# 단계 2: 테이블 조회
query = "select * from goods1"
goodsAll <- dbGetQuery(conn, query)
goodsAll


# 실습: csv 파일의 자료를 테이블에 저장하기 
# 단계 1: 파일 자료를 테이블에 저장하기 
recode <- read.csv("C:/Rwork/Part-II/recode.csv")
dbWriteTable(conn, "goods", recode)
dbWriteTable(conn, "goods2", recode)

# 단계 2: 테이블 조회
query = "select * from goods2"
goodsAll <- dbGetQuery(conn, query)
goodsAll



# 실습: 테이블에 자료 추가, 수정, 삭제하기 
# 단계 1: 테이블에 레코드 추가하기
query = "insert into goods2 values (6, 'test', 1, 10000)"

dbSendUpdate(conn, query)
query = "select * from goods2"
goodsAll <- dbGetQuery(conn, query)
goodsAll

# 단계 2: 테이블의 레코드 수정
query = "update goods2 set name = '테스트' where code = 6"
dbSendUpdate(conn, query)
query = "select * from goods2"
goodsAll <- dbGetQuery(conn, query)
goodsAll

# 단계 3: 테이블의 레코드 삭제
delquery = "delete from goods2 where code = 6"
dbSendUpdate(conn, delquery)
query = "select * from goods2"
goodsAll <- dbGetQuery(conn, query)
goodsAll


# 실습: MariaDB 연결 종료
dbDisconnect(conn)


## 9장 비정형 텍스트 분석을 위한 koNLP 설치
# 교재 301-303 내용대로 설치가 안됨
# R 설치하기(가급적 관리자 권한으로 설치)
# cran.r-project.org/bin/windows/base/R4.3.0
# cran.rstudio.com/bin/windows/contrib/3.4/KoNLP_0.80.1.zip 이 더 이상 동작하지 않음 contrib/3.4가 없어짐
# R version 4.3.0 에서 진행
version # R의 버젼이 4.3.0이 나오는 것을 확인 

### 0. 패키지 설치 및 라이브러리 사용
install.packages("multilinguer")
install.packages("vctrs")
library(multilinguer)

# 3. java, rJava 설치하기
install.packages("multilinguer")
library(multilinguer)

#1 JDK 설치
install_jdk()

#2 윈도우 재시작 > R 재시작
# 3. 의존성 패키지 설치하기
install.packages(c("hash", "tau", "Sejong", "RSQLite", "devtools", "bit", "rex", "lazyeval", "htmlwidgets", "crosstalk", "promises", "later", "sessioninfo", "xopen", "bit64", "blob", "DBI", "memoise", "plogr", "covr", "DT", "rcmdcheck", "rversions"), type = "binary")

# 4. remotes 패키지 설치하기
install.packages("remotes")

# 5. KoNLP 설치하기(64bit에서만 동작)
remotes::install_github('haven-jeon/KoNLP', upgrade = "never", INSTALL_opts=c("--no-multiarch"))

#6 jar 파일 복사
# scala-library-2.11.8.jar 파일을 구글 검색 후 다운로드: 
## https://jar-download.com/artifacts/org.scala-lang/scala-library/2.11.8/source-code 에서 Download scala-library(2.11.8)을 다운로드받아 압축 풀다
# C:\Users\[유저이름]\AppData\Local\R\win-library\4.3\KoNLP\java 위치에 복사
## 탐색기에서 유저이름 다음에 AppData 폴더가 숨김으로 보이지 않을 수 있음 > R에서  .libPaths()을 실행하면 R 설치 경로가 보임
### 탐색기에서 보기> 우측 숨긴항목 체크박스를 클릭하면 AppData 폴더가 나타남

#7 KoNLP 라이브러리 불러오기
library(KoNLP)

#8 테스트
extractNoun('부산대학교 인공지능 활용 빅데이터 분석 웹서비스 개발자 과정입니다.')
# 정상 실행 됨




# 실습: 형태소 분석을 위한 KoNLP 패키지 설치 
## 208 라인에서 KoNLP 설치가 되어 불필요 - 3.4버젼이 없어짐 
#install.packages("https://cran.rstudio.com/bin/windows/contrib/3.4/KoNLP_0.80.1.zip",repos = NULL)

# 실습: 한글 사전과 텍스트 마이닝 관련 패키지 설치
install.packages("Sejong")
install.packages("wordcloud")
install.packages("tm")


# 실습: 패키지 로딩
#library(KoNLP) ## 이미 실행으로 불필요
## 다음 패키지는 202라인의 의존성 패키지에서 이미 설치되어 다음 설치는 불필요 
#install.packages("hash")
#install.packages("tau")
#install.packages("devtools")
#install.packages("RSQLite")

library(KoNLP)
library(tm)
library(wordcloud)



# 실습: 텍스트 자료 가져오기 
facebook <- file("C:/Rwork/Part-II/facebook_bigdata.txt", 
                 encoding = "UTF-8")
facebook_data <- readLines(facebook)
head(facebook_data)


# 실습: 세종 사전에 단어 추가하기 
user_dic <- data.frame(term = c("R 프로그래밍", "페이스북", "김진성", "소셜네트워크"),
                       tag = 'ncn')

buildDictionary(ext_dic = "sejong", user_dic = user_dic)


# 실습: R 제공 함수로 단어 추출하기  
paste(extractNoun('김진성은 많은 사람과 소통을 위해서 소셜네트워크에 가입하였습니다.'),
      collapse = " ")



# 실습: 단어 추출을 위한 사용자 함수 정의하기 
# 단계 1: 사용자 정의 함수 작성
exNouns <- function(x) { paste(extractNoun(as.character(x)), collapse = " ") }


# 단계 2: exNouns() 함수를 이용하여 단어 추출 
facebook_nouns <- sapply(facebook_data, exNouns)
facebook_nouns[1]


# 실습: 추출된 단어를 대상으로 전처리하기 
# 단계 1: 추출된 단어를 이용하여 말뭉치(Corpus) 생성
myCorpus <-Corpus(VectorSource(facebook_nouns))
myCorpus

# 단계 2: 데이터 전처리 
# 단계 2-1: 문장부호 제거 
myCorpusPrepro <- tm_map(myCorpus, removePunctuation)
# 단계 2-2: 수치 제거 
myCorpusPrepro <- tm_map(myCorpusPrepro, removeNumbers)
# 단계 2-3: 소문자 변경
myCorpusPrepro <- tm_map(myCorpusPrepro, tolower)
# 단계 2-4: 불용어 제거 
myCorpusPrepro <- tm_map(myCorpusPrepro, removeWords, stopwords('english'))
# 단계 2-5: 전처리 결과 확인
inspect(myCorpusPrepro[1:5])



# 실습: 단어 선별(2 ~ 8 음절 사이 단어 선택)하기 
# 단계 1: 전처리된 단어집에서 2 ~ 8 음절 단어 대상 선정
myCorpusPrepro_term <-
  TermDocumentMatrix(myCorpusPrepro, 
                     control = list(wordLengths = c(4, 16)))
myCorpusPrepro_term

# 단계 2: matrix 자료구조를 data.frame 자료구조로 변경
myTerm_df <- as.data.frame(as.matrix(myCorpusPrepro_term))
dim(myTerm_df)


# 실습: 단어 출현 빈도수 구하기 
wordResult <- sort(rowSums(myTerm_df), decreasing = TRUE)
wordResult[1:10]


# 실습: 불용어 제거하기 
# 단계 1: 데이터 전처리
# 단계 1-1: 문장부호 제거 
myCorpusPrepro <- tm_map(myCorpus, removePunctuation)
# 단계 1-2: 수치 제거 
myCorpusPrepro <- tm_map(myCorpusPrepro, removeNumbers)
# 단계 1-3: 소문자 변경
myCorpusPrepro <- tm_map(myCorpusPrepro, tolower)
# 단계 1-4: 제거할 단어 지정
myStopwords = c(stopwords('english'), "사용", "하기")
# 단계 1-5: 불용어 제거 
myCorpusPrepro <- tm_map(myCorpusPrepro, removeWords, myStopwords)

#단계 2: 단어 선별과 평서문 변환
myCorpusPrepro_term <-
  TermDocumentMatrix(myCorpusPrepro,
                     control = list(wordLengths = c(4, 16)))
myTerm_df <- as.data.frame(as.matrix(myCorpusPrepro_term))


# 단계 3: 단어 출현 빈도수 구하기 
wordResult <- sort(rowSums(myTerm_df), decreasing = TRUE)
wordResult[1:10]



# 실습: 단어 구름에 디자인(빈도수, 색상, 위치, 회전 등) 적용하기 
# 단계 1: 단어 이름과 빈도수로 data.frame 생성
myName <- names(wordResult)
word.df <- data.frame(word = myName, freq = wordResult)
str(word.df)

# 단계 2: 단어 색상과 글꼴 지정
pal <- brewer.pal(12, "Paired")

# 단계 3: 단어 구름 시각화 
wordcloud(word.df$word, word.df$freq, scale = c(5, 1), 
          min.freq = 3, random.order = F, 
          rot.per = .1, colors = pal, family = "malgun")



# 실습: 한글 연관어 분석을 위한 패킺 설치와 메모리 로딩 
# 단계 1: 텍슽 파일 가져오기 
marketing <- file("C:/Rwork/Part-II/marketing.txt", encoding = "UTF-8")
marketing2 <- readLines(marketing)
close(marketing)
head(marketing2)

# 단계 2: 줄 단위 단어 추출
lword <- Map(extractNoun, marketing2)
length(lword)
lword <- unique(lword)
length(lword)


# 단계 3: 중복 단어 제거와 추출 단어 확인
lword <- sapply(lword, unique)
length(lword)
lword


# 실습: 연관어 분석을 위한 전처리하기 
# 단계 1: 단어 필터링 함수 정의
filter1 <- function(x) {
  nchar(x) <= 4 && nchar(x) >= 2 && is.hangul(x)
}

filter2 <- function(x) { Filter(filter1, x) }

# 단계 2: 줄 단위로 추출된 단어 전처리
lword <- sapply(lword, filter2)
lword


# 실습: 필터링 간단 예문 살펴보기 
# 단계 1: vector 이용 list 객체 생성
word <- list(c("홍길동", "이순", "만기", "김"),
             c("대한민국", "우리나라대한민구", "한국", "resu"))
class(word)
word
# 단계 2: 단어 필터링 함수 정의(길이 2 ~ 4 사이 한글 단어 추출) 
filter1 <- function(x) {
  nchar(x) <= 4 && nchar(x) >= 2 && is.hangul(x)
}

filter2 <- function(x) {
  Filter(filter1, x)
}

# 단계 3: 함수 적용 list 객체 필터링
filterword <- sapply(word, filter2)
filterword




# 실습: 트랜잭션 생성하기 
# 단계 1: 연관분석을 위한 패키지 설치와 로딩
install.packages("arules")
library(arules)

# 단계 2: 트랜잭션 생성
wordtran <- as(lword, "transactions")
wordtran



# 싨브: 단어 간 연관규칙 발견하기 
# 단계 1: 연관규칙 발견
tranrules <- apriori(wordtran, 
                     parameter = list(supp = 0.25, conf = 0.05))

# 단계 2: 연관규칙 생성 결과보기 
inspect(tranrules)


# 실습: 연관규칙을 생성하는 간단한 예문 살펴보기 
# 단계 1: Adult 데이터 셋 메모리 로딩
data("Adult")
Adult
str(Adult)
dim(Adult)
inspect(Adult)

# 단계 2: 특정 항목의 내용을 제외한 itermsets 수 발견
apr1 <- apriori(Adult,
                parameter = list(support = 0.1, target = "frequent"),
                appearance = list(none = 
                                    c("income=small", "income=large"),
                                  default = "both"))

apr1

inspect(apr1)


# 단계 3: 특정 항목의 내용을 제외한 rules 수 발견
apr2 <- apriori(Adult, 
                parameter = list(support = 0.1, target = "rules"), 
                appearance = list(none = 
                                    c("income=small", "income=large"),
                                  default = "both"))
apr2


# 단계 4: 지지도와 신뢰도 비율을 높일 경우
apr3 <- apriori(Adult, 
                parameter = list(supp = 0.5, conf = 0.9, target = "rules"),
                appearance = list(none =
                                    c("income=small", "income=large"),
                                  default = "both"))
apr3



# 실습: inspect() 함수를 사용하는 간단 예문 보기 
data(Adult)
rules <- apriori(Adult)
inspect(rules[10])



# 연관어 시각화하기
# 단계 1: 연관단어 시각화를 위해서 자료구조 변경 
rules <- labels(tranrules, ruleSep = " ")

rules


# 단계 2: 문자열로 묶인 연관 단어를 행렬구조로 변경 
rules <- sapply(rules, strsplit, " ", USE.NAMES = F)
rules

# 단계 3: 행 단위로 묶어서 matrix로 변환
rulemat <- do.call("rbind", rules)

class(rulemat)

# 단계 4: 연관어 시각화를 위한 igraph 패키지 설치와 로딩
install.packages("igraph")
library(igraph)

# 단계 5: edgelist 보기 
ruleg <- graph.edgelist(rulemat[c(12:59), ], directed = F)
ruleg


# 단계 6: edgelist 시각화 
plot.igraph(ruleg, vertex.label = V(ruleg)$name, 
            vertex.label.cex = 1.2, vertext.label.color = 'black',
            vertex.size = 20, vertext.color = 'green',
            vertex.frame.co.or = 'blue')



# 실습: 웹 문서 요청과 파싱 관련 패키지 설치 및 로딩
install.packages("httr")
library(httr)
install.packages("XML")
library(XML)


# 실습: 웹 문서 요청
url <- "http://media.daum.net"
web <- GET(url)
web

# 실습: HTML 파싱하기 
html <- htmlTreeParse(web, useInternalNodes = T, trim = T, encoding = "utf-8")
rootNode <- xmlRoot(html)


# 실습: 태그 자료 수집하기 
news <- xpathSApply(rootNode, "//a[@class = 'link_txt']", xmlValue)
news


# 실습: 자료 전처리하기 
# 단계 1: 자료 전처리 - 수집한 문서를 대상으로 불용어 제거
news_pre <- gsub("[\r\n\t]", ' ', news)
news_pre <- gsub('[[:punct:]]', ' ', news_pre)
news_pre <- gsub('[[:cntrl:]]', ' ', news_pre)
# news_pre <- gsub('\\d+', ' ', news_pre)   # corona19(covid19) 때문에 숫자 제거 생략
news_pre <- gsub('[a-z]+', ' ', news_pre)
news_pre <- gsub('[A-Z]+', ' ', news_pre)
news_pre <- gsub('\\s+', ' ', news_pre)

news_pre

# 단계 2: 기사와 관계 없는 'TODAY', '검색어 순위' 등의 내용은 제거 
news_data <- news_pre[1:59]
news_data


# 실습: 수집한 자료를 파일로 저장하고 읽기
setwd("C:/Rwork/output")
write.csv(news_data, "news_data.csv", quote = F)

news_data <- read.csv("news_data.csv", header = T, stringsAsFactors = F)
str(news_data)

names(news_data) <- c("no", "news_text")
head(news_data)

news_text <- news_data$news_text
news_text


# 실습: 세종 사전에 단어 추가 
user_dic <- data.frame(term = c("펜데믹", "코로나19", "타다"), tag = 'ncn')
buildDictionary(ext_dic = 'sejong', user_dic = user_dic)


# 실습: 단어 추출 사용자 함수 정의하기 
# 단계 1: 사용자 정의 함수 작성
exNouns <- function(x) { paste(extractNoun(x), collapse = " ")}

# 단계 2: exNouns()  함수를 이용하어 단어 추출
news_nouns <- sapply(news_text, exNouns)
news_nouns

# 단계 3: 추출 결과 확인
str(news_nouns)



# 실습: 말뭉치 생성과 집계 행렬 만들기 
# 단계 1: 추출된 단어를 이용한 말뭉치(corpus) 생성
newsCorpus <- Corpus(VectorSource(news_nouns))
newsCorpus

inspect(newsCorpus[1:5]) 

# 단계 2: 단어 vs 문서 집계 행렬 만들기 
TDM <- TermDocumentMatrix(newsCorpus, control = list(wordLengths = c(4, 16)))
TDM

# 단계 3: matrix 자료구조를 data.frame 자료구조로 변경
tdm.df <- as.data.frame(as.matrix(TDM))
dim(tdm.df)



# 실습: 단어 출현 빈도수 구하기 
wordResult <- sort(rowSums(tdm.df), decreasing = TRUE)
wordResult[1:10]




# 실습: 단어 구름 생성
# 단계 1: 패키지 로딩과 단어 이름 추출
library(wordcloud)
myNames <- names(wordResult)
myNames


# 단계 2: 단어와 단어 빈도수 구하기 
df <- data.frame(word = myNames, freq = wordResult)
head(df)

# 단계 3: 단어 구름 생성
pal <- brewer.pal(12, "Paired")
wordcloud(df$word, df$freq, min.freq = 2,
          random.order = F, scale = c(4, 0.7),
          rot.per = .1, colors = pal, family = "malgun")

install.packages("ggplot2")

