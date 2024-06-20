#!/bin/bash

#./subtasks/bash_env_sanity_check.sh -v
echo "- STEP 1 --------------------------------------------------------------------"
./export-roots.sh local_list_of_roots_s32ds.tmp.txt

echo "- STEP 2 --------------------------------------------------------------------"
./subtasks/create_workspace_lists_of_installable_units.sh -r "$1" -o ./workspace

echo "- STEP 3 --------------------------------------------------------------------"
./run_shaman_installer_of_roots.sh ./local_list_of_roots_s32ds.tmp.txt ./config_roots_K3xx.txt -i

# sorry that it has to run through the dependencies again, the order of installation is not yet figured out fully
# but it doe snot take that much time more and fixes it for this instance
echo "- STEP 4 --------------------------------------------------------------------"
./export-roots.sh local_list_of_roots_s32ds.tmp.txt
./run_shaman_installer_of_roots.sh ./local_list_of_roots_s32ds.tmp.txt ./config_roots_K3xx.txt -i

echo "- STEP 5 --------------------------------------------------------------------"
./export-roots.sh local_list_of_roots_s32ds.tmp.txt
./run_shaman_installer_of_roots.sh ./local_list_of_roots_s32ds.tmp.txt ./config_roots_K3xx.txt -i -v

echo "- S32DS Shaman DONE ---------------------------------------------------------"
exit 0
