#!/bin/bash

rm -f ../tables/latexnums.Rda

python3 01_zenodo_pull.py

for arg in $(ls [0-9]*.R)
do
R CMD BATCH ${arg} 
done

tail *.Rout
