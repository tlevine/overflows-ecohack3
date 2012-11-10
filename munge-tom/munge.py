#!/usr/bin/env python

import json
import datetime
from dumptruck import DumpTruck

def foo(url, dt):
	d = json.loads(open(url).read())
	observations = d['history']['observations']
	for observation in observations:
		data = simplify_observation(observation)
		dt.insert(data, 'precip')

def simplify_observation(observation):
	time = datetime.datetime.strptime(
		observation['date']['pretty'],
		'%I:%M %p %Z on %B %d, %Y'
	)
	return {
		'datetime': time,
		'precipi': observation['precipi'],
		'precipm': observation['precipm'],
	}

def hourly(dt):
    thedate = datetime.datetime(2011, 1, 1)
    for hour in range(356 * 24):
        thedate = thedate + datetime.timedelta(hours=1)
        stringdate = thedate.strftime('%Y-%m-%d %H')
        rowlist = dt.execute("select precipm, precipi from precip where precipi >= 0 and datetime < '%s' order by datetime desc limit 1;" % stringdate)
        if len(rowlist) == 0:
            continue

        row = rowlist[0]
        row['datetime'] = thedate
        dt.insert(row, 'hourly')

if __name__ == '__main__':
    import sys
    dt = DumpTruck(dbname = 'precip.db')	
    foo(sys.argv[1], dt)
