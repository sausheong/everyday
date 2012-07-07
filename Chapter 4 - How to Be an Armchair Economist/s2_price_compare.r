library(ggplot2)
data <- read.table("price_data.csv", header=F, sep=",")

pdf("price_compare.pdf")
ggplot(data = data) + scale_colour_grey(name="Average price", start=0, end=0.6) +
  geom_line(aes(x  = V1, y = V2, color = "chickens")) +
  geom_line(aes(x  = V1, y = V3, color = "ducks")) +
  scale_y_continuous("price") +  
  scale_x_continuous("time")
dev.off()