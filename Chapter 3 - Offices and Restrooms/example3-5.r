library(ggplot2)

data <- read.table("simulation1.csv", header=TRUE, sep=",")
mean <- colMeans(data)
median <- apply(data,2,median)
max  <- apply(data,2,max)
df <- data.frame(population=seq(from=10,to=600,by=10),mean=mean, median=median,max=max)

ggplot(data = df) + scale_shape_manual(name="Type", values=c(2,3,4)) +
  geom_smooth(aes(x = population, y = mean)) +
  geom_point(aes(x  = population, y = mean, shape = "mean")) +
  geom_smooth(aes(x = population, y = median)) +
  geom_point(aes(x  = population, y = median, shape = "median")) +
  geom_smooth(aes(x = population, y = max)) +
  geom_point(aes(x  = population, y = max, shape = "max")) +
  scale_y_continuous("queue size") +
  scale_x_continuous("population")

ggsave("figure3-2.pdf")
