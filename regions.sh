#!/bin/sh

get_guardduty_regions() {
  aws ssm get-parameters-by-path \
    --path /aws/service/global-infrastructure/services/guardduty/regions \
    --query 'Parameters[].Value'
}

aws ec2 describe-regions | \
  jq \
    --sort-keys \
    --from-file regions.jq \
    --argjson regions "$(get_guardduty_regions)" \
    --arg prefix 'region_' \
    --arg source './region'

