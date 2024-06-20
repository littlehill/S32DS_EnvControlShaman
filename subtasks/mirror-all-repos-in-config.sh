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

    if [ ! -d /c/NXP/__S32DS_Install-PKGSRC/NXP_repos_mirrored/$string1 ]; then
    # Print the strings ussage
      echo "RUN: ./mirror-repository.sh $string2 $string1"
      ./mirror-repository.sh "$string2" "$string1"
      if [[ $? -ne 0 ]]; then
        echo "ERROR"
        exit 1
      fi
    else
      echo "SKIP $string1 -- repostiry already exists"
    fi

    # Print the separator line
    echo "--------------------"
done < "$filename"
