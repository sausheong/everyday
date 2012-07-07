library(ggplot2)
data <- read.table("supply_data.csv", header=F, sep=",")

pdf("supply_compare.pdf")
ggplot(data = data) + scale_colour_grey(name="Supply", start=0, end=0.6) +
  geom_line(aes(x  = V1, y = V2, color = "chickens")) +
  geom_line(aes(x  = V1, y = V3, color = "ducks")) +
  scale_y_continuous("amount") +  
  scale_x_continuous("time")
dev.off()