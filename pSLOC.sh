#!/bin/bash

output="${1:-all_texts.txt}"

# make sure file doesnt already exist
if [[ -e "$output" ]]; then
    echo "Error: Output file '$output' already exists."
    exit 1
fi

# search for all non-binary and non hidden files
files=$(find . \
    -type f \
    ! -name "$(basename "$output")" \
    ! -path "./$output" \
    ! -path "*/.*" \
    ! -name '*Zone.Identifier*' \
    -exec sh -c 'head -c 4096 "$1" | grep -Iq . && echo "$1"' _ {} \; \
    | sort -u)

# init output
> "$output"

# cat files to output
while IFS= read -r file; do
    echo "===== $file =====" >> "$output"
    cat "$file" >> "$output"
    echo -e "\n" >> "$output"
done <<< "$files"

# success
lines=$(wc -l < "$output")
printf "Written %d lines to %s\n" "$lines" "$output"
