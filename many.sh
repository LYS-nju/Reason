#!/bin/bash

# FILE_LIST="sol_name/smartbugs_curated.txt"
# FILE_LIST="sol_name/Code4rena.txt"
FILE_LIST="sol_name/CVE.txt"

count=0

while IFS= read -r line; do
    count=$((count + 1))

    echo "The $count Line: $line"
	
    python src/run_files.py "$line"
    # python src/study_gpt.py
    # python src/study_deepseek.py
    python src/detect_deepseek.py

done < "$FILE_LIST"