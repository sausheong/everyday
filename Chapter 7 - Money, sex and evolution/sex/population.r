library(ggplot2)
library(mgcv)

data <- read.table("data-stable.csv", header=F, sep=",")
pdf("sex.pdf")
colnames(data) <- c('population','male','female')
time = 1:nrow(data)
ggplot(data=data) + 
  geom_smooth(aes(time,population),color='gray',method='gam',formula=y~s(x,bs="cs")) + 
  geom_smooth(aes(time,male),color='blue',method='gam',formula=y~s(x,bs="cs")) + 
  geom_smooth(aes(time,female),color='pink',method='gam',formula=y~s(x,bs="cs")) 
dev.off()

