library(ggplot2)
data <- read.table("money.csv", header=F, sep=",")
samples <- data.frame(roid=1:51)
points = c(1,5,15,30,50,75,100,125,150,200,300,500)
 pdf("money.pdf")
grid.newpage()
pushViewport(viewport(layout=grid.layout(4,3)))
vplayout <- function(x,y) {viewport(layout.pos.row=x, layout.pos.col=y)}
row <- 1; col <- 1
for (i in points) {
  point <- data.frame(t(data[i,]))
  colnames(point) <- 'energy'
  p <- qplot(energy, data=point, geom="histogram", binwidth=5, main=paste("time=",i,sep=""))
  print(p, vp=vplayout(row,col))
  if (col == 3) {row <- row + 1}
  col <- (col %% 3) + 1
}
dev.off()
