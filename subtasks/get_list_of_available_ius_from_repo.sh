#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 --type TYPE --path PATH --outfile OUTFILE [-v|--verbose]"
  exit 1
}

# Check for minimum number of arguments
if [ "$#" -lt 6 ]; then
  usage
fi

# Parse arguments
VERBOSE=0
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --type)
      TYPE="$2"
      shift
      ;;
    --path)
      INPUT_PATH="$2"
      shift
      ;;
    --outfile)
      OUTFILE="$2"
      shift
      ;;
    -v|--verbose)
      VERBOSE=1
      ;;
    *)
      usage
      ;;
  esac
  shift
done

# Check for mandatory arguments
if [ -z "$TYPE" ] || [ -z "$INPUT_PATH" ] || [ -z "$OUTFILE" ]; then
  usage
fi

# Handle the path based on type
if [ "$TYPE" == "URL" ]; then
  REPO_PATH="$INPUT_PATH"
  if [ $VERBOSE -eq 1 ]; then echo "path set to URL"; fi
elif [ "$TYPE" == "DIR" ]; then
  if [ $VERBOSE -eq 1 ]; then echo "path set to DIR"; fi
  if [ ! -d "$INPUT_PATH" ]; then
    echo "Directory $INPUT_PATH does not exist."
    exit 1
  fi
  REPO_PATH="file:${INPUT_PATH//\/c\//\/C:/}"
else
  echo "Invalid type: $TYPE. Must be 'URL' or 'DIR'."
  exit 1
fi

if [ $VERBOSE -eq 1 ]; then echo "runnning p2.director on $REPO_PATH.."; fi
# Run the command to list IUs
IU_LIST=$(../S32DS.3.5/eclipse/eclipsec.exe \
  -application org.eclipse.equinox.p2.director \
  -repository "$REPO_PATH" \
  -list -noSplash 2>/dev/null)
# Check if the command succeeded
if [ $? -ne 0 ]; then
  echo "Error executing eclipsec.exe."
  exit 1
fi

# Remove the line which reports time at the end
IU_LIST=$(echo "$IU_LIST" | sed '/Operation completed in/d')

# Check if the IU_LIST is empty
if [ -z "$IU_LIST" ]; then
  echo "No IUs found or eclipsec.exe failed to list IUs."
  exit 1
fi

# convert ot an array
# todo: validate the IUs syntax
VALID_IU_LIST=()
for IUSTR in $(echo "$IU_LIST"); do
  #replace the '=' version separator by '/'
  IUSTR="${IUSTR//=/\/}"
  VALID_IU_LIST+=("$IUSTR")
done

IU_COUNT=${#VALID_IU_LIST[@]}
echo "Found $IU_COUNT IUs."

# Output to file
printf "%s\n" "${VALID_IU_LIST[@]}" > "$OUTFILE"

exit 0
