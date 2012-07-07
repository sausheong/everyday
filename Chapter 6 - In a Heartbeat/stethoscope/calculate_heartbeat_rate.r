library(ggplot2)
heartbeat <- c()
period = seq(from=25, to=200, by=25)
rates <- c()


for (p in period) {
  data <- read.csv(file='heartbeat.csv', header=TRUE)
  filtered_data <- data[data$ch1 > p,]
  sounds <- as.numeric(rownames(filtered_data))
  
  beats <- unique(round(sounds/1000))
  cycles_between_beats <- c()
  count <- 1
  while (count < length(beats)) {
    cycles_between_beats <- append(cycles_between_beats, beats[count+1] - beats[count])
    count <- count + 1
  }

  cycles_between_beats <- cycles_between_beats[!cycles_between_beats<5]
  cy <- data.frame(cycles=cycles_between_beats,time=1:length(cycles_between_beats))
  png(paste("heartbeat_cycles_",p,".png",sep=""))
  print(qplot(time,cycles,data=cy))
  dev.off()
  rate <- c()
  count <- 1
  while (count < length(cycles_between_beats)) {
    rate <- append(rate, cycles_between_beats[count] + cycles_between_beats[count+1])
    count <- count + 2
  }
  rates <- append(rates, (round(mean(rate))))

}


png("heartbeat_rate.png")
f <- data.frame(table(rates))
print(qplot(rates,Freq,data=f,geom="bar"))
dev.off()

r <- as.numeric(names(sort(table(rates),decreasing=T)[1]))
print(paste("Interval between successive S1 + S2 sounds is", r*1000, "cycles"))
heartbeat <- round(60/(r/44.1))
print(paste("Heart rate is ", heartbeat, "bpm"))