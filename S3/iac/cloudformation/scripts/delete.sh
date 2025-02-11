#!/bin/bash

STACK_NAME="demo-sirvan-v1"

echo "⚠️ Deleting CloudFormation stack: $STACK_NAME..."
aws cloudformation delete-stack --stack-name $STACK_NAME

echo "⏳ Waiting for deletion..."
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME

echo "✅ Stack deleted successfully!"
