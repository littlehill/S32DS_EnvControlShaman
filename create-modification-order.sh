#!/bin/bash

# Function to print usage
usage() {
    echo "Usage: $0 -l <local_file> -c <desired_config_file> [-i <install_output_file>] [-r <remove_output_file>]"
    exit 1
}

# Parse arguments
install_output_file="autointstall-roots-list.tmp.txt"
remove_output_file="autoremove-roots-list.tmp.txt"

while getopts ":l:c:i:r:" opt; do
    case ${opt} in
        l ) 
            local_file=$OPTARG
            ;;
        c )
            config_file=$OPTARG
            ;;
        i )
            install_output_file=$OPTARG
            ;;
        r )
            remove_output_file=$OPTARG
            ;;
        \? )
            usage
            ;;
    esac
done

shift $((OPTIND -1))

# Check if required arguments are provided
if [ -z "${local_file}" ] || [ -z "${config_file}" ]; then
    usage
fi

# Ensure the input files exist
if [ ! -f "${local_file}" ]; then
    echo "Local file ${local_file} does not exist."
    exit 1
fi

if [ ! -f "${config_file}" ]; then
    echo "Desired config file ${config_file} does not exist."
    exit 1
fi

# Read the local and desired config files into arrays
mapfile -t local_packages < "${local_file}"
mapfile -t config_packages < "${config_file}"

# Convert arrays to associative arrays for fast lookup
declare -A local_map
declare -A config_map

for pkg in "${local_packages[@]}"; do
    local_map["$pkg"]=1
done

for pkg in "${config_packages[@]}"; do
    config_map["$pkg"]=1
done

# Initialize counters
install_count=0
remove_count=0

# Generate the install and remove lists
> "${install_output_file}"
> "${remove_output_file}"

for pkg in "${config_packages[@]}"; do
    if [[ -z "${local_map[$pkg]}" ]]; then
        echo "$pkg" >> "${install_output_file}"
        ((install_count++))
    fi
done

for pkg in "${local_packages[@]}"; do
    if [[ -z "${config_map[$pkg]}" ]]; then
        echo "$pkg" >> "${remove_output_file}"
        ((remove_count++))
    fi
done

# Output the results
echo "Packages to install are listed in: ${install_output_file}"
echo "Number of packages to install: ${install_count}"
echo "Packages to remove are listed: in ${remove_output_file}"
echo "Number of packages to remove: ${remove_count}"

# Return appropriate exit code
if [[ ${install_count} -eq 0 && ${remove_count} -eq 0 ]]; then
    exit 0
elif [[ ${install_count} -gt 0 && ${remove_count} -eq 0 ]]; then
    exit 2
elif [[ ${install_count} -eq 0 && ${remove_count} -gt 0 ]]; then
    exit 3
else
    exit 1
fi
