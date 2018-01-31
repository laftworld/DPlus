# 이숙번 2017 R 기초
# Naver 기사 분석

# 0. 네이버 기사 크롤링 ----------------------------------------------------------------
rm(list=ls())
getwd()
setwd("/Users/leesookbun/Desktop/Dplus/20171023_부산진흥원")
# Window
# setwd("C:\\Users\\GilbertHan\\Documents")

page_list <- NULL
save_files <- NULL
ds_news <- NULL
word_data <- NULL
results_nouns <- NULL
results_wordcount <- NULL

# A. 네이버 기사 크롤링 ----------------------------------------------------------------
# 네이버 뉴스 크롤링 : 출처 : https://github.com/forkonlp/N2H4
# 1. 범위 지정
# 1-1. 카테고리 선택
# 1-2. 세부 카테고리 선택
# 1-3.검색할 날짜 지정

# library
if (!require(devtools)) { install.packages("devtools"); require(devtools) }
if (!require(N2H4)) { devtools::install_github("forkonlp/N2H4"); require(N2H4) }

# 1-1. 카테고리 선택
# 메인 카테고리를 선택하여 가져옵니다. sid1
cate <- getMainCategory(); cate; 
sid1 <- cate$sid1[1]; sid1 # 1번 선택
# 1      정치  100
# 2      경제  101
# 3      사회  102
# 4 생활/문화  103
# 5      세계  104
# 6   IT/과학  105

# 1-2. 세부 카테고리 선택
# 세부 카테고리를 선택하여 가져옵니다. sid2
sub_cate <- getSubCategory(sid1=sid1); sub_cate
sid2 <- sub_cate$sid2[6]; sid2 # 6번 선택
# 1  101          금융  259
# 2  101          증권  258
# 3  101     산업/재계  261
# 4  101     중기/벤처  771
# 5  101        부동산  260
# 6  101   글로벌 경제  262
# 7  101      생활경제  310
# 8  101     경제 일반  263

# 1-3.검색할 날짜 지정
# 초기값
start_date <- "20171025" # 시작 날짜를 지정합니다.
end_date <- "20171025"    # 종료 날짜를 지정합니다.
max_page <- 5 # 각각의 날짜별 max page - 10을 입력하면 10페이지에 200(10 * 20)개의 기사를 스크랩합니다.

# 페이지 리스트 생성
# page_list - 기사 목록의 1페이지, 2페이지, ... 의 url을 저장할 벡터
# url sample: http://news.naver.com/main/list.nhn?mode=LS2D&mid=shm&sid2=264&sid1=100&date=20171023
for (date in start_date:end_date) {
  # 뉴스 리스트 페이지의 url을 sid1, sid2, date로 생성합니다.
  base_url <- paste0("http://news.naver.com/main/list.nhn?mode=LS2D&mid=shm&sid2=", sid2, "&sid1=", sid1, "&date=", date)
  # 리스트 페이지의 마지막 페이지수를 가져옵니다.
  max <- getMaxPageNum(base_url)
  
  # page_list 생성
  for (page_num in 1:max) {
    page_list <- c(page_list, paste0(base_url, "&page=", page_num))
    
    if (length(page_list) >= max_page) break
  }
}; page_list

page_num <- 0
count <- 0
max_count <- length(page_list) * 20
start_time <- Sys.time(); mid_time <- Sys.time()  # for log message

for (page in page_list) {
  page_num <- page_num + 1
  news_data <- c()  # news_data 초기화
  
  # 뉴스 리스트 페이지 내의 개별 네이버 뉴스 url들을 가져옵니다.
  news_list <- getUrlListByCategory(page)
  
  # news_list에 저장된 url에 접속하여 기사를 가져옵니다.
  for (news_link in news_list$links) {
    # 기사 가져오기
    tem <- getContent(news_link)
    if (class(tem$datetime)[1] == "POSIXct") {
      news_data <- rbind(news_data, tem)
    }
    
    # log message
    count <- count + 1
    print(paste0("(", count, "/", max_count, ") ", news_link, 
                 " / spent Time: ", Sys.time() - mid_time, " / spent Time at first: ", Sys.time() - start_time))
    mid_time <- Sys.time()
  }
  
  # 가져온 뉴스들(한 페이지에 20개의 뉴스가 있습니다.)을 csv 형태로 저장합니다.
  dir.create("./naver", showWarnings=F)
  filename <- paste0("./naver/news_", sid1, "_", sid2, "_", date, "_", page_num, ".csv")
  write.csv(news_data, file=filename, row.names=F)
  save_files <- c(save_files, paste0("news_", sid1, "_", sid2, "_", date, "_", page_num, ".csv"))
}

# 2. 저장한 뉴스를 불러옵니다. ------------------------------------------------------------

#파일 이름 가져오기
file.name <- list.files('naver'); file.name

# 파일 하나씩 가져와서 하나의 데이터셋에 담기
for (i in 1:length(file.name)) {
  temp_ds <- read.csv(paste('naver/', file.name[i], sep=""), stringsAsFactor=FALSE, header=T)
  ds_news <- rbind(ds_news, temp_ds)
}

nrow(ds_news)
head(ds_news)
tail(ds_news)

ds_news <- as.data.frame(ds_news[,c(3,5)])
ds_news <- unique(ds_news)

str(ds_news)
head(ds_news)
tail(ds_news)

# 3. text 전처리 - 단어 추출 ----------------------------------------------------------
if (!require(rJava)) { install.packages("rJava"); require(rJava) }
if (!require(KoNLP)) { install.packages("KoNLP"); require(KoNLP) }

useSejongDic()

# 사이즈 줄이기
# ds_news <- ds_news[sample(1:nrow(ds_news), 40),]; ds_news

# 단어만 골라내기
word_data <- sapply(ds_news, extractNoun, USE.NAMES=F)
word_data <- unlist(word_data[,2]); word_data

# 함수를 사용하여 불필요한 문자를 걸러낸다. 
# source() 를 사용하면 다른 스크립트에 저장된 코드를 사용할 수 있다
# 함수 코드는 text_cleanup.R 문서에서 가져온다.
source("text_cleanup.R", encoding="UTF-8")
word_data <- text_cleanup(word_data); word_data

# 두글자 이상 단어만 추출하기
results_nouns <- Filter(function (x) { nchar(x) >= 2 }, word_data); results_nouns

# 결과 확인
# 최종 분석할 단어
head(results_nouns, 50)
tail(results_nouns)

# 4. text mining 워드클라우드 ----------------------------------------------------------
if (!require(wordcloud)) { install.packages("wordcloud"); require(wordcloud) }

# 가장 많이 나타난 단어 50개만 살펴보자.
results_wordcount <- table(results_nouns)  # 문자 카운팅
results_wordcount <- head(sort(results_wordcount, decreasing=T), 400) 
results_wordcount

# pal <- brewer.pal(12, "Paired") # 컬러 세팅
pal <- brewer.pal(8, "Dark2") # 컬러 세팅

# wordcloud(names(results_wordcount), freq=results_wordcount, scale=c(10, .5), min.freq=2,
#           max.words=Inf, random.order=F, rot.per=.15, random.color=T,
#           colors=brewer.pal(9, "Dark2"))

wordcloud(names(results_wordcount), freq=results_wordcount, 
          scale=c(10, .5), min.freq=4, max.words=Inf, random.order=T, 
          rot.per=.2, colors=pal, family="AppleGothic")

# scale : 폰트크기 c(MAX, MIN)
# rot.per : 회전되는 단어의 빈도
# min.freq : 등장하는 단어의 최소 빈도 단위
# random.order=F : 빈도가 큰 단어를 중앙에 두도록 함
# random.color=T : 실행시마다 단어의 색 변화하도록 함
# brewer.pal : https://www.r-bloggers.com/choosing-colour-palettes-part-ii-educated-choices/
# 
# 필요할지도 모르는 라이브러리
# if (!require(XML)) { install.packages("XML"); require(XML) }
# if (!require(selectr)) { install.packages("selectr"); require(selectr) }
# if (!require(tm)) { install.packages("tm"); require(tm) }
# if (!require(data.table)) { install.packages("data.table"); require(data.table) }
# if (!require(RColorBrewer)) { install.packages("RColorBrewer"); require(RColorBrewer) }


# append 1. 검색어로 뉴스 기사 검색 ------------------------------------------------------------
keyword <- '부산은행'
query_result_page_url <- getQueryUrl(keyword); query_result_page_url
news_list <- getUrlListByQuery(query_result_page_url); news_list

news_data <- c()  # news_data 초기화

# news_list에 저장된 url에 접속하여 기사를 가져옵니다.
for (news_link in news_list$links) {
  # 기사 가져오기
  tem <- getContent(news_link)
  if (class(tem$datetime)[1] == "POSIXct") {
    news_data <- rbind(news_data, tem)
  }
  
  # log message
  count <- count + 1
  print(paste0("(", count, "/", max_count, ") ", news_link, 
               " / spent Time: ", Sys.time() - mid_time, " / spent Time at first: ", Sys.time() - start_time))
  mid_time <- Sys.time()
}

# 가져온 뉴스들(한 페이지에 20개의 뉴스가 있습니다.)을 csv 형태로 저장합니다.
dir.create("./naver", showWarnings=F)
filename <- paste0("./naver/query_", keyword, ".csv")
write.csv(news_data, file=filename, row.names=F)
save_files <- c(paste0("query_", keyword, ".csv")); save_files


# append 2. 파일 삭제 -------------------------------

#파일 이름 가져오기
file.name <- list.files('naver'); file.name
# 파일 하나씩 삭제
for (i in 1:length(file.name)) {
  file.remove(paste('naver/', file.name[i], sep=""))
}
