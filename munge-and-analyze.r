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

set.seed(234234)
training.cutoff <- round(nrow(overflow) * 3 / 4)
i <- sample(nrow(overflow))
overflow.training <- overflow[i[1:(training.cutoff - 1)],]
overflow.test <- overflow[i[training.cutoff:nrow(overflow)],]
model.training <- glm(overflow ~ after.9.am * precipi, data = overflow.training, family = binomial)

# When the Y value is zero, the likelihoods of overflowing and of not
# overflowing are the same.
table(overflow.test$overflow, round(predict(model.training, overflow.test, type = 'response'))) 
table(overflow.test$overflow, (predict(model.training, overflow.test) > 0))
print('The model is decent.')

# What's a good threshold?
print('This is a good threshold for precipitation rate before 9 am. Pay attention to the units.')
print(- (coef(model)[1] / coef(model)[3]))

print('This is a good threshold for precipitation rate after 9 am. Pay attention to the units.')
print(- (coef(model)[1] + coef(model)[2]) / coef(model)[4])

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

go <- function(){
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

overflow.sorted <- overflow[order(overflow$overflow),]
stripchart(overflow$precipi ~ overflow$after.9.am, method='stack', pch = 22, bg = overflow$overflow + 1, vertical = T, col = 0)
stripchart(overflow.sorted$precipi ~ overflow.sorted$after.9.am, method='stack', pch = 22, bg = overflow.sorted$overflow + 1, vertical = T, col = 0)
stripchart(overflow.sorted$precipi ~ overflow.sorted$after.9.am + overflow.sorted$overflow,
  method='stack', pch = 22, bg = 1, vertical = T,
  main = 'Sewer overflows in relation to time of day and precipitation rate',
  ylab = 'Precipitation rate (inches)',
  xlab = '', axes = F)
axis(2)
axis(1, at = 1:4, labels = c('Before 9 am, no overflow', 'After 9 am, no overflow', 'Before 9 am, overflow', 'After 9 am, overflow'))
}


library(reshape2)
overflow$precip.factor <- factor(round(overflow$precipi, 1))
overflow.for.graph <- melt(ddply(na.omit(overflow), 'precip.factor', function(df) {
  data.frame(
    no.overflow.before = sum(!df$overflow & !df$after.9.am),
    overflow.before = sum(df$overflow & !df$after.9.am),
    no.overflow.after = sum(!df$overflow & df$after.9.am),
    overflow.after = sum(df$overflow & df$after.9.am)
  )
}), 'precip.factor')
levels(overflow.for.graph$variable) <- c('Before 9 am, no overflow', 'Before 9 am, overflow', 'After 9 am, no overflow', 'After 9 am, overflow')
colnames(overflow.for.graph)[2] <- 'Scenario'
ordering <- c(
  'Before 9 am, overflow',
  'After 9 am, overflow',
  'Before 9 am, no overflow',
  'After 9 am, no overflow'
)

# Why doesn't this work for geom_area ????
overflow.for.graph$Scenario <- factor(overflow.for.graph$Scenario, levels = ordering)
# Oh, maybe it's the data frame ordering
overflow.for.graph <- overflow.for.graph[order(overflow.for.graph$Scenario),]
# Ah, yes! That did it.

overflow.for.graph$precip.factor <- as.numeric(as.character(overflow.for.graph$precip.factor))

p8 <- ggplot(overflow.for.graph) + aes(x = precip.factor, y = value, group = Scenario, fill = Scenario) +
  geom_area(position = 'stack') +
  scale_x_continuous('Precipitation rate (inches)', breaks = (0:20)/10) +
  scale_y_continuous('Number of occurrences (hours)') +
  labs(title = 'Newtown Creek precipitation rates and severflows by hour during New York City\'s top 10 storms of 2011')



png('figures/area.png', width = 1600, height = 900)
print(p8)
# text(2, 0.1, 'Note the lack of overflow during these early-morning hours of high precipitation (the blue band).')
dev.off()
