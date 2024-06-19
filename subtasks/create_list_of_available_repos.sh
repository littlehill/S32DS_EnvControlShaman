#!/bin/bash

# Default values
outfile=""
infile=""
folder=""
url=""
verbose_flag=false
keep_temps_flag=false

# Temporary folder
temp_folder=$(mktemp -d)
trap "rm -rf $temp_folder" EXIT

# Help function
usage() {
  echo "Usage: $0 [-outfile <output filename>] [-url <path to the repositories in S3 bucket or on NAS>] ..."
  echo "other arguments available:"
  echo "   [-folder <path to a local folder with mirrored/extracted repos>] "
  echo "   [-infile <input the list fo repos from a local file>]"
  echo "   [-k] keep temp folders with intermediary files"
  echo "   [-v] verbose, talk more"
  echo "   [-h] help, print this"
  exit 1
}

# Check if a file exists
file_exists() {
  if [[ ! -e $1 ]]; then
    echo "File $1 does not exist"
    exit 1
  fi
}

# Parse arguments
if [[ "$#" -eq 0 ]]; then
  usage
fi

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -outfile) outfile="$2"; shift ;;
    -infile) infile="$2"; file_exists "$infile"; shift ;;
    -folder) folder="$2"; shift ;;
    -url) url="$2"; shift ;;
    -v) verbose_flag=true ;;
    -k) keep_temps_flag=true ;;
    -h) usage ;;
    *) echo "Unknown parameter passed: $1"; usage ;;
  esac
  shift
done

# Check if outfile is provided and valid
if [[ -z $outfile ]]; then
  echo "Output file not specified"
  exit 1
fi

# Create list of repos
list_of_repos=()

# Process folder argument
if [[ -n $folder ]]; then
  for dir in "$folder"*/; do
    list_of_repos+=("DIR $dir")
  done
fi


silence_on_md5sum=""
if ! $verbose_flag; then silence_on_md5sum="--quiet"; fi
# Process url argument
if [[ -n $url ]]; then
  curl -s "$url/test-download.txt" -o "$temp_folder/test-download.txt"
  curl -s "$url/list-of-repos.txt" -o "$temp_folder/list-of-repos.txt"
  curl -s "$url/checksum.md5" -o "$temp_folder/checksum.md5"

  (cd "${temp_folder}" && md5sum -c checksum.md5 ${silence_on_md5sum} )
  if [[ $? -ne 0 ]]; then
    echo "Checksum verification failed"
    exit 1
  fi

  while IFS= read -r line; do
    list_of_repos+=("URL $url/$line")
  done < "$temp_folder/list-of-repos.txt"
fi

# Verbose output
if $verbose_flag; then
  for repo in "${list_of_repos[@]}"; do
    echo "$repo"
  done
fi

echo -n "" > "$outfile";
# Write to outfile
for repo in "${list_of_repos[@]}"; do
  echo "$repo" >> "$outfile"
done

# Clean up temp folder if not keeping temps
if ! $keep_temps_flag; then
  rm -rf "$temp_folder"
fi

exit 0
