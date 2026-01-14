#!/bin/bash
set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# Load environment variables
source ../env.txt
log_info "Environment loaded: $env"

amplify_env="$env"
EMPLOYER_ID="$employer_id"
TABLE_NAME="payroll-$amplify_env"

# Execute resetPreferences script silently
log_info "Resetting preferences for employer_id $EMPLOYER_ID..."
../resetPreference/run.sh
log_success "Preferences reset completed."

# Query older draft payrolls
log_info "Querying older draft payrolls in table $TABLE_NAME..."
items=$(aws dynamodb query \
    --table-name "$TABLE_NAME" \
    --key-condition-expression "PK = :pk AND begins_with(SK, :skprefix)" \
    --expression-attribute-values "{\":pk\":{\"S\":\"org#$EMPLOYER_ID\"},\":skprefix\":{\"S\":\"payroll#\"}}" \
    --projection-expression "PK, SK, payroll_status" \
    --query "Items[?payroll_status.S=='DRAFT']")

# Check if there are any draft items
if [ -z "$items" ] || [ "$items" = "[]" ]; then
    log_info "No draft payrolls found. Nothing to delete."
else
    # Delete each draft payroll
    log_info "Deleting draft payrolls..."
    echo "$items" | jq -c '.[]' | while read item; do
        PK=$(echo "$item" | jq -r '.PK.S')
        SK=$(echo "$item" | jq -r '.SK.S')

        log_warn "Deleting PK=$PK, SK=$SK..."
        aws dynamodb delete-item \
            --table-name "$TABLE_NAME" \
            --key "{\"PK\":{\"S\":\"$PK\"},\"SK\":{\"S\":\"$SK\"}}"
        log_success "Deleted PK=$PK, SK=$SK"
    done
fi

# Invoke Lambda to create a new payroll
log_info "Invoking Lambda function to create new payroll..."
aws lambda invoke \
  --function-name createPayroll-"$amplify_env" \
  --cli-binary-format raw-in-base64-out \
  --payload file://create_payroll.json \
  response.json >/dev/null

log_success "Lambda invoked successfully. Payroll creation triggered."
