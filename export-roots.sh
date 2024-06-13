#!/bin/bash

# Check if the filename is provided as an argument
if [ $# -ne 1 ]; then
  echo "target file not specified, using: 'list_of_roots_s32ds.tmp.txt'" 
  MAINOUTPUTFILE="list_of_roots_s32ds.tmp.txt"
else
  MAINOUTPUTFILE=$(realpath "$1")
  echo "target file for roots export: $MAINOUTPUTFILE"
fi

../S32DS.3.5/eclipse/eclipsec.exe -application org.eclipse.equinox.p2.director -listInstalledRoots -noSplash 2>/dev/null >$MAINOUTPUTFILE
RC=$?
if [ $RC -eq "0" ]; then
#remove the line which reports time at the end
  sed '/Operation completed in/d' -i $MAINOUTPUTFILE
  echo "Export DONE. File: $MAINOUTPUTFILE"
else
  echo "Encountered an error. RC: $RC"
  exit 1;
fi
exit 0
