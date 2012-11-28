#!/usr/bin/env Rscript

library(ggplot2)
library(plyr)

o <- read.csv('api/overflow_dates.csv')
o$datetime <- strptime(o$start_date, format = '%m/%d/%Y') + 3600 * o$hour
o$hour <- NULL
o$start_date <- NULL
o$after.9.am <- as.numeric(strftime(o$datetime, '%H')) > 9
o$overflow <- o$overflow == 'yes'


precip <- read.csv('munge-tom/precip.csv')
overflow <- join(o, precip)

model <- glm(overflow ~ after.9.am * precipm, data = overflow, family = binomial)
summary(model)
print('This model suggests that overflows only only occur after 9 am.')

training.cutoff <- round(nrow(overflow) * 3 / 4)
i <- sample(nrow(overflow))
overflow.training <- overflow[i[1:(training.cutoff - 1)],]
overflow.test <- overflow[i[training.cutoff:nrow(overflow)],]
model.training <- glm(overflow ~ after.9.am * precipm, data = overflow.training, family = binomial)

# When the Y value is zero, the likelihoods of overflowing and of not
# overflowing are the same.
table(overflow.test$overflow, round(predict(model.training, overflow.test, type = 'response'))) 
table(overflow.test$overflow, (predict(model.training, overflow.test) > 0))
print('The model is decent.')

# What's a good threshold?
print('This is a good threshold for precipitation rate. Pay attention to the units.')
print(- (coef(model.training)[1] + coef(model.training)[2]) / coef(model.training)[4])
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

p5 <- ggplot(subset(overflow, after.9.am)) + aes(x = precipm, fill = overflow) +
  geom_dotplot(binwidth = 1, stackgroups = T, binpositions = 'all')

# Change '0' to something else based on that other model I ran
# threshold.performance$precipm.adj <- threshold.performance$precipm + 0 * threshold.performance$after.9.am

pdf('figures/threshold.identification.pdf', width = 16, height = 9)
print(p3)
dev.off()

png('figures/threshold.identification.png', width = 1600, height = 900)
print(p3)
dev.off()

# This one's awesome!
png('figures/threshold.identification-after.9.am.png', width = 1600, height = 900)
print(p5)
dev.off()

png('figures/threshold.performance.png', width = 1600, height = 900)
print(p4)
dev.off()
