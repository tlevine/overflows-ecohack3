#!/usr/bin/env Rscript

o <- read.csv('overflow_dates.csv')
o$datetime <- strptime(o$start_date, format = '%m/%d/%Y') + 3600 * o$hour
o$hour <- NULL
o$start_date <- NULL
o$after.9.am <- as.numeric(strftime(o$datetime, '%H')) > 9
o$overflow <- o$overflow == 'yes'

library(plyr)

precip <- read.csv('../munge-tom/precip.csv')
overflow <- join(o, precip)

summary(glm(overflow ~ after.9.am + precipm, data = overflow, family = binomial))

p0 <- ggplot(overflow) + aes(x = precipm, color = overflow) + geom_histogram() + facet_grid(after.9.am ~ .)

p1 <- ggplot(subset(overflow, after.9.am)) +
  aes(x = precipm, color = overflow) + geom_histogram()

p2 <- ggplot(subset(overflow, !after.9.am)) +
  scale_y_reverse() +
  aes(x = precipm, color = overflow) + geom_histogram()

p3 <- ggplot(overflow) + aes(x = precipm, fill = overflow) +
  geom_dotplot(binwidth = 1, stackgroups = T, binpositions = 'all')

#print(p1)
#print(p2)
#print(p)
print(p3)
