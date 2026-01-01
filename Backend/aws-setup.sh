#!/bin/bash

# NammaYatri AWS S3 Setup Script for Linux/Mac
# This script helps configure AWS credentials for S3

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
BUCKET_NAME="${1:-nammayatri-dev}"
REGION="${2:-us-east-1}"
ENV_FILE="Backend/.env.local"

echo -e "${CYAN}================================${NC}"
echo -e "${CYAN}NammaYatri AWS S3 Configuration${NC}"
echo -e "${CYAN}================================${NC}"
echo ""

# Check if AWS CLI is installed
echo -e "${YELLOW}Checking AWS CLI installation...${NC}"
if ! command -v aws &> /dev/null; then
    echo -e "${RED}✗ AWS CLI not found. Please install it first:${NC}"
    echo "  https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

aws_version=$(aws --version)
echo -e "${GREEN}✓ AWS CLI found: $aws_version${NC}"
echo ""

# Get credentials
echo -e "${YELLOW}Enter your AWS credentials:${NC}"
read -p "AWS Access Key ID: " AWS_ACCESS_KEY_ID
read -sp "AWS Secret Access Key (hidden): " AWS_SECRET_ACCESS_KEY
echo ""
read -p "S3 Bucket name [${BUCKET_NAME}]: " BUCKET_INPUT
BUCKET_NAME="${BUCKET_INPUT:-$BUCKET_NAME}"
read -p "AWS Region [${REGION}]: " REGION_INPUT
REGION="${REGION_INPUT:-$REGION}"

echo ""
echo -e "${YELLOW}Setting environment variables...${NC}"

# Set environment variables
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION="$REGION"
export AWS_S3_BUCKET="$BUCKET_NAME"
export AWS_S3_REGION="$REGION"

echo -e "${GREEN}✓ Environment variables set for current session${NC}"

echo ""
echo -e "${YELLOW}Testing AWS credentials...${NC}"

# Test credentials
if aws sts get-caller-identity --region "$REGION" > /dev/null 2>&1; then
    CALLER_INFO=$(aws sts get-caller-identity --region "$REGION")
    ACCOUNT=$(echo "$CALLER_INFO" | grep -o '"Account": "[^"]*' | cut -d'"' -f4)
    ARN=$(echo "$CALLER_INFO" | grep -o '"Arn": "[^"]*' | cut -d'"' -f4)
    
    echo -e "${GREEN}✓ Credentials are valid!${NC}"
    echo -e "${CYAN}  Account: $ACCOUNT${NC}"
    echo -e "${CYAN}  User ARN: $ARN${NC}"
else
    echo -e "${RED}✗ Credentials test failed${NC}"
    echo "Please verify your Access Key ID and Secret Access Key"
    exit 1
fi

echo ""
echo -e "${YELLOW}Checking S3 bucket access...${NC}"

# Test S3 access
if aws s3 ls --region "$REGION" | grep -q "$BUCKET_NAME"; then
    echo -e "${GREEN}✓ S3 bucket '$BUCKET_NAME' found and accessible!${NC}"
elif aws s3 mb "s3://$BUCKET_NAME" --region "$REGION" 2>/dev/null; then
    echo -e "${GREEN}✓ S3 bucket created: $BUCKET_NAME${NC}"
else
    echo -e "${YELLOW}⚠ Could not access or create bucket '$BUCKET_NAME'${NC}"
    echo "This might be due to:"
    echo "  - Bucket name already exists (S3 names are globally unique)"
    echo "  - Insufficient IAM permissions"
    echo "  - Network issues"
fi

echo ""
echo -e "${GREEN}=== Setup Summary ===${NC}"
echo -e "${CYAN}✓ AWS Access Key ID: ${AWS_ACCESS_KEY_ID:0:4}...${NC}"
echo -e "${CYAN}✓ AWS Region: $REGION${NC}"
echo -e "${CYAN}✓ S3 Bucket: $BUCKET_NAME${NC}"
echo ""

# Save to .env.local
read -p "Save credentials to $ENV_FILE? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    cat > "$ENV_FILE" << EOF
# NammaYatri AWS S3 Configuration
# AUTO-GENERATED - DO NOT COMMIT TO GIT!

export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="$REGION"
export AWS_S3_BUCKET="$BUCKET_NAME"
export AWS_S3_REGION="$REGION"
export AWS_S3_PATH_PREFIX=""

# To load: source Backend/.env.local
EOF
    
    # Secure file permissions
    chmod 600 "$ENV_FILE"
    
    echo -e "${GREEN}✓ Credentials saved to $ENV_FILE${NC}"
    echo -e "${YELLOW}⚠ IMPORTANT: Add '$ENV_FILE' to .gitignore${NC}"
    echo ""
    echo "Add this line to .gitignore:"
    echo "  echo 'Backend/.env.local' >> .gitignore"
fi

echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Load environment variables:"
echo "   source Backend/.env.local"
echo ""
echo "2. Verify S3 access:"
echo "   aws s3 ls --region $REGION"
echo ""
echo "3. Test file upload:"
echo "   echo 'test' > test.txt"
echo "   aws s3 cp test.txt s3://$BUCKET_NAME/ --region $REGION"
echo ""
echo -e "${GREEN}Setup complete! ✓${NC}"
