# AWS S3 Credential Errors - Resolution Guide

## Quick Diagnosis

Run this command to check your S3 setup:

```bash
aws s3 ls --debug
```

This will show you exactly what's wrong. Match your error below:

---

## Common Errors and Solutions

### ❌ Error: "Unable to locate credentials"

**Cause:** AWS credentials not found in environment variables or config files

**Solution:**

1. **Set environment variables:**
   ```bash
   # Linux/Mac
   export AWS_ACCESS_KEY_ID="your-key-id"
   export AWS_SECRET_ACCESS_KEY="your-secret-key"
   
   # Windows PowerShell
   $env:AWS_ACCESS_KEY_ID = "your-key-id"
   $env:AWS_SECRET_ACCESS_KEY = "your-secret-key"
   ```

2. **Or use .env.local file:**
   ```bash
   # Copy and fill the template
   cp Backend/.env.local.example Backend/.env.local
   
   # Edit with your credentials
   nano Backend/.env.local
   
   # Load in current session
   source Backend/.env.local  # Linux/Mac
   # OR on Windows:
   Get-Content Backend\.env.local | ForEach-Object { $_ }
   ```

3. **Or use AWS CLI configuration:**
   ```bash
   aws configure
   ```
   Then provide:
   - Access Key ID
   - Secret Access Key
   - Default region: `us-east-1`

---

### ❌ Error: "InvalidAccessKeyId" or "Invalid access key"

**Cause:** Access Key ID is incorrect, expired, or doesn't exist

**Solution:**

1. **Verify the access key is correct:**
   ```bash
   echo $AWS_ACCESS_KEY_ID  # Should show your key starting with AKIA
   ```

2. **Check if key is active in AWS Console:**
   - Go to: https://console.aws.amazon.com/iam/
   - Click **Users** → Find your user
   - Click **Security Credentials**
   - Check if the access key is **Active** (not Inactive)
   - If inactive, create a new one

3. **Generate a new access key:**
   - AWS Console → IAM → Users → Your User
   - Security Credentials → Access Keys
   - Click "Create access key"
   - Save the new key ID and secret
   - Update your `.env.local` or environment

4. **Verify credentials:**
   ```bash
   aws sts get-caller-identity
   
   # Should output:
   # {
   #     "UserId": "AIDA...",
   #     "Account": "123456789012",
   #     "Arn": "arn:aws:iam::123456789012:user/nammayatri-s3-user"
   # }
   ```

---

### ❌ Error: "The provided token is malformed or otherwise invalid"

**Cause:** Secret Access Key is incorrect or malformed

**Solution:**

1. **Verify secret key doesn't have extra characters:**
   ```bash
   echo "$AWS_SECRET_ACCESS_KEY" | wc -c
   # Should be 40+ characters
   ```

2. **Check for special characters:**
   - If your secret contains `&`, `$`, `"`, `'`, escape them:
     ```bash
     # Instead of: export AWS_SECRET_ACCESS_KEY="abc&def"
     # Use: export AWS_SECRET_ACCESS_KEY='abc&def'
     # OR: export AWS_SECRET_ACCESS_KEY="abc\&def"
     ```

3. **Re-copy the secret from AWS Console:**
   - Go to IAM → Users → Security Credentials
   - Copy the secret again (character by character)
   - Update your environment

---

### ❌ Error: "AccessDenied" or "User: arn:aws:iam::... is not authorized"

**Cause:** IAM user doesn't have S3 permissions

**Solution:**

1. **Check IAM permissions:**
   - AWS Console → IAM → Users → Your User
   - Click **Permissions** tab
   - Look for policies like "AmazonS3FullAccess"

2. **If not found, add S3 permissions:**
   - Click **Add permissions** → **Attach policies directly**
   - Search for: `AmazonS3FullAccess`
   - Check the box and click **Next**
   - Click **Attach policies**
   - **Wait 1-2 minutes** for changes to propagate

3. **Test access:**
   ```bash
   aws s3 ls
   
   # Should list your buckets
   ```

---

### ❌ Error: "NoSuchBucket" or "The specified bucket does not exist"

**Cause:** S3 bucket name is wrong or doesn't exist

**Solution:**

1. **List your buckets:**
   ```bash
   aws s3 ls
   
   # Shows all your buckets
   ```

2. **Check bucket name in environment:**
   ```bash
   echo $AWS_S3_BUCKET
   
   # Must match one of your buckets exactly
   ```

3. **Create bucket if missing:**
   ```bash
   aws s3 mb s3://nammayatri-dev --region us-east-1
   
   # Replace with your region if needed
   ```

4. **Update environment:**
   ```bash
   export AWS_S3_BUCKET="nammayatri-dev"
   export AWS_S3_REGION="us-east-1"
   ```

---

### ❌ Error: "The bucket already exists"

**Cause:** S3 bucket name is already taken (names are globally unique)

**Solution:**

1. **Choose a different bucket name:**
   ```bash
   aws s3 mb s3://nammayatri-dev-myname --region us-east-1
   
   # Use your name or organization suffix
   ```

2. **Update environment:**
   ```bash
   export AWS_S3_BUCKET="nammayatri-dev-myname"
   ```

---

### ❌ Error: "An error occurred (InvalidBucketName) with message: The specified bucket is not valid"

**Cause:** Bucket name doesn't follow S3 naming rules

**Solution:**

S3 bucket names must be:
- 3-63 characters long
- Start with lowercase letter or number
- Contain only lowercase letters, numbers, hyphens (-)
- No underscores, spaces, or uppercase letters
- No consecutive hyphens

**Valid names:**
- `nammayatri-dev`
- `namma-yatri-2025`
- `nammayatri123`

**Invalid names:**
- `nammayatri_dev` ❌ (underscore)
- `NammaYatri` ❌ (uppercase)
- `namma yatri` ❌ (space)
- `nn` ❌ (too short)

---

### ❌ Error: "RequestTimeTooSkewed"

**Cause:** Your system clock is out of sync with AWS servers

**Solution:**

1. **Sync system time:**
   ```bash
   # Linux/Mac
   sudo ntpdate -s time.nist.gov
   
   # Or use timedatectl (newer systems)
   sudo timedatectl set-ntp true
   
   # Windows
   # Settings → Time & language → Set time automatically (Enable)
   ```

2. **Verify time:**
   ```bash
   date
   # Should match current time within ±5 minutes
   ```

---

### ❌ Error: "An error occurred (SignatureDoesNotMatch) with message: The request signature we calculated does not match the signature you provided"

**Cause:** 
- Secret key has extra whitespace
- Environment variable has quotes mixed in
- Credentials were pasted with line breaks

**Solution:**

1. **Remove whitespace from credentials:**
   ```bash
   # Don't include trailing spaces or newlines
   export AWS_SECRET_ACCESS_KEY="abcd1234..."
   # NOT: export AWS_SECRET_ACCESS_KEY="abcd1234... " (with trailing space)
   ```

2. **Use single quotes for special characters:**
   ```bash
   export AWS_SECRET_ACCESS_KEY='abc&def$ghi'
   # NOT: export AWS_SECRET_ACCESS_KEY="abc&def$ghi"
   ```

3. **Re-copy credentials from AWS Console:**
   - Go to IAM → Users → Security Credentials
   - Copy each piece carefully
   - Paste and verify no extra characters

---

### ❌ Error: "Connection timeout" or "Unable to connect to endpoint"

**Cause:** 
- AWS endpoint unreachable
- Network/firewall issues
- Custom endpoint (MinIO/LocalStack) not running

**Solution:**

1. **Test AWS connectivity:**
   ```bash
   curl -I https://s3.amazonaws.com
   # Should return HTTP 200
   ```

2. **Check custom endpoint (if applicable):**
   ```bash
   # If using LocalStack
   curl http://localhost:4566
   
   # If using MinIO
   curl http://localhost:9000
   
   # Should show a response
   ```

3. **Verify AWS region:**
   ```bash
   echo $AWS_DEFAULT_REGION
   # Should be valid: us-east-1, us-west-2, eu-west-1, etc.
   ```

4. **Check firewall/proxy:**
   - Your firewall might block AWS connections
   - Try from a different network
   - Contact IT if behind corporate proxy

---

## Verification Checklist

After fixing errors, verify everything works:

```bash
# 1. Check credentials are set
echo "Access Key: $AWS_ACCESS_KEY_ID"
echo "Secret Key: ${AWS_SECRET_ACCESS_KEY:0:10}..."
echo "Region: $AWS_DEFAULT_REGION"

# 2. Verify credentials with AWS
aws sts get-caller-identity

# 3. List buckets
aws s3 ls

# 4. Test upload
echo "test" > test-file.txt
aws s3 cp test-file.txt s3://$AWS_S3_BUCKET/test-file.txt

# 5. Test download
aws s3 cp s3://$AWS_S3_BUCKET/test-file.txt test-file-download.txt

# 6. Cleanup
aws s3 rm s3://$AWS_S3_BUCKET/test-file.txt
rm test-file.txt test-file-download.txt
```

---

## Getting Help

If the error persists:

1. **Collect diagnostic info:**
   ```bash
   aws --version
   aws sts get-caller-identity --debug 2>&1 | head -50
   ```

2. **Check AWS service status:**
   - https://status.aws.amazon.com/

3. **Review AWS documentation:**
   - IAM User Guide: https://docs.aws.amazon.com/iam/
   - S3 Troubleshooting: https://docs.aws.amazon.com/s3/latest/userguide/troubleshooting.html

4. **Contact AWS Support:**
   - If you have an AWS support plan
   - Or post on AWS forums

---

## Security Reminders

⚠️ **When troubleshooting:**
- ❌ Never paste your actual Access Key ID or Secret Access Key in public places
- ❌ Don't commit credentials to git
- ✅ Use placeholder values like `AKIA...` or `abc123...` when asking for help
- ✅ Rotate credentials if you accidentally exposed them

---

## Summary Table

| Error | Cause | Check |
|-------|-------|-------|
| "Unable to locate credentials" | Missing env vars | `echo $AWS_ACCESS_KEY_ID` |
| "InvalidAccessKeyId" | Wrong access key | AWS Console IAM User |
| "malformed token" | Wrong secret key | Re-copy from Console |
| "AccessDenied" | No S3 permissions | Attach `AmazonS3FullAccess` |
| "NoSuchBucket" | Wrong bucket name | `aws s3 ls` |
| "already exists" | Name taken | Use different name |
| "InvalidBucketName" | Invalid name format | Follow S3 naming rules |
| "SignatureDoesNotMatch" | Whitespace in creds | Remove extra spaces |
| "Connection timeout" | Network issue | Check firewall, test endpoint |

