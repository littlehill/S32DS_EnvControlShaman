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

# Functions to handle package actions
install_packages() {
    print_list "Install packages" "$VERBOSE" "${install_list[@]}"
}

keep_packages() {
    print_list "Keep packages" "$VERBOSE" "${keep_list[@]}"
}

update_packages() {
    print_list "Update packages" "$VERBOSE" "${update_list[@]}"
}

remove_packages() {
    print_list "Remove packages" "$VERBOSE" "${remove_list[@]}"
}

if $VERBOSE; then echo "Processing DONE."; fi
# Print summary
print_list "Keep packages" "$VERBOSE" "${keep_list[@]}"
print_list "Update packages" "$VERBOSE" "${update_list[@]}"
print_list "Remove packages" "$VERBOSE" "${remove_list[@]}"
print_list "Install packages" "$VERBOSE" "${install_list[@]}"


if ! ${INSTALL_FLAG}; then
  # if we do not install, just exit here
  echo "INSTALL_FLAG not set, exiting 0;"
  exit 0
fi

#TODO: create the list of available repos and their destination
    #TODO: on VERBOSE print the list

#TODO: create 'sanity check instllable' function/script which can process the update and install list
    #big on verbose too


        #TODO: on VERBOSE print which packages are being skipped

#TODO: run UPDATE packages - possibly with verify-only

#TODO: run REMOVE packages - possibly with verify-only

#TODO: run INSTALL packages - possibly with verify-only

#report results

#untils the script is complete, exit with error
exit 127