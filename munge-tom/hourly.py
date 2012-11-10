#!/usr/bin/env python

from dumptruck import DumpTruck
from munge import hourly

dt = DumpTruck(dbname = 'precip.db')	
hourly(dt)
