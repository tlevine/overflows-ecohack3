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

import sys
dt = DumpTruck(dbname = 'precip.db')	
foo(sys.argv[1], dt)