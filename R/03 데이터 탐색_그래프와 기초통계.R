#==================================================
# 3. 데이터 탐색
#==================================================


# 3.1 기본 그래프 ----------------------------- 

# Scatter 산점도
library(ggplot2)
dia <- data.frame(diamonds)
plot(dia$carat, dia$price)

# Histogram
hist(dia$carat, breaks = 20)

# Barplot
avgPrice <- aggregate(price ~ color, data=dia, mean)
barplot(avgPrice$price, names.arg=avgPrice$color)

# Boxplot
boxplot(dia$carat)

# 3.2 기본 그래프 ----------------------------- 

# 데이터 샘플링. 
nrow(diamonds)
sample(nrow(diamonds), 10000)

dsmall <- diamonds[sample(nrow(diamonds), 10000), ]

# Scatter 산점도
qplot(carat, price, data = dsmall)

# 몇가지 옵션
qplot(carat, price, data = dsmall, colour = color)
qplot(carat, price, data = dsmall, shape = cut)

# Adding a smoother to a plot
qplot(carat, price, data = dsmall, geom = c("point", "smooth"))

# Boxplot
qplot(color, price / carat, data = dsmall, geom = "boxplot")

# histogram
qplot(carat, data = dsmall, geom = "histogram", binwidth = 0.2)
qplot(carat, data = diamonds, geom = "histogram", fill = color)

# density plot
qplot(carat, data = diamonds, geom = "density")
qplot(carat, data = diamonds, geom = "density", colour = color)

# Bar chart
qplot(color, data = dsmall, geom = "bar")

# facet 옵션

qplot(carat, data = dsmall, facets = color ~ .,
      geom = "histogram", binwidth = 0.1, xlim = c(0, 3))

qplot(carat, data = diamonds, geom = "histogram", fill = color
      , binwidth = 0.1, xlim = c(0, 3))


# Line chart
?economics

qplot(date, unemploy / pop, data = economics, geom = "line")

# path
install.packages("lubridate")
library(lubridate)
# year, month 함수 Date 형식에서 추출하기

qplot(unemploy / pop, uempmed, data = economics,
      geom = "path", colour = year(date)) 




