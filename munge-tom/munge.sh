#!/bin/sh
set -e

rm -f precip.db
for file in ../weather-data/greenpoint*.txt; do
  ./munge.py "$file"
done
./hourly.py

sqlite3 precip.db < munge.sql
