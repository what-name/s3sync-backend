resource "aws_s3_bucket" "backup" {
  bucket = "${var.project_name}-cloud-backup"
  acl    = "private"

  ##################################
  # 1. straight-to-ia
  #      objects go to Intelligent Tiering storage class right away
  # 2. delete-versioned-and-failed
  #      delete previous versions in 30 days
  #      delete failed multipart uploads after 1 day
  # 3. delete-me-versioned-instant-delete # DISABLED
  #      delete previous versions after 1 day, used for testing

  ##################################

  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 0
    enabled                                = true
    id                                     = "straight-to-ia"
    tags                                   = {}

    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }
  }
  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 1
    enabled                                = true
    id                                     = "delete-versioned-and-failed"
    tags                                   = {}

    expiration {
      days                         = 0
      expired_object_delete_marker = false
    }

    noncurrent_version_expiration {
      days = 14
    }
  }
  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 0
    enabled                                = false
    id                                     = "delete-me-versioned-instant-delete"
    tags                                   = {}

    noncurrent_version_expiration {
      days = 1
    }
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.backup.arn
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "backup" {
  bucket = aws_s3_bucket.backup.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_kms_key" "backup" {
  description = "Default KMS key for ${var.project_name}-cloud-backup S3 bucket."

  tags = {
    Name = "${var.project_name}-backup"
  }
}
