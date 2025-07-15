#!/bin/bash

# Function to print usage
usage() {
    echo "Usage: $0 -e/--eclipsebin <path> -r/--reposlist <reposlist_file> -o/--outdir <output_folder>"
    echo "  [-e/--eclipsebin] -- path to Eclipse executable"
    echo "  [-f/forcewrite] -- export new lists even if the folder is not empty"
    echo "  [-v/--verbose]"
    exit 1
}

# Check if a file exists and is readable
check_file() {
    if [[ ! -f "$1" || ! -r "$1" ]]; then
        echo "File $1 does not exist or is not readable"
        exit 1
    fi
}

# Initialize variables
SCRIPT_NAME=$(basename "$0")
verbose=0
checkonly=0
outfile=""
forcewrite="false"
ECLIPSE_EXEC=""

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -e|--eclipsebin )
            ECLIPSE_EXEC="$2"
            ;;
        -r|--reposlist)
            reposlist="$2"
            shift 2
            ;;
        -v|--verbose)
            verbose=1
            shift
            ;;
        -o|--outdir)
            outdir="$2"
            shift 2
            ;;
        -f|--forcewrite)
           forcewrite="true"
           shift 1
           ;;
        *)
            usage
            ;;
    esac
done

# Check required arguments
if [[ -z "$reposlist" || -z $outdir ]]; then
    usage
fi

if [ -z "$ECLIPSE_EXEC" ]; then
    echo "[${SCRIPT_NAME}:${LINENO}] Error: Eclipse executable path (--eclipsebin) is required."
    usage
fi

if [ ! -x "$ECLIPSE_EXEC" ]; then
    echo "[${SCRIPT_NAME}:${LINENO}] Error: '$ECLIPSE_EXEC' is not an executable file."
    exit 1
fi

# Check files
check_file "$reposlist"

outdir=$(realpath $outdir)
# Check if the folder exists
if [ -d "$outdir" ]; then
    # Check if the folder is empty
    if [ "$(ls -A $outdir)" ]; then
        echo "Warning: Folder $outdir exists and is not empty."
        if ! $forcewrite; then exit 1; fi
    fi
else
    # Attempt to create the folder
    mkdir -p "$outdir"
    # Check if the folder was created successfully
    if [ ! -d "$outdir" ]; then
        echo "Error: Folder could not be created."
        exit 1
    fi
fi
# Check if we can write to the folder
if [ ! -w "$outdir" ]; then
    echo "Error: Folder is not writable."
    exit 1
fi
echo "using folder: $outdir"

# Load reposlist into arrays
echo "loading a list of repositories.."
declare -A repos_array
while IFS= read -r line; do
    type=$(echo "$line" | awk '{print $1}')
    value=$(echo "$line" | awk '{print $2}')
    repos_array["$value"]="$type"
done < "$reposlist"

echo "exporting list of installable IUs in each repo.."
# Create array to store available IUs from repos
declare -A available_ius_from_repo
declare -A repo_file_index
totaliuscounter=0
for repo in "${!repos_array[@]}"; do
    repo_type=${repos_array[$repo]}
    
    list_of_ius_tmp=$(mktemp "$outdir/repo_list_of_ius.XXXXXXXX")
    repo_file_index["$repo"]="$list_of_ius_tmp"
    ./subtasks/get_list_of_available_ius_from_repo.sh --eclipsebin "$ECLIPSE_EXEC" --type "$repo_type" --path "$repo" --outfile "$list_of_ius_tmp" -v
    thisrepoiucount=$(cat $list_of_ius_tmp | wc -l)
    ((totaliuscounter = totaliuscounter + thisrepoiucount))
done

OUTFILE="$outdir/repo_index_of_lists.txt"
echo "exporting index of lists into $OUTFILE.."
echo -n "" >"$OUTFILE"
for recordkey in "${!repo_file_index[@]}"; do
  echo "$recordkey  ${repo_file_index[$recordkey]}" >> "$OUTFILE"
done

echo "total available_ius_from_repo loaded: ${totaliuscounter} IUs"
exit 0
