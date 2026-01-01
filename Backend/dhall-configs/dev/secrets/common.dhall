let topSecret = ./top-secret.dhall

let globalCommon = ../../generic/common.dhall

let mockS3Config1 =
      { accessKeyId = env:AWS_ACCESS_KEY_ID as Text
      , secretAccessKey = env:AWS_SECRET_ACCESS_KEY as Text
      , bucketName = env:AWS_S3_BUCKET as Text ? "nammayatri-dev"
      , region = env:AWS_S3_REGION as Text ? "us-east-1"
      , pathPrefix = env:AWS_S3_PATH_PREFIX as Text ? ""
      }

let mockS3Config = globalCommon.S3Config.S3MockConf mockS3Config1

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
