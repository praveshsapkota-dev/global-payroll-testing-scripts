#!/bin/bash
set -euo pipefail

# Color codes
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RED="\033[31m"
RESET="\033[0m"

# Output file
OUTPUT_FILE="env.txt"

# Check arguments
if [ $# -lt 2 ]; then
    echo -e "${RED}Usage: $0 env=<env> employer_id=<employer_id>${RESET}"
    exit 1
fi

# Write env variables to file
> "$OUTPUT_FILE"
for arg in "$@"; do
    if [[ "$arg" =~ ^(env|employer_id)=.+$ ]]; then
        echo "$arg" >> "$OUTPUT_FILE"
    else
        echo -e "${RED}Invalid argument: $arg${RESET}"
        echo -e "${YELLOW}Expected env=<value> or employer_id=<value>${RESET}"
        exit 1
    fi
done

echo -e "${GREEN}Environment variables written to $OUTPUT_FILE:${RESET}"
cat "$OUTPUT_FILE"

# Recursively find all run.sh files and make them executable
echo -e "${CYAN}Setting execute permission for all run.sh files...${RESET}"
find . -type f -name "run.sh" -exec chmod +x {} \;

echo -e "${GREEN}All run.sh files are now executable.${RESET}"
