# AWS S3 Dhall Configuration Examples

This file contains example Dhall configurations for different S3 setups.

---

## Example 1: AWS S3 with Environment Variables (Recommended)

**File:** `Backend/dhall-configs/dev/secrets/common.dhall`

```dhall
let topSecret = ./top-secret.dhall
let globalCommon = ../../generic/common.dhall

-- AWS S3 Configuration (reads from environment variables)
let awsS3Config1 =
      { accessKeyId = env:AWS_ACCESS_KEY_ID as Text
      , secretAccessKey = env:AWS_SECRET_ACCESS_KEY as Text
      , bucketName = env:AWS_S3_BUCKET as Text ? "nammayatri-dev"
      , region = env:AWS_S3_REGION as Text ? "us-east-1"
      , pathPrefix = env:AWS_S3_PATH_PREFIX as Text ? ""
      }

let awsS3Config = globalCommon.S3Config.S3AwsConf awsS3Config1

let InfoBIPConfig = { username = "xxxxx", password = "xxxxx", token = "xxxxx" }

in  { smsUserName = "xxxxxxx"
    , smsPassword = "yyyyyyy"
    , s3Config = awsS3Config
    , s3PublicConfig = awsS3Config
    , googleKey = topSecret.googleKey
    , googleTranslateKey = topSecret.googleTranslateKey
    , slackToken = "xxxxxxx"
    , InfoBIPConfig
    , urlShortnerApiKey = "some-internal-api-key"
    , nammayatriRegistryApiKey = "some-secret-api-key"
    }
```

**Required environment variables:**
```bash
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_S3_BUCKET="nammayatri-dev"
export AWS_S3_REGION="us-east-1"
```

---

## Example 2: Local Mock S3 (Development)

**File:** `Backend/dhall-configs/dev/secrets/common.dhall`

```dhall
let topSecret = ./top-secret.dhall
let globalCommon = ../../generic/common.dhall

-- Local Mock S3 Configuration
let mockS3Config1 =
      { baseLocalDirectory = "./s3/local"
      , bucketName = "test-bucket"
      , pathPrefix = ""
      }

let mockS3Config = globalCommon.S3Config.S3MockConf mockS3Config1

let InfoBIPConfig = { username = "xxxxx", password = "xxxxx", token = "xxxxx" }

in  { smsUserName = "xxxxxxx"
    , smsPassword = "yyyyyyy"
    , s3Config = mockS3Config
    , s3PublicConfig = mockS3Config
    , googleKey = topSecret.googleKey
    , googleTranslateKey = topSecret.googleTranslateKey
    , slackToken = "xxxxxxx"
    , InfoBIPConfig
    , urlShortnerApiKey = "some-internal-api-key"
    , nammayatriRegistryApiKey = "some-secret-api-key"
    }
```

**No environment variables needed** - stores files locally in `./s3/local/`

---

## Example 3: AWS S3 with Hard-coded Credentials (Development Only)

⚠️ **WARNING:** Only for isolated development. Never commit real credentials!

```dhall
let topSecret = ./top-secret.dhall
let globalCommon = ../../generic/common.dhall

-- AWS S3 Configuration (hard-coded)
let awsS3Config1 =
      { accessKeyId = "AKIAIOSFODNN7EXAMPLE"
      , secretAccessKey = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
      , bucketName = "nammayatri-dev"
      , region = "us-east-1"
      , pathPrefix = ""
      }

let awsS3Config = globalCommon.S3Config.S3AwsConf awsS3Config1

let InfoBIPConfig = { username = "xxxxx", password = "xxxxx", token = "xxxxx" }

in  { smsUserName = "xxxxxxx"
    , smsPassword = "yyyyyyy"
    , s3Config = awsS3Config
    , s3PublicConfig = awsS3Config
    , googleKey = topSecret.googleKey
    , googleTranslateKey = topSecret.googleTranslateKey
    , slackToken = "xxxxxxx"
    , InfoBIPConfig
    , urlShortnerApiKey = "some-internal-api-key"
    , nammayatriRegistryApiKey = "some-secret-api-key"
    }
```

---

## Example 4: LocalStack/MinIO Configuration

**File:** `Backend/dhall-configs/dev/secrets/common.dhall`

For testing with LocalStack or MinIO running locally.

```dhall
let topSecret = ./top-secret.dhall
let globalCommon = ../../generic/common.dhall

-- LocalStack/MinIO S3 Configuration
let localstackS3Config1 =
      { accessKeyId = "test"  -- LocalStack accepts any value
      , secretAccessKey = "test"
      , bucketName = "nammayatri-dev"
      , region = "us-east-1"
      , pathPrefix = ""
      }

let localstackS3Config = globalCommon.S3Config.S3AwsConf localstackS3Config1

let InfoBIPConfig = { username = "xxxxx", password = "xxxxx", token = "xxxxx" }

in  { smsUserName = "xxxxxxx"
    , smsPassword = "yyyyyyy"
    , s3Config = localstackS3Config
    , s3PublicConfig = localstackS3Config
    , googleKey = topSecret.googleKey
    , googleTranslateKey = topSecret.googleTranslateKey
    , slackToken = "xxxxxxx"
    , InfoBIPConfig
    , urlShortnerApiKey = "some-internal-api-key"
    , nammayatriRegistryApiKey = "some-secret-api-key"
    }
```

**Then set environment variable for endpoint:**
```bash
export AWS_S3_ENDPOINT="http://localhost:4566"  # LocalStack
# OR
export AWS_S3_ENDPOINT="http://localhost:9000"  # MinIO
```

---

## Example 5: Multi-Environment Configuration (Production-Ready)

For different configurations per environment:

**File:** `Backend/dhall-configs/prod/secrets/common.dhall`

```dhall
let globalCommon = ../../generic/common.dhall

-- Production AWS S3 (from environment)
let prodS3Config1 =
      { accessKeyId = env:AWS_ACCESS_KEY_ID as Text
      , secretAccessKey = env:AWS_SECRET_ACCESS_KEY as Text
      , bucketName = env:AWS_S3_BUCKET as Text ? "nammayatri-prod"
      , region = env:AWS_S3_REGION as Text ? "us-east-1"
      , pathPrefix = env:AWS_S3_PATH_PREFIX as Text ? "prod/"
      }

let prodS3Config = globalCommon.S3Config.S3AwsConf prodS3Config1

let InfoBIPConfig = { username = "xxxxx", password = "xxxxx", token = "xxxxx" }

in  { smsUserName = "xxxxxxx"
    , smsPassword = "yyyyyyy"
    , s3Config = prodS3Config
    , s3PublicConfig = prodS3Config
    , googleKey = "prod-google-key"
    , googleTranslateKey = "prod-translate-key"
    , slackToken = "prod-slack-token"
    , InfoBIPConfig
    , urlShortnerApiKey = "prod-url-shortner-key"
    , nammayatriRegistryApiKey = "prod-registry-key"
    }
```

---

## Example 6: With Path Prefix for Multi-Tenant

If you want to organize uploads by user or service:

```dhall
let globalCommon = ../../generic/common.dhall

let awsS3Config1 =
      { accessKeyId = env:AWS_ACCESS_KEY_ID as Text
      , secretAccessKey = env:AWS_SECRET_ACCESS_KEY as Text
      , bucketName = "nammayatri-shared"
      , region = "us-east-1"
      , pathPrefix = "dev/rider-app/"  -- ← Prefix for this service
      }

let awsS3Config = globalCommon.S3Config.S3AwsConf awsS3Config1

-- Files uploaded will go to: s3://nammayatri-shared/dev/rider-app/filename.txt
```

---

## Example 7: Different Buckets for Public/Private

```dhall
let globalCommon = ../../generic/common.dhall

-- Private bucket for internal files
let privateS3Config1 =
      { accessKeyId = env:AWS_ACCESS_KEY_ID as Text
      , secretAccessKey = env:AWS_SECRET_ACCESS_KEY as Text
      , bucketName = "nammayatri-private"
      , region = "us-east-1"
      , pathPrefix = ""
      }

let privateS3Config = globalCommon.S3Config.S3AwsConf privateS3Config1

-- Public bucket for user uploads
let publicS3Config1 =
      { accessKeyId = env:AWS_ACCESS_KEY_ID as Text
      , secretAccessKey = env:AWS_SECRET_ACCESS_KEY as Text
      , bucketName = "nammayatri-public"
      , region = "us-east-1"
      , pathPrefix = ""
      }

let publicS3Config = globalCommon.S3Config.S3AwsConf publicS3Config1

let InfoBIPConfig = { username = "xxxxx", password = "xxxxx", token = "xxxxx" }

in  { smsUserName = "xxxxxxx"
    , smsPassword = "yyyyyyy"
    , s3Config = privateS3Config        -- ← Private bucket
    , s3PublicConfig = publicS3Config   -- ← Public bucket
    , googleKey = "xxxxx"
    , googleTranslateKey = "xxxxx"
    , slackToken = "xxxxxxx"
    , InfoBIPConfig
    , urlShortnerApiKey = "some-internal-api-key"
    , nammayatriRegistryApiKey = "some-secret-api-key"
    }
```

---

## Switching Between Configurations

### From Mock to AWS S3

**Before (local testing):**
```bash
s3Config = mockS3Config
```

**After (AWS):**
```bash
s3Config = awsS3Config
```

**Then set environment variables:**
```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_S3_BUCKET="nammayatri-dev"
export AWS_S3_REGION="us-east-1"
```

### From AWS to LocalStack

**In Dhall:**
```bash
s3Config = localstackS3Config
```

**Then set endpoint:**
```bash
export AWS_S3_ENDPOINT="http://localhost:4566"
```

**And start LocalStack:**
```bash
docker run -p 4566:4566 localstack/localstack
```

---

## Environment Variable Fallback

In Example 1, note the `?` operator for defaults:

```dhall
let awsS3Config1 =
      { accessKeyId = env:AWS_ACCESS_KEY_ID as Text
      , secretAccessKey = env:AWS_SECRET_ACCESS_KEY as Text
      , bucketName = env:AWS_S3_BUCKET as Text ? "nammayatri-dev"  -- ← Default if not set
      , region = env:AWS_S3_REGION as Text ? "us-east-1"           -- ← Default if not set
      , pathPrefix = env:AWS_S3_PATH_PREFIX as Text ? ""            -- ← Default if not set
      }
```

This means:
- If `AWS_S3_BUCKET` is not set, it defaults to `"nammayatri-dev"`
- If `AWS_S3_REGION` is not set, it defaults to `"us-east-1"`
- If `AWS_S3_PATH_PREFIX` is not set, it defaults to `""` (no prefix)

---

## Troubleshooting Configuration

**Problem:** "Unable to read environment variable"
**Solution:** Set the environment variable before running the application:
```bash
export AWS_ACCESS_KEY_ID="..."
```

**Problem:** "Invalid configuration"
**Solution:** Validate Dhall syntax:
```bash
dhall --check < Backend/dhall-configs/dev/secrets/common.dhall
```

**Problem:** "Wrong bucket being used"
**Solution:** Verify environment variables:
```bash
echo $AWS_S3_BUCKET
echo $AWS_S3_REGION
```

---

## Recommended Setup

For most developers:

```dhall
-- Use Example 1: AWS S3 with Environment Variables
let awsS3Config1 =
      { accessKeyId = env:AWS_ACCESS_KEY_ID as Text
      , secretAccessKey = env:AWS_SECRET_ACCESS_KEY as Text
      , bucketName = env:AWS_S3_BUCKET as Text ? "nammayatri-dev"
      , region = env:AWS_S3_REGION as Text ? "us-east-1"
      , pathPrefix = env:AWS_S3_PATH_PREFIX as Text ? ""
      }
```

With environment variables in `.env.local`:
```bash
AWS_ACCESS_KEY_ID="..."
AWS_SECRET_ACCESS_KEY="..."
AWS_S3_BUCKET="nammayatri-dev"
AWS_S3_REGION="us-east-1"
```

This is secure, flexible, and works across dev/staging/prod environments.
