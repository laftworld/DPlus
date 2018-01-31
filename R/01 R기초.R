rm(list = ls())

##################################################################################
# 1. 개요 ----------------------------------------------------------------
##################################################################################

#(1)라이브러리 -------------------------------------------------------------
.libPaths()

install.packages("ggplot2")

library(ggplot2)

detach("package:ggplot2", unload = T)


#(2)도움말 -------------------------------------------------------------

?seq

??seq

example(seq)

install.packages("sos")
library(sos)

findFn("standard deviation", maxPages = 1)


##################################################################################
# 2.3 데이터형식 ----------------------------------------------------------------
##################################################################################

#(1)변수 -------------------------------------------------------------
 
a <- 3
b = 4.5
c <- a + b
c

#(2)스칼라 -------------------------------------------------------------
d <- "Hello"
e <- 'R World!'
f <- d + e

#Error in d + e : non-numeric argument to binary operator
f <- paste(d, e, sep = ' ')
f


# true & false
TRUE & FALSE
TRUE | FALSE

c(TRUE, T) & c(FALSE, F)
c(TRUE, T) && c(FALSE, F)


# factor
gender <- factor('male', c('male', 'female'))
gender
str(gender)

# (3) vector
x <- c(1,2,3,4,5)
x

y <- c('a','b','c','d',2)
y

# 표현식 : ':'
1:10

x
x[2]
2:4
y[2:4]
x1 <- 1:20
x1
seq(1,10,.2)
rep(x1,2)
rep(5:10,2)
length(x1)

x + x1
x - x1
x * x1
x / x1

x2 <- c(x,6,7,8) ; x2
x2 <- 1 ; x2
# (4) list -------------------------------------------------------------

x <- list(name="hanky",
          sight = c(0.8, 0.5))
class(x)
x
x[2]
x[[2]]
x[[2]][1]

x$sight
x$sight[1]

str(x)

cars
a<- lapply(cars, sum)
class(a)
a
a$speed


# (5) matrix -------------------------------------------------------------
matrix(1:9, nrow = 3)
matrix(1:9, nrow = 3, byrow = T)
matrix(1:9, nrow = 3
       , dimnames = list(c("r1","r2","r3")
                         ,c("c1","c2","c3")))

m <- matrix(1:9, nrow = 3)
m[2,3]
m[2,]

# []에서의 표현 : [행,열]
m
m[1,]
m[,1]
m[1,1:3]
m[1,1:2]
m[1,c(1,3)]

m1 <- matrix(1:9, nrow = 3
       , dimnames = list(c("r1","r2","r3")
                         ,c("c1","c2","c3")))

m1["r1",]

m2 <- matrix(1:9, nrow = 3)
m3 <- matrix(1:9, nrow = 3, byrow = T)
m2
m2 * 2
m2[,4] <- c(10,11,12)
cbind(m2, c(10,11,12))
m2 + m3
m2 * m3
m2;m3
m2 %*% m3
solve(m2)
det(m2)

m4 <- matrix(1:4, nrow = 2)
m4
solve(m4)
m5 <- solve(m4)

# 행렬과 역행렬의 곱은 단위행렬
m4 %*% m5

t(m4)

# (6) data frame

df <- data.frame(x=1:5, y = seq(2,10,2)) ; df
df$x
df$y
df
# adding column
df$z <- c("kim","lee","park","han","kang")
df
df[,"z"]
df$z
df[,3]
df[1,3]
df[2:3,c("x","z")]
df[2:3,c(1,3)]

class(cars)
nrow(cars)
head(cars)
tail(cars)
?cars
head(cars, 20)
tail(cars, 2)
str(cars)
df
#changing column name
names(df)
names(df) <- c("CustomerID","Age", "LastName")
df
df[4:5,]




# (7) 데이터 형식 다루기 -------------------------------------------------------------
class(m1)
class(df)

df2m <- as.matrix(df)
m12df <- as.data.frame(m2)

class(df2m)
class(m12df)
m12df
m2
# (8) NA, NULL -------------------------------------------------------------
df$City <- c("Seoul","Busan",NA,NA,"Incheon")
df
is.na(df)
colSums(is.na(df))
is.na(df$City)

df$City[c(3,4)]

df$City[is.na(df$City)]

df$City[is.na(df$City)] <- "Daejeon"
df$City
df


i <- NULL
i
is.null(i)

df$City <- NULL
df
##################################################################################
# 3. R데이터 다루기 -------------------------------------------------------------
##################################################################################

# (1) 파일 가져오기 & 파일로 저장하기 ----------------------------------------------------

#working directory
getwd()

#아래 경로에는 여러분의 작업 디렉토리 경로를 넣으세요.
setwd("C:\\Users\\Gilbert Han\\Documents\\2.회사업무\\D_plus\\2.강의\\데이터진흥원_유통빅데이터과정_R")

df1 <- read.csv("testdata.csv")
df1

#화면으로 보여줄 행수 지정
options(max.print=10000)


ds.0 <- read.csv("https://archive.ics.uci.edu/ml/machine-learning-databases/car/car.data")
ds.0

write.csv(ds.0, "test.csv")


# (2) 작업환경 저장하기 & 불러오기  ----------------------------------------------------

save.image("test.RData")
rm(list=ls())
load("test.RData")

rm(ds.0)
rm(list = ls())

# (3) 데이터프레임 열 추가, 변경, 삭제  ----------------------------------------------------
library(ggplot2)

str(diamonds)

dia <- data.frame(diamonds)
str(dia)

dia$volume <- dia$x * dia$y * dia$z
head(dia)
dia$volume <- round(dia$volume,1)
head(dia)

dia$volume2 <- NA
head(dia)

str(dia)

dia$volume2 <- NULL
dia$volume <- NULL
head(dia)

# (3) 원하는 데이터 조회하기  ----------------------------------------------------

subset(dia, select = c("carat", "color", "price")
       , subset = (color == "E" & price > 1000))

which(dia$color == "E" & dia$price > 1000)

dia[which(dia$color == "E" & dia$price > 1000)
    , c("carat", "cut", "color", "price")]

attach(dia)
dia[which(color == "E" & price > 1000)
    , c("carat", "cut", "color", "price")]
detach(dia)

# (5) 데이터 프레임 합치기  ----------------------------------------------------
cust_id <- c("c01","c02","c03","c04")
cust_id
last_name <- c("Kim", "Lee", "Choi", "Park")

cust_mart_1 <- data.frame(cust_id, last_name)

cust_mart_1

cust_mart_2 <- data.frame(cust_id = c("c05", "c06", "c07")
                          , last_name = c("Bae", "Kim", "Lim"))
cust_mart_1
cust_mart_2

cust_mart_12 <- rbind(cust_mart_1, cust_mart_2)

cust_mart_12


# cbind
cust_mart_5 <- data.frame(age = c(20, 25, 19, 40, 32, 39, 28)
                          , income = c(2500, 2700, 0, 7000, 3400, 3600, 2900))

cust_mart_5
cust_mart_125 <- cbind(cust_mart_12, cust_mart_5)
cust_mart_125

str(cust_mart_125)


# (6) dplyr 패키지  ----------------------------------------------------

install.packages("dplyr")
library(dplyr)

head(diamonds, 10)
class(diamonds)

# select
diamonds[,c("carat","cut","color")]
select(diamonds, carat, cut, color, price)

# filter
diamonds[diamonds$carat >= 1 & diamonds$cut == 'Premium',]
filter(diamonds, carat >= 1, cut == 'Premium')
filter(diamonds, carat >= 1 & cut == 'Premium')
filter(diamonds, carat >= 1 | cut == 'Premium')


# mutate
dia2 <- mutate(diamonds, volume = round(x*y*z, digits = 2))
head(dia2)

dia0 <- diamonds
head(dia0)
dia0$volume <- round(dia0$x*dia0$y*dia0$z, digits = 2)

head(dia0)
select(a, cut, price, carat, x,y,z,volume)

#변수 삭제1
dia2$volume <- NULL
str(dia2)

#열,행 번호에 -를 붙이면 그 인덱스에 해당하는 열/행을 제외한다.
dia0[,-11]
dia0 <- dia0[,-11]
str(dia0)

# arrange

arrange(diamonds, price)
arrange(diamonds, desc(price))

# group_by

groupby.df <- group_by(diamonds, color)
groupby.df
summarise(groupby.df, AvgPrice = mean(price))

groupby.df <- group_by(diamonds, cut)
summarise(groupby.df, AvgPrice = mean(price))


# %>%
select(diamonds, carat, cut, color, price) %>%
    filter(carat >= 1, cut == 'Premium')

group_by(diamonds, color) %>% 
  summarise(AvgPrice = mean(price), maxPrice = max(price)) %>%
  arrange(desc(maxPrice))

group_by(diamonds, color) %>% summarise(AvgPrice = mean(price))

group_by(diamonds, color) 
%>% summarise(AvgPrice = mean(price))


# (7) apply 함수들  ----------------------------------------------------

if (require(ggplot2)) {
  require(ggplot2)
} else {
  install.packages("ggplot2")
  require(ggplot2)
}

#임의의 수를 생성해보자.

sample(1:10,5)
sample(1:10,5, replace = TRUE)

#set.seed(숫자) 숫자가 같으면 동일한 결과를 얻는다.
set.seed(10)
sample(1:10,5)

#정규분포를 이루는 임의의 값 추출하기
?rnorm

rnorm(100)
rnorm(100, mean = 0, sd = 1)
mean(rnorm(10000))
sd(rnorm(10000))

x<-matrix(rnorm(30), nrow=5, ncol=6);x
apply(x, 2 ,mean)
apply(x, 2 ,max)

head(cars)

apply(cars, 2 ,mean)
apply(cars, 2 ,max)

la <- lapply(cars, sum);la
la$dist

sa <- sapply(cars, sum);sa

class(sa)

tapply(mpg$cty, mpg$manufacturer, max)

mpg

