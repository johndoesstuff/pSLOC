#!/bin/bash

output="pSLOC.txt"
exclude_patterns=()

# get options
while getopts ":o:e:h" opt; do
    case $opt in
        o)
            output="$OPTARG"
            ;;
        e)
            exclude_patterns+=("$OPTARG")
            ;;
        h)
            echo "Usage: pSLOC [-o output_file] [-e exclude_pattern] ..."
            echo "  -o   Output file (default: $output)"
            echo "  -e   Exclude files/directories matching pattern"
            echo "  -h   Show help message"
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

# make sure file doesnt already exist
if [[ -e "$output" ]]; then
    echo "Error: Output file '$output' already exists."
    exit 1
fi

# default exclusions
find_excludes=(
    # exclude self
    ! -name "$(basename "$output")"
    ! -path "./$output"
    # exclude hidden
    ! -path "*/.*"
    # exclude builds
    ! -path "*\/build\/*"
    ! -path "*\/release\/*"
    ! -path "*\/node_modules\/*"
    ! -path "*\/dist\/*"
    ! -path "*\/target\/*"
    ! -path "*\/bin\/*"
    ! -path "*\/lib\/*"
    # misc
    ! -name '*Zone.Identifier*'
    ! -name 'Cargo.lock'
    ! -name 'Cargo.toml'
    ! -name '*.svg'
)

# add custom exclusions
for pat in "${exclude_patterns[@]}"; do
    find_excludes+=(! -path "*$pat*")
done

# search for non-binary files
# optimizes only for first 4096 bytes to avoid parsing entire file
echo "Searching for files..."
files=$(find . -type f "${find_excludes[@]}" \
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
