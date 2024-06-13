#!/bin/bash

# just a viasual separation in the log
echo "-------------------------------"
echo "--- Started the $0 script. ---"

# Check if a filename is provided as the first argument
if [ -z "$1" ]; then
  # Print usage message with an extended comment
  echo "Usage: $0 <filename>"
  echo "No list of IUs provided provided."
  exit 1
else
  ROOTS_TO_REMOVE_FILE=$(realpath "$1")
fi

# Check if the file exists
if [ ! -f "$ROOTS_TO_REMOVE_FILE" ]; then
  echo "Error: File '$ROOTS_TO_REMOVE_FILE' not found."
  exit 1
fi

FAILCOUNT=0
for iuroot in $(cat $ROOTS_TO_REMOVE_FILE); do
# get rid of whitespace bs  
  iuroot="$(echo $iuroot)"

  echo "removing IU root: $iuroot ..."
  ../S32DS.3.5/eclipse/eclipsec.exe \
    -application org.eclipse.equinox.p2.director \
    -uninstallIU "$iuroot" \
    -consolelog -noSplash

  if [[ $? -ne 0 ]]; then
    echo " - FAILED to remove $iuroot"
    ((FAILCOUNT+=1))
  else
    echo " - REMOVED $iuroot"
  fi
done
# just a viasual separation in the log
echo "-------------------------------"
if [[ $FAILCOUNT -ne 0 ]]; then
  echo "--- ERRORs detected - exit 1 ---"
  exit 1
fi
echo "--- SUCCESS: all packages removed - exit 0 ---"
exit 0