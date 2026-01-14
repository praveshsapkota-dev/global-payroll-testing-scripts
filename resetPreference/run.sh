#!/bin/bash
set -e
source ../env.txt

# Silence output by redirecting stdout and stderr to /dev/null
{
    aws dynamodb update-item \
      --table-name "payroll-$env" \
      --key "{\"PK\":{\"S\":\"org#$employer_id\"},\"SK\":{\"S\":\"payroll_prefs\"}}" \
      --update-expression "SET active_payroll_count = :val1, last_payroll_date = :val2" \
      --expression-attribute-values '{
            ":val1":{"N":"0"},
            ":val2":{"S":""}  
      }'
} >/dev/null 2>&1
