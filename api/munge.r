#!/usr/bin/env Rscript

o <- read.csv('overflow_dates.csv')
o$datetime <- strptime(o$start_date, format = '%m/%d/%Y') + 3600 * o$hour
o$hour <- NULL
o$start_date <- NULL
o$after.9.am <- as.numeric(strftime(o$datetime, '%H')) > 9
o$overflow <- o$overflow == 'yes'
