# NammaYatri AWS S3 Setup Script for Windows PowerShell
# This script helps configure AWS credentials for S3

param(
    [Parameter(Mandatory=$false)]
    [string]$AccessKeyId = $null,
    
    [Parameter(Mandatory=$false)]
    [string]$SecretAccessKey = $null,
    
    [Parameter(Mandatory=$false)]
    [string]$BucketName = "nammayatri-dev",
    
    [Parameter(Mandatory=$false)]
    [string]$Region = "us-east-1"
)

Write-Host "================================" -ForegroundColor Cyan
Write-Host "NammaYatri AWS S3 Configuration" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if AWS CLI is installed
Write-Host "Checking AWS CLI installation..." -ForegroundColor Yellow
try {
    $awsVersion = aws --version
    Write-Host "✓ AWS CLI found: $awsVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ AWS CLI not found. Please install it first:" -ForegroundColor Red
    Write-Host "  https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
}

Write-Host ""

# Get credentials interactively if not provided
if (-not $AccessKeyId) {
    Write-Host "Enter your AWS credentials:" -ForegroundColor Yellow
    $AccessKeyId = Read-Host "AWS Access Key ID"
}

if (-not $SecretAccessKey) {
    Write-Host "AWS Secret Access Key (will be hidden):" -ForegroundColor Yellow
    $SecretAccessKey = Read-Host -AsSecureString
    $SecretAccessKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($SecretAccessKey)
    )
}

Write-Host ""
Write-Host "Setting environment variables..." -ForegroundColor Yellow

# Set environment variables for current session
$env:AWS_ACCESS_KEY_ID = $AccessKeyId
$env:AWS_SECRET_ACCESS_KEY = $SecretAccessKey
$env:AWS_DEFAULT_REGION = $Region
$env:AWS_S3_BUCKET = $BucketName
$env:AWS_S3_REGION = $Region

Write-Host "✓ Environment variables set for current session" -ForegroundColor Green

Write-Host ""
Write-Host "Testing AWS credentials..." -ForegroundColor Yellow

# Test credentials
try {
    $caller = aws sts get-caller-identity --region $Region | ConvertFrom-Json
    Write-Host "✓ Credentials are valid!" -ForegroundColor Green
    Write-Host "  Account: $($caller.Account)" -ForegroundColor Cyan
    Write-Host "  User ARN: $($caller.Arn)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Credentials test failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Checking S3 bucket access..." -ForegroundColor Yellow

# Test S3 access
try {
    $buckets = aws s3 ls
    if ($buckets | Select-String $BucketName) {
        Write-Host "✓ S3 bucket '$BucketName' found and accessible!" -ForegroundColor Green
    } else {
        Write-Host "⚠ Bucket '$BucketName' not found. Creating..." -ForegroundColor Yellow
        aws s3 mb "s3://$BucketName" --region $Region
        Write-Host "✓ Bucket created!" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ S3 access failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Setup Summary ===" -ForegroundColor Green
Write-Host "✓ AWS Access Key ID: $($AccessKeyId.Substring(0, 4))..." -ForegroundColor Cyan
Write-Host "✓ AWS Region: $Region" -ForegroundColor Cyan
Write-Host "✓ S3 Bucket: $BucketName" -ForegroundColor Cyan
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Copy credentials to .env.local file:"
Write-Host "   Copy-Item Backend\.env.local.example Backend\.env.local"
Write-Host ""
Write-Host "2. Edit Backend\.env.local with your credentials"
Write-Host ""
Write-Host "3. Load environment for future sessions:"
Write-Host "   . Backend\aws-setup.ps1"
Write-Host ""
Write-Host "4. Verify S3 access:"
Write-Host "   aws s3 ls"
Write-Host ""

# Optionally save to .env.local
$saveToFile = Read-Host "Save credentials to Backend\.env.local? (y/n)"
if ($saveToFile -eq "y" -or $saveToFile -eq "Y") {
    $envContent = @"
# NammaYatri AWS S3 Configuration
# AUTO-GENERATED - DO NOT COMMIT TO GIT!

AWS_ACCESS_KEY_ID="$AccessKeyId"
AWS_SECRET_ACCESS_KEY="$SecretAccessKey"
AWS_DEFAULT_REGION="$Region"
AWS_S3_BUCKET="$BucketName"
AWS_S3_REGION="$Region"
AWS_S3_PATH_PREFIX=""

# Add to .gitignore
"@
    
    Set-Content -Path "Backend\.env.local" -Value $envContent
    Write-Host "✓ Credentials saved to Backend\.env.local" -ForegroundColor Green
    Write-Host "⚠ IMPORTANT: Add 'Backend\.env.local' to .gitignore" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Setup complete! ✓" -ForegroundColor Green
