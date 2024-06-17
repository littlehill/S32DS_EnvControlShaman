#!/bin/bash

# Check if mandatory files are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <local> <config> [-i] [-k] [-v]"
    exit 1
fi

LOCAL_FILE=$1
CONFIG_FILE=$2
INSTALL=false
CONTINUE_ON_FAIL=false
VERBOSE=false

# Parse optional arguments
shift 2
while getopts "ikv" opt; do
    case ${opt} in
        i ) INSTALL=true ;;
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

# Load local packages
while IFS=/ read -r name version; do
    local_packages["$name"]="$version"
done < "$LOCAL_FILE"

# Load config packages
while IFS=/ read -r name version; do
    config_packages["$name"]="$version"
done < "$CONFIG_FILE"

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

# Print summary
install_packages
keep_packages
update_packages
remove_packages

# Exit with appropriate status
exit 0
