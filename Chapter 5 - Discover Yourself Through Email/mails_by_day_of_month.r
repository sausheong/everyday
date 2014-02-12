library(ggplot2)
library(mailminer)

pdf("ch08_ex1.pdf")
inbox_data <- read.table("inbox_data_enron.csv", header=TRUE, sep=",")
sent_data <- read.table("sent_data_enron.csv", header=TRUE, sep=",")

inbox_count <- dates_count(dates=inbox_data['date'], element='%d')
sent_count <- dates_count(dates=sent_data['date'], element='%d')

days_of_month <- c("01","02","03","04","05","06","07","08","09","10",
                   "11","12","13","14","15","16","17","18","19","20",
                   "21","22","23","24","25","26","27","28","29","30","31")
df <- data.frame(days=factor(days_of_month, levels=days_of_month),inbox=inbox_count,sent=sent_count)

ggplot(data=df) + scale_shape_manual(name="Mailbox", values=c(2,3)) +
  geom_point(aes(x=days,y=inbox, shape='inbox')) +
  geom_smooth(aes(x=days,y=inbox, group=1)) +
  geom_point(aes(x=days,y=sent, shape='sent')) +
  geom_smooth(aes(x=days,y=sent, group=2)) +
  scale_y_continuous('number of emails') +
  scale_x_discrete('day of month')