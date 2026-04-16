resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-ecom-app-data"
}

# 1. Versioning (fix CKV_AWS_21)
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.my_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 2. Encryption with KMS (fix CKV_AWS_145)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

# 3. Public access block (fix CKV2_AWS_6)
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 4. Logging (fix CKV_AWS_18)
resource "aws_s3_bucket_logging" "logging" {
  bucket = aws_s3_bucket.my_bucket.id

  target_bucket = aws_s3_bucket.my_bucket.id
  target_prefix = "log/"
}

# 5. Lifecycle policy (fix CKV2_AWS_61)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    id     = "log-cleanup"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}