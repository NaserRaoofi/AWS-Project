#!/bin/bash

STACK_NAME="s3-buckets"
TEMPLATE_FILE="../templates/s3_bucket.yaml"
PARAMETERS_FILE="../parameters/s3_buckets_params.json"

echo "🚀 Deploying CloudFormation stack: $STACK_NAME"

aws cloudformation deploy \
    --stack-name "$STACK_NAME" \
    --template-file "$TEMPLATE_FILE" \
    --parameter-overrides $(jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' "$PARAMETERS_FILE") \
    --capabilities CAPABILITY_NAMED_IAM

# Check if deployment was successful
if [ $? -eq 0 ]; then
    echo "✅ Deployment complete for stack: $STACK_NAME"
else
    echo "❌ Deployment failed for stack: $STACK_NAME"
    exit 1
fi
