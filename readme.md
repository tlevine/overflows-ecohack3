Using recent rainfall figures to predict Newtown Creek sewer overflows
===

<!-- introduction -->

## Data sources

### Overflow statistic
We received a book from a FOIA request. This book contains graphs of, among
other things, sewer overflow incidents in New York City during the top 10
storms of 2011 for each of the 14 sewage treatment plants.

> Dates of the top ten storms, in the order they are presented in the book
> 
> 8/14/2011
> 8/27/2011
> 9/6/2011
> 3/6/2011
> 4/16/2011
> 11/22/2011
> 10/29/2011
> 9/23/2011
> 5/17/2011
> 12/7/2011

For each of these 10 storms, the graphs present a 48-hour or 60-hour window
of data around the storm. For 60-hour widows, we only used the first 48-hours.
This results in a total of 7720 observation-hours, with one observation per
hour.

<!-- picture of the book and a plot from it -->

### Rainfall statistic
We collected rainfall statistics from Weather Underground. We chose this
because of the [practical applications blah blah]

### Goal
We want to predict whether a sewer will overflow soon based on current
rainfall data in order to make [DontFlush.me](http://dontflush.me)'s alerts
more relevant.

## Methods

### Data collection
We focused on the Newtown Creek sewershed. We have 480 observation-hours
(10 storms at 14 plants) in the book. We measured overflow as hours between
an NC throttle start (solid diamond) and an NC throttle end (empty diamond),
inclusive. For example, the two darkened bands on this plot, from hours t1
to t2, indicate overflow periods.

<!-- picture with dots -->

For each of these hours, we also acquired
the most recent observation from Weather Underground. This resulted in a table
that looked like this.

    Date  Hour  Overflowing?  Last rainfall figure
    ----  ----  ------------  --------------------
                Yes

### Model
We used the following model (in R formula syntax).

    overflowing ~ Last rainfall figure + hour of the day


