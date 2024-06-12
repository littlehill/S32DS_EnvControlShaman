#!/bin/bash

echo "- START listting of all IUs available for install. -"
IU_LISTFILE=""
REPO_REFLISTFILE="./workspace/repo-file-list.index"

echo "clear index"
INDEXCOUNT=0
rm $REPO_REFLISTFILE
touch $REPO_REFLISTFILE || exit 1;


for repo in $(ls /c/NXP/__S32DS_Install-PKGSRC/NXP_repos_extracted | sed '/.zip/d'); do

  IU_LISTFILE="./workspace/${repo}-IU-list.txt"
  echo "processing repo: $repo"
  REPO_FULLPATH="file:/C:/NXP/__S32DS_Install-PKGSRC/NXP_repos_extracted/$repo"
  echo "-- listing available IUs --"
  ../S32DS.3.5/eclipse/eclipsec.exe \
    -application org.eclipse.equinox.p2.director \
    -repository $REPO_FULLPATH \
    -list -noSplash 2>/dev/null > ${IU_LISTFILE}

  echo "${REPO_FULLPATH} ${IU_LISTFILE} $INDEXCOUNT" >> $REPO_REFLISTFILE
  ((INDEXCOUNT+=1))

#remove the line which reports time at the end
  sed '/Operation completed in/d' -i ${IU_LISTFILE}
#replace '=' by '/' - '/' is used in roots list and for install, '=' only in packaged IUs
  sed -i 's/=/\//g' ${IU_LISTFILE}
  
  UNITS_TOTAL=$(cat ${IU_LISTFILE} | wc -l)
  echo "  - found: $UNITS_TOTAL IUs --"

  echo "-- DONE $repo --";
  echo "";
done

echo "- Listting of all IUs available for install: DONE -";
exit 0;
