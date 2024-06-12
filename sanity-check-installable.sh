#!/bin/bash

echo "- START -"
ROOTS_LISTFILE="config_roots_K3xx.txt"
REPO_REFLISTFILE="./workspace/repo-file-list.index"

INSTALLABLE_ORDER_FILE="./workspace/installable-list-of-IUs.order"
rm $INSTALLABLE_ORDER_FILE
touch $INSTALLABLE_ORDER_FILE

echo "config_roots file: ${ROOTS_LISTFILE}"
# print lines of file with sed and keep spaces and new lines...
# UNIT_LIST_INLINE=$(awk '{printf "%s ", $0}' ${IU_LISTFILE} | sed 's/=/\//g')

COUNTER_SATISFIABLE=0
COUNTER_FAILED2MATCH=0

#check if we can find repo for each IU root
for root in $(cat $ROOTS_LISTFILE); do
  
  MATCHED_FILES=$(grep -E -R -n $root ./workspace/*.txt | cut -d: -f 1)

  if [ -z "$MATCHED_FILES" ]; then
    echo "FAILED to MATCH: $root"
    ((COUNTER_FAILED2MATCH+=1))
  else
    echo "for $root matched files:"
    echo "$MATCHED_FILES"
    MATCHED_FILES_ARRAY=($MATCHED_FILES)
    echo "item #1: ${MATCHED_FILES_ARRAY[0]}"

    MATCHED_REPO=$(grep ${MATCHED_FILES_ARRAY[0]} $REPO_REFLISTFILE | cut -d' ' -f 1)
    echo "for $root found repository:"
    echo "  $MATCHED_REPO"
    ((COUNTER_SATISFIABLE+=1))
  fi
  
  echo "-- root resolved";
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
