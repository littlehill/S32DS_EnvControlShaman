#!/bin/bash

usage() {
    echo "Usage: $0 -e <eclipse_exec_path> <roots_to_remove_file>"
    echo " -e -- path to Eclipse executable (required, e.g. /c/NXP/S32DS.3.x.x/eclipse/s32ds.exe)"
    exit 1
}

###############################################################################
# Parse command-line options
###############################################################################
SCRIPT_NAME=$(basename "$0")
ECLIPSE_EXEC=""

while getopts ":e:" opt; do
    case "${opt}" in
        e )
            ECLIPSE_EXEC="${OPTARG}"
            ;;
        \? )
            usage
            ;;
    esac
done
shift $((OPTIND - 1))

if [ -z "${ECLIPSE_EXEC}" ]; then
    echo "[${SCRIPT_NAME}:${LINENO}] Error: Eclipse executable path (-e) is required."
    usage
fi

if [ ! -x "${ECLIPSE_EXEC}" ]; then
    echo "[${SCRIPT_NAME}:${LINENO}] Error: '${ECLIPSE_EXEC}' is not an executable file."
    exit 1
fi

if [ -z "$1" ]; then
    echo "[${SCRIPT_NAME}:${LINENO}] Error: No roots-to-remove file provided."
    usage
fi

ROOTS_TO_REMOVE_FILE=$(realpath "$1")

if [ ! -f "${ROOTS_TO_REMOVE_FILE}" ]; then
    echo "[${SCRIPT_NAME}:${LINENO}] Error: File '${ROOTS_TO_REMOVE_FILE}' not found."
    exit 1
fi

###############################################################################
# Main
###############################################################################
echo "-------------------------------"
echo "--- Started the $0 script. ---"

FAILCOUNT=0
while read -r iuroot; do
    # Trim surrounding whitespace
    iuroot="$(echo "$iuroot")"

    # Skip empty lines
    [ -z "$iuroot" ] && continue

    echo "Removing IU root: $iuroot ..."
    "${ECLIPSE_EXEC}" \
        -application org.eclipse.equinox.p2.director \
        -uninstallIU "$iuroot" \
        -consolelog -noSplash

    if [[ $? -ne 0 ]]; then
        echo " - FAILED to remove $iuroot"
        ((FAILCOUNT+=1))
    else
        echo " - REMOVED $iuroot"
    fi
done < "${ROOTS_TO_REMOVE_FILE}"

echo "-------------------------------"
if [[ $FAILCOUNT -ne 0 ]]; then
    echo "--- ERRORs detected - exit 1 ---"
    exit 1
fi

echo "--- SUCCESS: all packages removed - exit 0 ---"
exit 0
