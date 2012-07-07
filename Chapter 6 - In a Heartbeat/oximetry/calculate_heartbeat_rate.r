library(PROcess)
library(ggplot2)

data <- read.csv(file='data.csv', header=T)

png("heartbeat_rate.png")
qplot(data=data, frame, intensity, geom="line")


# find the peak intensities
peaks <- peaks(data$intensity,span=10)
peak_times <- which(peaks==T, arr.in=T)

# find the intervals between the peaks
intervals <- c()
i <- 1
while (i < length(peak_times)) {
  intervals <- append(intervals, peak_times[i+1] - peak_times[i])
  i <- i + 1
}

# find the mode interval
mode <- as.numeric(names(sort(table(intervals), decreasing=T)[1]))
print(paste("Mode interval between peak intensities is", mode))

# movie frame rate is 30 fps
heartbeat_rate <- round(60 * (30/mode))
print(paste("Heartbeat rate is",heartbeat_rate))

dev.off()