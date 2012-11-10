#!/bin/sh

rm -f precip.db
for file in greenpoint*.txt; do
  ./munge.py "$file"
done

sqlite3 precip.db < munge.sql
