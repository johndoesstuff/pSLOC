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
    ! -path "*\/build\/*" \
    ! -path "*\/release\/*" \
    ! -path "*\/node_modules\/*" \
    ! -path "*\/dist\/*" \
    ! -path "*\/target\/*" \
    ! -path "*\/bin\/*" \
    ! -path "*\/lib\/*" \
    ! -name '*Zone.Identifier*' \
    ! -name 'Cargo.lock' \
    ! -name 'Cargo.toml' \
    ! -name '*.svg' \
    -exec sh -c 'head -c 4096 "$1" | grep -Iq . && echo "$1"' _ {} \; \
    | sort -u)

# init output
> "$output"

# hide cursor
tput civis

# how many files?
total=$(echo "$files" | wc -l)
count=0

printf "Found %d files...\n" "$total"

# progress bar
draw_progress() {
    local progress=$1
    local total=$2
    local width=40
    local filled=$(( progress * width / total ))
    local empty=$(( width - filled ))
    printf "\r["
    printf "%-${filled}s" "" | tr ' ' '#'
    printf "%-${empty}s" "" | tr ' ' '-'
    printf "] %d/%d" "$progress" "$total"
}

# cat files to output
while IFS= read -r file; do
    echo "===== $file =====" >> "$output"
    cat "$file" >> "$output"
    echo -e "\n" >> "$output"
    count=$((count + 1))
    draw_progress $count $total
done <<< "$files"

# newline after progress
echo

# success
lines=$(wc -l < "$output")
printf "Written %d lines to %s\n" "$lines" "$output"

# show cursor
tput cnorm
