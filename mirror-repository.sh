#!/bin/bash

REPO_LINK=$1
DEST_DIRNAME=$2

mkdir -p ls /c/NXP/__S32DS_Install-PKGSRC/NXP_repos_mirrored/$DEST_DIRNAME
ls /c/NXP/__S32DS_Install-PKGSRC/NXP_repos_mirrored/$DEST_DIRNAME || exit 1;

echo "- Mirror a repository '$REPO_LINK' into";
echo " s folder: C:/NXP/__S32DS_Install-PKGSRC/NXP_repos_mirrored/$DEST_DIRNAME"; 

../S32DS.3.5/eclipse/eclipsec.exe -verbose -noSplash -consoleLog  \
   -application org.eclipse.equinox.p2.metadata.repository.mirrorApplication \
   -source $REPO_LINK \
   -destination /C:/NXP/__S32DS_Install-PKGSRC/NXP_repos_mirrored/$DEST_DIRNAME
 # TODO: add optional switch for   '-writeMode clean -raw'
if [ $? -eq 0 ]; then
  echo "- Mirror of metadata in '$REPO_LINK' DONE -";
else
  echo "- FAILED to mirror of metadata in '$REPO_LINK' -";
  exit 1;
fi

echo "- Mirroring of artifacts in '$REPO_LINK' started -";
../S32DS.3.5/eclipse/eclipsec.exe -verbose -noSplash -consoleLog  \
   -application org.eclipse.equinox.p2.artifact.repository.mirrorApplication \
   -source $REPO_LINK \
   -destination /C:/NXP/__S32DS_Install-PKGSRC/NXP_repos_mirrored/$DEST_DIRNAME
 # TODO: add optional switch for   '-writeMode clean -raw'

if [ $? -eq 0 ]; then
  echo "- Mirror of artifacts in '$REPO_LINK' DONE -";

  #TODO: extract the artifact and content jar
  #TODO: autocreate the p2.index header
  pushd /c/NXP/__S32DS_Install-PKGSRC/NXP_repos_mirrored/$DEST_DIRNAME
  echo "unpacking xml from content.jar & artifacts.jar"
  unzip content.jar
  unzip artifacts.jar
  echo "creating p2.index..."
  touch "p2.index"
  echo "# manual mirror of $REPO_LINK with Shaman - $(date)" > p2.index
  echo $'artifact.repository.factory.order=artifacts.xml.xz,artifacts.xml,\\!' \
       $'\nversion=1' \
       $'\nmetadata.repository.factory.order=content.xml.xz,content.xml,\\!' \
       >> p2.index
  popd
  echo "- Metadata setup in /C:/NXP/__S32DS_Install-PKGSRC/NXP_repos_mirrored/$DEST_DIRNAME DONE -";
else 
  echo "- FAILED to mirror of artifacts in '$REPO_LINK' -";
  exit 1
fi
echo " - Mirrorring COMPLETE -"
exit 0;