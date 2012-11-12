#!/bin/sh
set -e

echo Building the website with pictures
mkdir -p web

cat readme.md | markdown > tmp/index.html

(
  cd figures
  for fig in 2012* *.png; do
    convert -geometry 900 "$fig" "../tmp/$fig" 
  done
)
