#!/bin/bash

# Check if the filename is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

filename=$1

# Read each line from the file
while IFS= read -r line; do
    # Split the line into two strings
    string1=$(echo "$line" | cut -d' ' -f1)
    string2=$(echo "$line" | cut -d' ' -f2-)

    # Print the strings with the specified prefixes
    echo "first arg: $string1"
    echo "second arg: $string2"

    # Print the separator line
    echo "--------------------"

done < "$filename"
