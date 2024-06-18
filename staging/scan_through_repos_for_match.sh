#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 -b BASEPATH"
  exit 1
}

# Check if basepath is provided
while getopts "b:" opt; do
  case $opt in
    b) BASEPATH="$OPTARG" ;;
    *) usage ;;
  esac
done

# Validate basepath
if [[ -z "$BASEPATH" || ! -d "$BASEPATH" ]]; then
  echo "Basepath is not provided or does not exist."
  exit 1
fi

# Function to get the list of packages
get_me_the_repo_list_of_packages() {
  local repo_path="$1"
  local output_file="$2"
  # Simulate fetching package list
  # This should be replaced with the actual implementation
  echo "package1/1.0" > "$output_file"
  echo "package2/2.0" >> "$output_file"
}

# Initialize the 2D array
declare -A package_repo_array

# Process each repository
for repo in "$BASEPATH"/*; do
  if [[ -d "$repo" ]]; then
    repo_name=$(basename "$repo")
    output_file="/tmp/${repo_name}_packages.txt"
    get_me_the_repo_list_of_packages "$repo" "$output_file"
    
    while IFS= read -r line; do
      package_repo_array["$line"]+="$repo_name "
    done < "$output_file"
  fi
done

# Print the list of packages and repositories
for package in "${!package_repo_array[@]}"; do
  repos=${package_repo_array["$package"]}
  repo_count=$(echo "$repos" | wc -w)
  echo "For package $package, there are $repo_count repos providing:"
  for repo in $repos; do
    echo "    $repo"
  done
done
