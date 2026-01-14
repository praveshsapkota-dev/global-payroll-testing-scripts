#!/bin/bash
set -euo pipefail  # safer: exit on unset variables, errors, and failed pipes

# Load environment variables
source ../env.txt

# Validate required variables
: "${env:?env is not set. Please set env before running this script}"
: "${employer_id:?employer_id is not set. Please set employer_id before running this script}"

amplify_env="$env"
echo -e "\033[32mCurrent ENVIRONMENT: $amplify_env\033[0m"
echo -e "\033[32mGenerating Outbound event...\033[0m"

export EMPLOYER_ID="$employer_id"
echo -e "\033[32mEmployer ID: ${EMPLOYER_ID}\033[0m"

# Generate event JSON with envsubst and compact it using jq
EVENT_JSON="$(envsubst < outbound_event.template.json | jq -c .)"
echo "---------------------"
echo -e "\033[36mPayload:\033[0m $EVENT_JSON"
echo "---------------------"

# Invoke Lambda, decode logs, and extract console URL
set +e  # temporarily disable exit-on-error to capture Lambda failures
CONSOLE_URL=$(aws lambda invoke \
  --function-name payrolls-"$amplify_env" \
  --cli-binary-format raw-in-base64-out \
  --payload "$EVENT_JSON" \
  --log-type Tail /dev/stdout \
  | jq -r '.LogResult' \
  | base64 --decode \
  | grep -o 'https://[^ ]*console\.aws\.amazon\.com[^ ]*')
STATUS=$?
set -e

echo -e "\033[32mLambda invoke exit status: $STATUS\033[0m"

if [[ -n "$CONSOLE_URL" ]]; then
    echo -e "\033[32m----- Console URL -----\033[0m"
    echo "$CONSOLE_URL"
    echo -e "\033[32m----------------------\033[0m"
else
    echo -e "\033[31mConsole URL not found in Lambda logs.\033[0m"
fi
