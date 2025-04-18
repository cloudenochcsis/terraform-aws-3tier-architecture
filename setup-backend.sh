#!/bin/bash

# Variables
BUCKET_NAME="cloudenochcsis-terraform-state"
REGION="us-east-1"
AWS_PROFILE="DevOps-Admin"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Setting up Terraform backend infrastructure..."

# Create S3 bucket
if aws s3api head-bucket --bucket "$BUCKET_NAME" --profile "$AWS_PROFILE" 2>/dev/null; then
    echo -e "${GREEN}Bucket $BUCKET_NAME already exists${NC}"
else
    echo "Creating S3 bucket..."
    if aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$REGION" \
        --profile "$AWS_PROFILE"; then
        echo -e "${GREEN}Successfully created S3 bucket${NC}"
    else
        echo -e "${RED}Failed to create S3 bucket${NC}"
        exit 1
    fi
fi

# Enable versioning
echo "Enabling versioning on S3 bucket..."
if aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled \
    --profile "$AWS_PROFILE"; then
    echo -e "${GREEN}Successfully enabled versioning${NC}"
else
    echo -e "${RED}Failed to enable versioning${NC}"
    exit 1
fi

# Enable encryption
echo "Enabling default encryption on S3 bucket..."
if aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration \
    '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}' \
    --profile "$AWS_PROFILE"; then
    echo -e "${GREEN}Successfully enabled encryption${NC}"
else
    echo -e "${RED}Failed to enable encryption${NC}"
    exit 1
fi

echo -e "${GREEN}Backend infrastructure setup complete!${NC}"
echo "You can now initialize Terraform with:"
echo "terraform init"
