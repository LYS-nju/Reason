#!/bin/bash

FILE_LIST="sol_name/samrtbugs_curated.txt"

count=0

while IFS= read -r line; do
    count=$((count + 1))

    echo "The $count Line: $line"
	
    python src/run_files.py "$line"
    python src/detect_ac_4o.py

done < "$FILE_LIST"