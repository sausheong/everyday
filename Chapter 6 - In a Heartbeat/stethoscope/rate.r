library(outliers)

heartbeat <- c()
period = seq(from=50, to=400, by=25)


for (p in period) {
  print(paste("** for period more than ",p))
data <- read.csv(file='heartbeat7.csv', header=TRUE)
ar <- data[data$combined > p,]
r <- as.numeric(rownames(ar))

beats <- unique(round(r/1000))
print(beats)
freq <- c()
i <- 1
while (i < length(beats)) {
  freq <- append(freq, beats[i+1] - beats[i])
  i <- i + 1
}
freq
#freq <- rm.outlier(freq)
freq <- freq[!freq<8]
print(freq)
heartbeat <- append(heartbeat, round(60/((round(mean(freq))*2)/44.1)))

}
print(heartbeat)
plot(heartbeat)
