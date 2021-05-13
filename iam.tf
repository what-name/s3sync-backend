resource "aws_iam_user" "backup" {
  name = "${var.project_name}-backup"
  path = "/"
}

######################
# Direct user access #
######################

resource "aws_iam_user_policy" "backup_user_policy" {
  name = "${var.project_name}-BackupUserPolicy"
  user = aws_iam_user.backup.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:ListMultipartUploadParts",
          "s3:ListBucketMultipartUploads",
          "s3:AbortMultipartUpload"
        ]
        Effect   = "Allow"
        Resource = [
          "${aws_s3_bucket.backup.arn}/*",
          "${aws_s3_bucket.backup.arn}",
        ]
      },
      {
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:GenerateDataKey*",
          "kms:ReEncryptFrom",
          "kms:ReEncryptTo"
        ],
        Effect   = "Allow",
        Resource = "${aws_kms_key.backup.arn}"
      },
    ]
  })
}


###############
# Assume Role #
###############

# resource "aws_iam_user_policy" "backup_user_policy" {
#   name = "SpiritBackupAssumeRolePolicy"
#   user = aws_iam_user.backup.name

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "sts:AssumeRole"
#       ],
#       "Effect": "Allow",
#       "Resource": "${aws_iam_role.backup.arn}"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role" "backup" {
#   name                 = "spirit-backup-role"
#   description          = "Allows write access to objects in the spirit-backup bucket."
#   max_session_duration = 21600
#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           "AWS" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_role_policy" "spirit-backup" {
#   name = "SpiritBackupRolePolicy"
#   role = aws_iam_role.backup.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:DeleteObject",
#           "s3:ListBucket",
#           "s3:ListMultipartUploadParts",
#           "s3:ListBucketMultipartUploads",
#           "s3:AbortMultipartUpload"
#         ]
#         Effect   = "Allow"
#         Resource = [
#           "${aws_s3_bucket.backup.arn}/*",
#           "${aws_s3_bucket.backup.arn}",
#         ]
#       },
#       {
#         Action = [
#           "kms:Decrypt",
#           "kms:Encrypt",
#           "kms:GenerateDataKey",
#           "kms:GenerateDataKey*",
#           "kms:ReEncryptFrom",
#           "kms:ReEncryptTo"
#         ],
#         Effect   = "Allow",
#         Resource = "${aws_kms_key.backup.arn}"
#       },
#     ]
#   })
# }
