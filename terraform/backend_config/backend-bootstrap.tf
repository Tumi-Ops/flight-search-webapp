# This is a one-time setup file to create the S3 bucket and DynamoDB table
# After running this once, you can delete this file or move it to a separate directory
# This ensures there is versioning, encryption, and locking for Terraform state management for recovery and safety
# Can be adapted for other environments by changing names and regions accordingly

# S3 bucket to store Terraform state files
resource "aws_s3_bucket" "state" {
  bucket = "tf-state-dev-stack-eu-north-1"

  # Prevent accidental deletion of the state bucket
  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning so we can recover from bad state changes
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt state files at rest for security
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to the state bucket
resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

# DynamoDB table for state locking to prevent concurrent modifications
resource "aws_dynamodb_table" "lock" {
  name         = "tf-state-locks-dev-stack"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}