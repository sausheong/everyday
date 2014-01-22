library(ggplot2)
library(mailminer)

pdf("ch08_ex4.pdf")
inbox_data <- read.table("inbox_data_enron.csv", header=TRUE, sep=",")
sent_data <- read.table("sent_data_enron.csv", header=TRUE, sep=",")

inbox_count <- times_count(times=inbox_data['date'], element="%H")
sent_count <- times_count(times=sent_data['date'], element='%H')

hours_of_day <- c("00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23")
df <- data.frame(hours=factor(hours_of_day, levels=hours_of_day),inbox=inbox_count,sent=sent_count)

ggplot(data=df) + scale_shape_manual(name="Mailbox", values=c(2,3)) +
  geom_point(aes(x=hours,y=inbox, shape='inbox')) +
  geom_smooth(aes(x=hours,y=inbox, group=1)) +
  geom_point(aes(x=hours,y=sent, shape='sent')) +
  geom_smooth(aes(x=hours,y=sent, group=2)) +
  scale_y_continuous('number of emails') +
  scale_x_discrete('hour of day')
