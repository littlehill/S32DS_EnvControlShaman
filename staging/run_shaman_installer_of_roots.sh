#!/bin/bash

# Check if mandatory files are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <local> <config> [-i] [-t] [-k] [-v]"
    exit 1
fi

LOCAL_FILE=$1
CONFIG_FILE=$2
INSTALL_FLAG=false
TESTONLY_FLAG=false
CONTINUE_ON_FAIL=false
VERBOSE=false

# Parse optional arguments
shift 2
while getopts "itkv" opt; do
    case ${opt} in
        i ) INSTALL_FLAG=true ;;
        t ) TESTONLY_FLAG=true ;;
        k ) CONTINUE_ON_FAIL=true ;;
        v ) VERBOSE=true ;;
        \? ) echo "Usage: $0 <local> <config> [-i] [-k] [-v]"
             exit 1 ;;
    esac
done

# Check if files exist and have read access
if [ ! -r "$LOCAL_FILE" ] || [ ! -r "$CONFIG_FILE" ]; then
    echo "Error: Files do not exist or cannot be read."
    exit 1
fi

# Arrays to store packages
declare -A local_packages
declare -A config_packages
install_list=()
keep_list=()
update_list=()
remove_list=()

if $VERBOSE; then echo "Processing local.... $(realpath $LOCAL_FILE)"; fi
# Load local packages
while IFS=/ read -r name version; do
    #whitespace removal from the end of the version, different ends of line kept messing it up on Win
    wstrimmedversion=$(sed -e 's/\ *$//g'<<<"${version}")
    local_packages["$name"]="$wstrimmedversion"
done < "$LOCAL_FILE"

if $VERBOSE; then echo "Processing config... $(realpath $CONFIG_FILE)"; fi
# Load config packages
while IFS=/ read -r name version; do
    #whitespace removal from the end of the version, different ends of line kept messing it up on Win
    wstrimmedversion=$(sed -e 's/\ *$//g'<<<"${version}")
    config_packages["$name"]="$wstrimmedversion"
done < "$CONFIG_FILE"


if $VERBOSE; then echo "Comparing package lists..."; fi
# Determine package actions
for name in "${!config_packages[@]}"; do
    if [ -n "${local_packages[$name]}" ]; then
        if [ "${local_packages[$name]}" == "${config_packages[$name]}" ]; then
            keep_list+=("$name/${config_packages[$name]}")
        else
            update_list+=("$name/${config_packages[$name]}")
        fi
    else
        install_list+=("$name/${config_packages[$name]}")
    fi
done

for name in "${!local_packages[@]}"; do
    if [ -z "${config_packages[$name]}" ]; then
        remove_list+=("$name/${local_packages[$name]}")
    fi
done

# Function to print package lists
print_list() {
    local title=$1
    local printall=$2
    shift 2
    local list=("$@")
    echo "$title (${#list[@]})"

    if $printall; then
        for item in "${list[@]}"; do
            echo "  $item"
        done
    fi
}

find_matching_repo() {
  local search_string=$1
  local folder_path=$2

  local matched_list=$(grep "$search_string" ${folder_path}/repo_list_of_ius.* | head -n 1 | cut -d: -f 1)
  if [ -z $matched_list ]; then
    return 1;
  fi

  local matched_repo=$(grep $(basename $matched_list) ${folder_path}/repo_index_of_lists.txt | cut -d' ' -f 1)
  if [ -z $matched_repo ]; then
    return 1;
  else
    echo -n "$matched_repo "
  fi

return 0
}

# Functions to handle package actions
install_package() {
    print_list "Install packages" "$VERBOSE" "${install_list[@]}"
}

keep_package() {
    print_list "Keep packages" "$VERBOSE" "${keep_list[@]}"
}

update_package() {
    print_list "Update packages" "$VERBOSE" "${update_list[@]}"
}

remove_package() {
    print_list "Remove packages" "$VERBOSE" "${remove_list[@]}"
}

if $VERBOSE; then echo "Processing DONE."; fi
# Print summary
print_list "Keep packages" "$VERBOSE" "${keep_list[@]}"
print_list "Update packages" "$VERBOSE" "${update_list[@]}"
print_list "Remove packages" "$VERBOSE" "${remove_list[@]}"
print_list "Install packages" "$VERBOSE" "${install_list[@]}"


#create the list of available repos and their destination
#done before by "create_list_of_available_repos.sh"


# -t flag - if this is apssed, just run the check for matched repos on all update and install
declare -A update_list_repos
declare -A install_list_repos

FAILED2MATCH=0
MATCHEDCOUNTER=0

echo "check repo lists for UPDATE:"
for iuname in ${update_list[@]}; do
  update_list_repos[$iuname]=$(find_matching_repo "$iuname" "./workspace/")
  if [ $? -ne "0" ]; then
    ((FAILED2MATCH+=1))
    echo "Update FAILED to match: $iuname"
  else
    ((MATCHEDCOUNTER+=1))
  fi
done

echo "check repo lists for INSTALL:"
for iuname in ${install_list[@]}; do
  install_list_repos[$iuname]=$(find_matching_repo "$iuname" "./workspace/")
  if [ $? -ne "0" ]; then
    ((FAILED2MATCH+=1))
    echo "Install FAILED to match: $iuname"
  else
    ((MATCHEDCOUNTER+=1))
  fi
done

echo "Info: matched $MATCHEDCOUNTER IUs in total."
if [ $FAILED2MATCH -gt 0 ]; then
  echo "ERROR: FAILED to match $FAILED2MATCH IUs in total."
  exit 1
fi

for iunamekey in ${!install_list_repos[@]}; do
  if $VERBOSE; then echo "install:  =${iunamekey}=  from repo: =${install_list_repos[$iunamekey]}="; fi
done

if ! ${INSTALL_FLAG}; then
  # if we do not install, just exit here
  echo "INSTALL_FLAG not set, exiting 0;"
  exit 0
fi

#TODO: create 'sanity check instllable' function/script which can process the update and install list
    #big on verbose too


        #TODO: on VERBOSE print which packages are being skipped

#TODO: run UPDATE packages - possibly with verify-only

#TODO: run REMOVE packages - possibly with verify-only

#TODO: run INSTALL packages - possibly with verify-only

#report results

#untils the script is complete, exit with error
exit 127