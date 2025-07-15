#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Export the list of installed Eclipse p2 roots from S32DS.
#
# Usage:
#   ./export_s32ds_roots.sh [output_file]
#
# Requirements:
#   • The environment variable SHAMAN_ECLIPSE_BIN_PATH must point to the
#     S32DS "eclipse" executable (typically something like "C:/NXP/S32DS.3.5/eclipse/<main s32ds>.exe" on Windows)
# -----------------------------------------------------------------------------
set -euo pipefail

if [[ -z "${SHAMAN_ECLIPSE_BIN_PATH:-}" ]]; then
  echo "ERROR: The environment variable SHAMAN_ECLIPSE_BIN_PATH is not set." >&2
  echo "       Please export SHAMAN_ECLIPSE_BIN_PATH pointing at the main S32DS eclipse executable." >&2
  exit 1
fi

ECLIPSE_BIN_PATH=$(realpath ${SHAMAN_ECLIPSE_BIN_PATH})

if [[ ! -f "${ECLIPSE_BIN_PATH}" ]]; then
  echo "ERROR: The file '${ECLIPSE_BIN_PATH}' does not exist." >&2
  exit 1
fi

if ! timeout -k 90 80 "${ECLIPSE_BIN_PATH}" \
    -application org.eclipse.equinox.p2.director \
    -help -nosplash -consolelog > /dev/null 2>&1; then
  echo "ERROR: '${ECLIPSE_BIN_PATH}' failed to execute. Ensure it is a valid S32DS eclipse executable." >&2
  exit 1
fi

# output file
if [[ $# -eq 1 ]]; then
  MAINOUTPUTFILE=$(realpath "$1")
  echo "Target file for roots export: ${MAINOUTPUTFILE}"
else
  MAINOUTPUTFILE="list_of_roots_s32ds.tmp.txt"
  echo "Target file not specified, using default: '${MAINOUTPUTFILE}'"
fi

# Run export
"${ECLIPSE_BIN_PATH}" -application org.eclipse.equinox.p2.director \
  -listInstalledRoots -noSplash 2>/dev/null > "${MAINOUTPUTFILE}"
RC=$?

if [[ ${RC} -eq 0 ]]; then
  # Remove the summary timing line appended by p2.director
  sed -i '/Operation completed in/d' "${MAINOUTPUTFILE}"
  echo "Export DONE. File: ${MAINOUTPUTFILE}"
else
  echo "Encountered an error. RC: ${RC}" >&2
  exit 1
fi

exit 0
