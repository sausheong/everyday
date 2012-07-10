library(ggplot2)

pdf("figure3-9.pdf")

df <- function(sim) {
  data <- read.table(paste(sim,".csv",sep=""), header=TRUE, sep=",")
  max  <- apply(data,2,max)
  return(data.frame(population=seq(from=10,to=600,by=10),max=max))
}

ggplot() + scale_shape_manual(name="Type", values=c(2,3,4,22)) + 
  geom_smooth(data = df("simulation3"), aes(x=population,y=max)) +
  geom_point(data  = df("simulation3"), aes(x=population,y=max,shape="max-1x12")) +
  geom_smooth(data = df("simulation3-4"), aes(x=population,y=max)) +
  geom_point(data  = df("simulation3-4"), aes(x=population,y=max,shape="max-4x3")) +  
  scale_y_continuous("queue size") +
  scale_x_continuous("population")
