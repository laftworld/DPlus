# 정원혁 2014 R 기초
# 이숙번 2017 Update

text_cleanup <- function(x, keywords = vector()) {
  for (k in keywords) {
    x <- gsub(k, " ", x)
  }
  
  # 숫자 제외, 정규식
  x <- gsub("\\d+", "", x)
  
  # ( )괄호 제외
  x <- gsub("\\(", "", x)
  x <- gsub("\\)", "", x)
  
  # 영문 제외
  x <- gsub("[A-Za-z]", "", x)

  x <- gsub("@\\w+", "", x)
  x <- gsub("[[:punct:]]", "", x)
  x <- gsub("[[:digit:]]", "", x)
  x <- gsub("[ \t]{2,}", "", x)
  x <- gsub("^\\s+|\\s+$", "", x) 
  x <- gsub("ㄴ|ㅋ|ㅎ|ㅊ|ㅠ|ㅜ|큨|큐|ㅣ|ㅇ|ㄹ|ㅂ|ㅍ|ㄱ|ㅅ|ㅛ|ㄷ|ㅈ|ㅁ|ㅗ|ㅡ|ㅏ|ㅐ", "", x) 

  # 한글 utf-8 garbage
  x <- gsub("[\xed\xa0\x80-\xed\xff\xff]", "", x)
  # 한글 unicode garbage
  x <- gsub("[\u2000-\u2fff]", "", x)

  return(x)
}