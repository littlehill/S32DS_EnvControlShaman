#!/bin/bash

# Check if a filename is provided as the first argument
if [ -z "$1" ]; then
  # Print usage message with an extended comment
  echo "Usage: $0 <filename>"
  echo "No filename provided. Using default value 'config_roots_K3xx.txt'."
  ROOTS_LISTFILE="config_roots_K3xx.txt"
else
  ROOTS_LISTFILE="$1"
fi

# Check if the file exists
if [ ! -f "$ROOTS_LISTFILE" ]; then
  echo "Error: File '$ROOTS_LISTFILE' does not exist."
  exit 1
fi

echo "- START -"
REPO_REFLISTFILE="./workspace/repo-file-list.index"
# Check if the file exists
if [ ! -f "$REPO_REFLISTFILE" ]; then
  echo "Error: File '$REPO_REFLISTFILE' does not exist."
  exit 1
fi

INSTALLABLE_ORDER_FILE="./workspace/installable-list-of-IUs.order"
rm $INSTALLABLE_ORDER_FILE
touch $INSTALLABLE_ORDER_FILE

echo "config_roots file: ${ROOTS_LISTFILE}"
# print lines of file with sed and keep spaces and new lines...
# UNIT_LIST_INLINE=$(awk '{printf "%s ", $0}' ${IU_LISTFILE} | sed 's/=/\//g')

COUNTER_SATISFIABLE=0
COUNTER_FAILED2MATCH=0

#check if we can find repo for each IU root
for iuroot in $(cat $ROOTS_LISTFILE); do
# get rid of whitespace bs  
  iuroot="$(echo $iuroot)"

  MATCHED_FILE=$(grep -R -n "$iuroot" ./workspace/*.txt | head -1 | cut -d: -f 1);

  if [ -z "$MATCHED_FILE" ]; then
    echo "FAILED to MATCH: $iuroot";
    ((COUNTER_FAILED2MATCH+=1))
    echo "--";
  else
    echo "for $iuroot matched file: $MATCHED_FILE"
    echo "LOG all avalable repos:"
    grep -R -n "$iuroot" ./workspace/*.txt
    echo "--"
    MATCHED_REPO=$(grep ${MATCHED_FILE} $REPO_REFLISTFILE | cut -d' ' -f 1)
    echo "for $iuroot found repository:"
    echo "  $MATCHED_REPO"
    ((COUNTER_SATISFIABLE+=1))
    echo "-- root resolved";
  fi
  
done
echo "--------------------------------------------------"
echo "-- Install sanity check DONE --";
if [ $COUNTER_FAILED2MATCH -ne 0 ]; then
  echo " * FAILED to match $COUNTER_FAILED2MATCH roots --"
  echo " * Requests to match passed for $COUNTER_SATISFIABLE roots --"
  exit 1;
else
  echo " * SUCCESS in matching all $COUNTER_SATISFIABLE roots --"
fi;
exit 0;
