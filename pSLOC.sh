#!/bin/bash

output="${1:-all_texts.txt}"

# make sure file doesnt already exist
if [[ -e "$output" ]]; then
    echo "Error: Output file '$output' already exists."
    exit 1
fi

> "$output"

# search for all non-binary and non hidden files
find . -type f ! -name "$(basename "$output")" -exec file {} \; | grep text | cut -d: -f1 | awk '!/\/\./' | while read -r file; do
    echo "===== $file =====" >> "$output"
    cat "$file" >> "$output"
    echo -e "\n" >> "$output"
done

