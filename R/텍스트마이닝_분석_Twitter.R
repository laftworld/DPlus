# 이숙번 2017 R 기초
# twitter 분석

# 0. 트위터 크롤링 ----------------------------------------------------------------
rm(list=ls())
getwd()
setwd("/Users/leesookbun/Desktop/Dplus/20171023_부산진흥원")

# Window
# setwd("C:\\Users\\GilbertHan\\Documents")

word_data <- NULL
results_nouns <- NULL
results_wordcount <- NULL

#  트위터 API 연결 --------------------------------------------------------------
# stentiment Analysis를 위한 기본 setting 
# 1. twitter 계정 만들기#
# 2. twitter에 접속 한 후 application 생성
#     http://apps.twitter.com
# 3. consumerkey, consumerSecret

if (!require(twitteR)) { install.packages("twitteR"); require(twitteR) }

### Keys and Access Tokens 탭에서 다음을 찾아 입력한다.
# Declare Twitter API Credentials
# token은 'Generate Consumer Key'를 누르면 아래 정보가 나타난다. 

# token 설정
# 파일에는 순서대로 값이 한줄에 하나씩 있어야 한다.
tokens <- read.csv(file='twitter_token.txt', header=FALSE, colClasses='character', sep=','); tokens

# tokens
consumer_key <- tokens[1,]
consumer_secret <- tokens[2,]
access_token <- tokens[3,]
access_token_secret <- tokens[4,]

# Create Twitter Connection
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_token_secret)
# options(encoding='euc-kr')

keyword <- '심심해'
## 한글일 때
results <- searchTwitter(enc2utf8(keyword), n=1000, lang='ko')
## 영문일 때
# results <- searchTwitter(keyword, n=100, lang="en")

# if (localeToCharset() == 'CP949') {
#   keyword <- iconv(keyword, localeToCharset()[1], "UTF-8")
# }

# 결과 확인
head(results) 
tail(results)

# twitter 검색 결과를 data frame으로 변환한다.
results.df <- twListToDF(results) 
head(results.df, 1)

# 트위터에서 어떤 종류의 데이터를 넘겨주는 지 확인
colnames(results.df)

# 여러 컬럼 중 text 컬럼만 별도로 저장한다.
results.text <- results.df$text 
tail(results.text, 50)

# 검색 결과 저장/ 불러오기 ----------------------------------------------------------
# save(results, file="twitter_result.RData")  # 가져온 결과를 임시로 저장한다.
# load("twitter_result.RData")


# text 전처리 - 단어 추출 -----------------------------------------------------------------
if (!require(rJava)) { install.packages("rJava"); require(rJava) }
if (!require(KoNLP)) { install.packages("KoNLP"); require(KoNLP) }

useSejongDic()

# 단어만 골라내기
word_data <- sapply(results.text, extractNoun, USE.NAMES=F); word_data
word_data <- unlist(word_data); word_data

# 함수를 사용하여 불필요한 문자를 걸러낸다. 
# source() 를 사용하면 다른 스크립트에 저장된 코드를 사용할 수 있다
# 함수 코드는 text_cleanup.R 문서에서 가져온다.
source("text_cleanup.R", encoding="UTF-8")
word_data <- text_cleanup(word_data, c(keyword, '심심')); word_data

# 두글자 이상 단어만 추출하기
results_nouns <- Filter(function(x) { nchar(x) >= 2 }, word_data); results_nouns

# 결과 확인
# 최종 분석할 단어
head(results_nouns, 50)
tail(results_nouns)

# keyword에 대해 긍정/부정 반응 -----------------------------------------------------------
# 긍정 단어 부정 단어를 가진 다음 파일이 같은 폴더에 있어야 한다.
# 이 파일에 있는 단어를 기준으로 긍정/부정 점수를 부여한다.
# 필요하면 이 단어 사전에 원하는 단어를 추가/ 삭제/ 수정 한다.
# ANSI 인코딩일 때는 encoding="UTF-8 을 빼고 처리한다.

pos.word <- scan("positive-words-ko-v3.txt", what="character", 
                 comment.char=";", fileEncoding="UTF-8")
pos.word
neg.word <- scan("negative-words-ko-v3.txt", what="character", 
                 comment.char=";", fileEncoding="UTF-8")
neg.word

# 긍정 사전, 부정 사전에서 일치하는 단어가 있는지 찾아 낸다. 있으면 각 1점을 부여한다.
pos.matches <- match(results_nouns, pos.word); pos.matches
neg.matches <- match(results_nouns, neg.word); neg.matches
pos.matches <- !is.na(pos.matches); pos.matches
neg.matches <- !is.na(neg.matches); neg.matches

# 합을 구하고 긍정 - 부정 값을 구한다.
sum(pos.matches); sum(neg.matches)
score <- sum(pos.matches) - sum(neg.matches)
if (score >= 0) {
  print("긍정")
  score
} else {
  print("부정")
  score
}


# wordcloud 그리기 -----------------------------------------------------------
if (!require(wordcloud)) { install.packages("wordcloud"); require(wordcloud) }

# 가장 많이 나타난 단어 50개만 살펴보자.
results_wordcount <- table(results_nouns)  # 문자 카운팅
results_wordcount <- head(sort(results_wordcount, decreasing=T), 400) 

pal <- brewer.pal(12, "Paired") # 컬러 세팅

# 폰트 세팅
# windowsFonts(malgun=windowsFont("맑은 고딕"))
# 윈도우즈 폰트데이터베이스에서 찾을 수 없는 폰트페밀리입니다
# 라는 오류가 나타나면 설정한다.

# 그리기: 화면이 좁으면 제대로  안 보인다. 시간이 걸린다. 화면에 결과가 나타나면 , zoom을 눌러 본다.
# 화면이 깜빡 거리면 아직 그리는 중이다.
# 빨간 stop 표시가 나타나면 아직 그리는 중이다.
# Windows에서는 family="malgun"
# 맥(Apple)에서는 family="AppleGothic"
wordcloud(names(results_wordcount), freq=results_wordcount, 
          scale=c(5, 0.2), min.freq=5, random.order=F, 
          rot.per=.2, colors=pal, family="AppleGothic")

# 최소 20번 이상 나타난 단어만 그린다.
wordcloud(names(results_wordcount), freq=results_wordcount, 
          scale=c(5, 0.5), min.freq=20, random.order=F,
          rot.per=.2, colors=pal, family="AppleGothic")

# scale 앞 자리는 전체 크기를 결정한다. 뒷자리는 빈도에 따른 글자 크기 비유을 결정한다.
wordcloud(names(results_wordcount), freq=results_wordcount, 
          scale=c(5, 0.2), min.freq=10, random.order=F, 
          rot.per=.2, colors=pal, family="AppleGothic")
wordcloud(names(results_wordcount), freq=results_wordcount, 
          scale=c(20, 0.6), min.freq=30, random.order=F, 
          rot.per=.2, colors=pal, family="AppleGothic")
wordcloud(names(results_wordcount), freq=results_wordcount, 
          scale=c(20, 1.5), min.freq=10, random.order=F, 
          rot.per=.2, colors=pal, family="AppleGothic") ## best

# rot.per: 0~1 90도 회전시킬 단어들의 비율
wordcloud(names(results_wordcount), freq=results_wordcount, scale=c(5, 0.2), min.freq=5, random.order=F, rot.per=.5, colors=pal, family="AppleGothic")
wordcloud(names(results_wordcount), freq=results_wordcount, scale=c(20, 0.6), min.freq=30, random.order=F, rot.per=.0, colors=pal, family="AppleGothic")

# random.order 나타날 글자들의 순서를 랜덤으로 정한다. F이면 감소하는 순서대로 나타난다.
wordcloud(names(results_wordcount), freq=results_wordcount, scale=c(5, 0.2), min.freq=5, random.order=T, rot.per=.5, colors=pal, family="malgun")

# 한글 검색을 위해서. 영어만 할 때는 불필요 설치하지 않으면 한글로된 내용을 다룰때에는 'utf8towcs'에 잘못된 입력 이라는 오류가 발생합니다
if (!require(Unicode)) { install.packages("Unicode"); require(Unicode) }

# > options()$encoding
# [1] "native.enc"