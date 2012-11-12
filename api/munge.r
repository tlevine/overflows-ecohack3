#!/usr/bin/env Rscript

library(ggplot2)
library(plyr)

o <- read.csv('overflow_dates.csv')
o$datetime <- strptime(o$start_date, format = '%m/%d/%Y') + 3600 * o$hour
o$hour <- NULL
o$start_date <- NULL
o$after.9.am <- as.numeric(strftime(o$datetime, '%H')) > 9
o$overflow <- o$overflow == 'yes'


precip <- read.csv('../munge-tom/precip.csv')
overflow <- join(o, precip)

model <- glm(overflow ~ after.9.am + precipm, data = overflow, family = binomial)
summary(model)



# What's a good threshold?
table(overflow$precipi > 0.2, overflow$overflow, dnn = c('Precip over threshold', 'Sewer overflow'))

thresholds <- (1:100)/10
threshold.performance <- adply(thresholds, 1, function(threshold){
  results <- c(
    correctly_report = nrow(subset(overflow, precipm > threshold & overflow)),
    correctly_avoid_reporting = nrow(subset(overflow, precipm <= threshold & !overflow)),
    accidental_report = nrow(subset(overflow, precipm > threshold & !overflow)),
    missed_report = nrow(subset(overflow, precipm <= threshold & overflow))
  )
  data.frame(
    result = names(results),
    hours = results
  )
})
colnames(threshold.performance)[1] <- 'threshold'
threshold.performance$threshold <- thresholds

p0 <- ggplot(overflow) + aes(x = precipm, color = overflow) + geom_histogram() + facet_grid(after.9.am ~ .)

p1 <- ggplot(subset(overflow, after.9.am)) +
  aes(x = precipm, color = overflow) + geom_histogram()

p2 <- ggplot(subset(overflow, !after.9.am)) +
  scale_y_reverse() +
  aes(x = precipm, color = overflow) + geom_histogram()

p3 <- ggplot(overflow) + aes(x = precipm, fill = overflow) +
  geom_dotplot(binwidth = 1, stackgroups = T, binpositions = 'all')

p4 <- ggplot(threshold.performance) + aes(x = threshold, y = hours, group = result) + geom_line()


png('../figures/threshold.identification.png', width = 1600, height = 900)
print(p3)
dev.off()

png('../figures/threshold.performance.png', width = 1600, height = 900)
print(p4)
dev.off()
