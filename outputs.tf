output "backup_bucket_domain_name" {
  value = aws_s3_bucket.backup.bucket_regional_domain_name
}

# output "backup_iam_role" {
#   value = aws_iam_role.spirit_backup.arn
# }