#!/bin/bash

# Initialize counters and flags
CHECK_COUNTER=0
FAIL_COUNTER=0
VERBOSE=0
CONTINUE=0

# Function to print usage
usage() {
    echo "Usage: $0 [-v|--verbose] [-c|--continue]"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -c|--continue)
            CONTINUE=1
            shift
            ;;
        *)
            usage
            ;;
    esac
done

# Function to perform a check
perform_check() {
    local description=$1
    local command=$2

    ((CHECK_COUNTER++))
    if [[ $VERBOSE -eq 1 ]]; then
        echo "Check $CHECK_COUNTER: $description"
    fi

    eval $command
    if [[ $? -ne 0 ]]; then
        if [[ $VERBOSE -eq 1 ]]; then
            echo "Check $CHECK_COUNTER: ERROR"
        fi
        ((FAIL_COUNTER++))
        if [[ $CONTINUE -eq 0 ]]; then
            exit 1
        fi
    else
        if [[ $VERBOSE -eq 1 ]]; then
            echo "Check $CHECK_COUNTER: OK"
        fi
    fi
}

# Intro message if verbose
if [[ $VERBOSE -eq 1 ]]; then
    echo "Starting environment checks..."
fi

# Check if '../S32DS.3.5/eclipse/eclipsec.exe' exists
perform_check "Check if '../S32DS.3.5/eclipse/eclipsec.exe' exists" \
  "[[ -f '../S32DS.3.5/eclipse/eclipsec.exe' ]]"

# Create folder 'workspace' if it does not exist and make sure it is writable
perform_check "Create folder 'workspace' if it does not exist and make sure it is writable" \
  "mkdir -p workspace && [[ -w workspace ]]"

# Check if device can ping 8.8.8.8
perform_check "Check if device can ping 8.8.8.8" \
  "ping -n 1 8.8.8.8 > /dev/null 2>&1"

# Check if device can ping amazonaws.com
perform_check "Check if device can ping amazonaws.com" \
  "ping -n 1 amazonaws.com > /dev/null 2>&1"

# Check that list of commands is available
commands=("echo" "sed" "cat" "ls" "read" "curl" "realpath" "mktemp" "printf" "unzip" "touch" "mkdir" "git" "awk" "timeout")
for cmd in "${commands[@]}"; do
    perform_check "Check that command '$cmd' is available" "command -v $cmd > /dev/null 2>&1"
done

# Check that '../S32DS.3.5/eclipse/eclipsec.exe' exits with 0
perform_check "Check that '../S32DS.3.5/eclipse/eclipsec.exe ..p2.director -help' exits with 0" \
  "timeout -k 90 80 ../S32DS.3.5/eclipse/eclipsec.exe \
  -application org.eclipse.equinox.p2.director \
  -help -nosplash -consolelog > /dev/null 2>&1"

# Final check for failures
if [[ $FAIL_COUNTER -gt 0 ]]; then
    exit 1
else
    exit 0
fi
