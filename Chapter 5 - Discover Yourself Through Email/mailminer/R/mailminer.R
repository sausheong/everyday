times_count <- function(times,element) {
  times <-  as.vector(as.matrix(times))
  elements <- strftime(strptime(times, format="%Y-%m-%dT%H:%M:%S"), element)
  data.frame(table(elements))$Freq
}

dates_count <- function(dates,element) {
  dates <- as.Date(as.vector(as.matrix(dates)),"%Y-%m-%dT%H:%M:%S")
  elements <- format(dates, element)
  data.frame(table(elements))$Freq  
}