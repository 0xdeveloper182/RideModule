# 🚀 AWS S3 Quick Start for NammaYatri

**Time Required:** ~10 minutes  
**Difficulty:** Easy  
**Prerequisites:** AWS account, AWS CLI installed

---

## Step-by-Step Setup (Choose Your OS)

### 🪟 Windows Users

1. **Open PowerShell as Administrator**
   ```powershell
   # Navigate to project root
   cd f:\nammayatri-main
   
   # Run the setup script
   .\Backend\aws-setup.ps1
   ```

2. **Follow the prompts:**
   - Enter your AWS Access Key ID
   - Enter your AWS Secret Access Key
   - Confirm bucket name: `nammayatri-dev`
   - Confirm region: `us-east-1`

3. **Choose to save to .env.local?** → Press `y`

4. **Done!** ✅ Environment is configured

---

### 🐧 Linux/Mac Users

1. **Open Terminal**
   ```bash
   cd ~/nammayatri-main
   chmod +x Backend/aws-setup.sh
   ./Backend/aws-setup.sh
   ```

2. **Follow the prompts:**
   - Enter your AWS Access Key ID
   - Enter your AWS Secret Access Key
   - Confirm bucket name: `nammayatri-dev`
   - Confirm region: `us-east-1`

3. **Choose to save to .env.local?** → Press `y`

4. **Load environment:**
   ```bash
   source Backend/.env.local
   ```

5. **Done!** ✅ Environment is configured

---

## Manual Setup (If Scripts Don't Work)

### 1. Create IAM User

```bash
# Using AWS CLI
aws iam create-user --user-name nammayatri-s3-user
aws iam attach-user-policy --user-name nammayatri-s3-user --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam create-access-key --user-name nammayatri-s3-user
```

Or manually in AWS Console:
- Go to: https://console.aws.amazon.com/iam/
- Create user → Create access key → Save credentials

### 2. Create S3 Bucket

```bash
aws s3 mb s3://nammayatri-dev --region us-east-1
```

Or manually in AWS Console:
- Go to: https://console.aws.amazon.com/s3/
- Create bucket → Name: `nammayatri-dev`

### 3. Set Environment Variables

**Option A: Using .env.local file**

```bash
# Copy template
cp Backend/.env.local.example Backend/.env.local

# Edit with your credentials (use your favorite editor)
# Windows: notepad Backend\.env.local
# Mac/Linux: nano Backend/.env.local

# Add your credentials:
AWS_ACCESS_KEY_ID="your-access-key-id"
AWS_SECRET_ACCESS_KEY="your-secret-access-key"
AWS_DEFAULT_REGION="us-east-1"
AWS_S3_BUCKET="nammayatri-dev"
AWS_S3_REGION="us-east-1"

# Save and load (Linux/Mac)
source Backend/.env.local

# Or Windows PowerShell
Get-Content Backend\.env.local | ForEach-Object { Invoke-Expression $_ }
```

**Option B: Using System Environment Variables**

```bash
# Linux/Mac
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_S3_BUCKET="nammayatri-dev"
export AWS_S3_REGION="us-east-1"

# Windows PowerShell
$env:AWS_ACCESS_KEY_ID = "your-access-key-id"
$env:AWS_SECRET_ACCESS_KEY = "your-secret-access-key"
$env:AWS_DEFAULT_REGION = "us-east-1"
$env:AWS_S3_BUCKET = "nammayatri-dev"
$env:AWS_S3_REGION = "us-east-1"
```

**Option C: Using AWS CLI**

```bash
aws configure
# Enter credentials when prompted
```

### 4. Verify Setup

```bash
# Test credentials
aws sts get-caller-identity

# Should output:
# {
#     "UserId": "AIDA...",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/nammayatri-s3-user"
# }

# Test S3 access
aws s3 ls

# Should show:
# 2025-12-09 10:30:00 nammayatri-dev

# Test file upload
echo "test" > test.txt
aws s3 cp test.txt s3://nammayatri-dev/test.txt
aws s3 rm s3://nammayatri-dev/test.txt
```

---

## Update Dhall Configuration

Edit: `Backend/dhall-configs/dev/secrets/common.dhall`

**Replace the mock S3 config:**

```dhall
# OLD (REMOVE)
let mockS3Config1 =
      { baseLocalDirectory = "./s3/local"
      , bucketName = "test-bucket"
      , pathPrefix = ""
      }

let mockS3Config = globalCommon.S3Config.S3MockConf mockS3Config1

# NEW (ADD)
let awsS3Config1 =
      { accessKeyId = env:AWS_ACCESS_KEY_ID as Text
      , secretAccessKey = env:AWS_SECRET_ACCESS_KEY as Text
      , bucketName = env:AWS_S3_BUCKET as Text ? "nammayatri-dev"
      , region = env:AWS_S3_REGION as Text ? "us-east-1"
      , pathPrefix = env:AWS_S3_PATH_PREFIX as Text ? ""
      }

let awsS3Config = globalCommon.S3Config.S3AwsConf awsS3Config1

# THEN UPDATE THE OUTPUT
in  { smsUserName = "xxxxxxx"
    , smsPassword = "yyyyyyy"
    , s3Config = awsS3Config              # ← Changed from mockS3Config
    , s3PublicConfig = awsS3Config        # ← Changed from mockS3Config
    , googleKey = topSecret.googleKey
    , googleTranslateKey = topSecret.googleTranslateKey
    , slackToken = "xxxxxxx"
    , InfoBIPConfig
    , urlShortnerApiKey = "some-internal-api-key"
    , nammayatriRegistryApiKey = "some-secret-api-key"
    }
```

---

## Verify Everything Works

```bash
# 1. Load environment
source Backend/.env.local  # Linux/Mac

# 2. Start your application
# (follow your normal startup process)

# 3. Check logs for S3 connection success
# Should see: "S3 connection successful" or similar

# 4. Test S3 operations in your app
# Try uploading/downloading files through the UI
```

---

## Common Issues & Quick Fixes

| Issue | Fix |
|-------|-----|
| "Unable to locate credentials" | Run `source Backend/.env.local` |
| "InvalidAccessKeyId" | Verify access key in AWS Console |
| "AccessDenied" | Attach S3 permissions to IAM user |
| "NoSuchBucket" | Create bucket: `aws s3 mb s3://nammayatri-dev` |
| Credentials in wrong region | Set `AWS_S3_REGION="us-east-1"` |

**Detailed troubleshooting:** See `Backend/S3-CREDENTIAL-ERRORS.md`

---

## Security Checklist

- [ ] Credentials saved in `.env.local`
- [ ] `.env.local` added to `.gitignore`
- [ ] IAM user has S3 permissions only (not admin)
- [ ] Access key is active in AWS Console
- [ ] System clock is in sync (`date` command)
- [ ] Credentials not shared with anyone

---

## Environment Variables Reference

| Variable | Required | Example |
|----------|----------|---------|
| `AWS_ACCESS_KEY_ID` | ✅ | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | ✅ | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_DEFAULT_REGION` | ✅ | `us-east-1` |
| `AWS_S3_BUCKET` | ✅ | `nammayatri-dev` |
| `AWS_S3_REGION` | ✅ | `us-east-1` |
| `AWS_S3_PATH_PREFIX` | ❌ | `uploads/` |
| `AWS_S3_ENDPOINT` | ❌ | `http://localhost:4566` |

---

## Next Steps

1. ✅ Complete setup above
2. ✅ Verify with `aws s3 ls`
3. 📚 Read full guide: `Backend/dhall-configs/dev/secrets/aws-s3-setup.md`
4. 🔧 Troubleshoot: `Backend/S3-CREDENTIAL-ERRORS.md`
5. 🚀 Start developing!

---

## Need Help?

**Setup Script Issues:**
- Windows: Run PowerShell as Administrator
- Linux/Mac: Make script executable: `chmod +x Backend/aws-setup.sh`

**Credential Errors:**
- Check: `Backend/S3-CREDENTIAL-ERRORS.md`
- Run: `aws sts get-caller-identity --debug`

**AWS Console:**
- IAM: https://console.aws.amazon.com/iam/
- S3: https://console.aws.amazon.com/s3/

---

**You're all set!** 🎉

Your NammaYatri project now has AWS S3 credentials configured and ready to use.
