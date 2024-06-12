#!/bin/bash
MAINOUTPUTFILE="config_roots_K3xx.txt"

../S32DS.3.5/eclipse/eclipsec.exe -application org.eclipse.equinox.p2.director -listInstalledRoots -noSplash 2>/dev/null >$MAINOUTPUTFILE
RC=$?
if [ $RC -eq "0" ]; then
  echo "Export DONE. File: $MAINOUTPUTFILE"
else
  echo "Encountered an error. RC: $RC"
  exit 1;
fi

#remove the line which reports time at the end
sed '/Operation completed in/d' -i config_roots_K3xx.txt

exit 0
