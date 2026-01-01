# 🎯 AWS S3 Credential Setup - Complete Guide Index

**Project:** NammaYatri  
**Created:** December 9, 2025  
**Status:** ✅ Ready to Use  

---

## 📍 Start Here

### First Time Setup (10 minutes)
👉 **Start with:** [`AWS-S3-QUICKSTART.md`](./AWS-S3-QUICKSTART.md)
- Quick overview
- Platform-specific scripts
- Manual setup option
- Verification steps

### Got an Error?
👉 **Check:** [`Backend/S3-CREDENTIAL-ERRORS.md`](./Backend/S3-CREDENTIAL-ERRORS.md)
- Common errors and solutions
- Troubleshooting steps
- Verification checklist

### Need Detailed Setup?
👉 **Read:** [`Backend/dhall-configs/dev/secrets/aws-s3-setup.md`](./Backend/dhall-configs/dev/secrets/aws-s3-setup.md)
- Step-by-step IAM setup
- S3 bucket creation
- Security best practices
- Environment variable configuration

---

## 📚 All Documentation

### Quick Reference
| Document | Purpose | Read Time |
|----------|---------|-----------|
| `AWS-S3-QUICKSTART.md` | Quick start guide | 5 min |
| `AWS-S3-SETUP-SUMMARY.md` | Overview & checklist | 3 min |

### Detailed Guides
| Document | Purpose | Read Time |
|----------|---------|-----------|
| `Backend/dhall-configs/dev/secrets/aws-s3-setup.md` | Complete setup guide | 15 min |
| `Backend/S3-CREDENTIAL-ERRORS.md` | Error troubleshooting | As needed |
| `Backend/S3-DHALL-EXAMPLES.md` | Configuration examples | 10 min |

### Helper Files
| Document | Purpose |
|----------|---------|
| `gitignore-aws-s3-additions.txt` | .gitignore additions |
| `Backend/.env.local.example` | Environment template |

---

## 🔧 Setup Scripts

### Windows Users
```powershell
cd f:\nammayatri-main
.\Backend\aws-setup.ps1
```

### Linux/Mac Users
```bash
cd ~/nammayatri-main
chmod +x Backend/aws-setup.sh
./Backend/aws-setup.sh
```

---

## 🚀 Quick Setup Steps

1. **Create AWS Account** (if not done)
   - Go to: https://aws.amazon.com
   - Sign up and verify

2. **Create IAM User**
   - AWS Console → IAM → Users → Create User
   - Attach: `AmazonS3FullAccess` policy
   - Generate Access Key ID and Secret

3. **Create S3 Bucket**
   - AWS Console → S3 → Create Bucket
   - Name: `nammayatri-dev` (or preferred name)
   - Region: `us-east-1` (or your region)

4. **Run Setup Script**
   - Windows: `.\Backend\aws-setup.ps1`
   - Linux/Mac: `./Backend/aws-setup.sh`
   - Or manually create `.env.local`

5. **Test Connection**
   ```bash
   aws sts get-caller-identity
   aws s3 ls
   ```

6. **Update Dhall Config**
   - Edit: `Backend/dhall-configs/dev/secrets/common.dhall`
   - Replace mock S3 config with AWS S3 config
   - See: `Backend/S3-DHALL-EXAMPLES.md`

7. **Start Developing!**
   ```bash
   source Backend/.env.local  # Load credentials
   # Start your application
   ```

---

## 📋 File Structure

```
nammayatri-main/
├── AWS-S3-QUICKSTART.md           # ← START HERE
├── AWS-S3-SETUP-SUMMARY.md        # Overview & checklist
├── gitignore-aws-s3-additions.txt # Add to .gitignore
├── Backend/
│   ├── aws-setup.ps1              # Windows setup script
│   ├── aws-setup.sh               # Linux/Mac setup script
│   ├── .env.local.example         # Environment template
│   ├── S3-CREDENTIAL-ERRORS.md    # Troubleshooting guide
│   ├── S3-DHALL-EXAMPLES.md       # Configuration examples
│   └── dhall-configs/
│       └── dev/
│           └── secrets/
│               ├── common.dhall        # ← Update this file
│               └── aws-s3-setup.md     # Detailed setup guide
```

---

## 🔑 Environment Variables Needed

```bash
AWS_ACCESS_KEY_ID="AKIA..."              # From IAM user
AWS_SECRET_ACCESS_KEY="..."              # From IAM user (keep secret!)
AWS_DEFAULT_REGION="us-east-1"           # Your AWS region
AWS_S3_BUCKET="nammayatri-dev"          # Your bucket name
AWS_S3_REGION="us-east-1"                # Same as bucket region
AWS_S3_PATH_PREFIX=""                    # Optional: path within bucket
```

---

## ⚠️ Security Checklist

- [ ] Credentials saved in `.env.local`
- [ ] `.env.local` added to `.gitignore`
- [ ] Never committed credentials to git
- [ ] Using IAM user (not root account)
- [ ] IAM user has S3 permissions only
- [ ] Access key is active in AWS Console
- [ ] Never shared credentials with anyone

---

## ❌ Common Mistakes

| Mistake | Impact | Solution |
|---------|--------|----------|
| Committing `.env.local` | Credentials exposed | Add to `.gitignore`, rotate keys |
| Using root credentials | Security risk | Create IAM user instead |
| Hard-coding in Dhall | Credentials in git | Use environment variables |
| Wrong bucket name | S3 operations fail | Verify with `aws s3 ls` |
| Expired access key | Intermittent failures | Create new key in IAM console |
| Network/firewall blocked | Connection timeout | Check firewall, test connectivity |

---

## 🎯 Status Overview

### ✅ What's Been Done
- Created comprehensive documentation
- Created setup scripts (Windows & Linux/Mac)
- Created error troubleshooting guide
- Created configuration examples
- Created security checklist

### ⏳ What You Need to Do
1. Create AWS account (if needed)
2. Run setup script or follow manual steps
3. Set environment variables
4. Update Dhall configuration
5. Test and start developing

### 🎉 Result
Your NammaYatri project will be configured to use real AWS S3 for file storage.

---

## 📞 Need Help?

### If you get an error:
1. Note the exact error message
2. Check: `Backend/S3-CREDENTIAL-ERRORS.md`
3. Find your error in the table
4. Follow the solution steps

### If setup fails:
1. Verify AWS credentials: `aws sts get-caller-identity`
2. Check S3 access: `aws s3 ls`
3. Check environment variables: `env | grep AWS`
4. Review logs for more details

### If still stuck:
1. Re-read the relevant guide
2. Run the setup script with `--debug` if available
3. Check AWS service status: https://status.aws.amazon.com/
4. Contact AWS support or your team lead

---

## 🔄 What Happens When You Run Setup

```
1. Check AWS CLI is installed
   ↓
2. Ask for credentials (Access Key ID & Secret)
   ↓
3. Test credentials validity
   ↓
4. Check/create S3 bucket
   ↓
5. Test S3 access
   ↓
6. Save to .env.local (optional)
   ↓
7. Done! ✅
```

---

## 📊 Configuration After Setup

**Your application flow:**

```
Application
    ↓
Reads .env.local
    ↓
Sets environment variables
    ↓
Dhall config reads env vars
    ↓
Creates S3AwsConfig with credentials
    ↓
Connects to AWS S3
    ↓
Uploads/downloads files
```

---

## 🎓 Learning Resources

- **AWS IAM:** https://docs.aws.amazon.com/iam/
- **AWS S3:** https://docs.aws.amazon.com/s3/
- **AWS CLI:** https://docs.aws.amazon.com/cli/
- **Dhall:** https://dhall-lang.org/
- **Haskell Amazonka:** https://hackage.haskell.org/package/amazonka

---

## ✨ Next Steps

1. **Pick your platform:** Windows, Linux, or Mac
2. **Run the setup script** or follow `AWS-S3-QUICKSTART.md`
3. **Verify with:** `aws s3 ls`
4. **Update Dhall config** with AWS S3 credentials
5. **Start coding!**

---

## 📋 Quick Reference Commands

```bash
# Load credentials (Linux/Mac)
source Backend/.env.local

# Test AWS credentials
aws sts get-caller-identity

# List S3 buckets
aws s3 ls

# Upload file to S3
aws s3 cp file.txt s3://nammayatri-dev/file.txt

# Download file from S3
aws s3 cp s3://nammayatri-dev/file.txt file.txt

# Delete file from S3
aws s3 rm s3://nammayatri-dev/file.txt

# Check environment variables
env | grep AWS
```

---

## 🎯 Success Criteria

You'll know setup is complete when:

✅ `aws sts get-caller-identity` returns your account info  
✅ `aws s3 ls` shows your bucket  
✅ `.env.local` file contains your credentials  
✅ `.gitignore` includes `.env.local`  
✅ Dhall config updated to use AWS S3  
✅ Application starts without S3 errors  
✅ Can upload/download files via S3  

---

**You're all set! 🚀**

Start with: [`AWS-S3-QUICKSTART.md`](./AWS-S3-QUICKSTART.md)
