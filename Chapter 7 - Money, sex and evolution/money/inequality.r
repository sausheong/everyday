library(ineq)
data <- read.table("money.csv", header=F, sep=",")
points = c(1,5,15,30,50,75,100,125,150,200,300,500)
 pdf("inequality.pdf")
par(mfrow=c(4,3))
for (i in 1:12) {
  p <- Lc(as.vector(as.matrix(data[points[i],])))
  ie <- ineq(data[points[i],])
  plot(p, main=paste("t =", points[i], "/ Gini = ", round(ie, 3)), font.main=1)
}
dev.off()
