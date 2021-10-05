# ################################################################################
# # https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
# # https://docs.aws.amazon.com/AmazonS3/latest/dev/example-bucket-policies.html
# 
# # TODO: Add CloudFront distribution and ACM cert to get HTTPS endpoint
# # for the static website
# 
# resource "aws_s3_bucket" "s3_static_website" {
#   bucket = var.dns_domain
#   acl    = "public-read"
#   tags   = var.tags
# 
#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "PublicReadGetObject",
#             "Effect": "Allow",
#             "Principal": "*",
#             "Action": [
#                 "s3:GetObject"
#             ],
#             "Resource": [
#                 "arn:aws:s3:::${var.dns_domain}/*"
#             ]
#         }
#     ]
# }
# EOF
# 
#   website {
#     index_document = "index.html"
#     error_document = "error.txt"
#   }
# }
# 
# resource "aws_s3_bucket" "config_storage" {
#   bucket = "config.${var.dns_domain}"
#   acl    = "public-read"
#   tags   = var.tags
# 
#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "PublicReadGetObject",
#             "Effect": "Allow",
#             "Principal": "*",
#             "Action": [
#                 "s3:GetObject"
#             ],
#             "Resource": [
#                 "arn:aws:s3:::config.${var.dns_domain}/*"
#             ]
#         }
#     ]
# }
# EOF
# 
#   versioning {
#     enabled = true
#   }
# 
#   website {
#     index_document = "index.html"
#     error_document = "error.txt"
#   }
# }
# 
# ################################################################################
# # https://www.terraform.io/docs/providers/aws/r/s3_bucket_object.html
# 
# resource "aws_s3_bucket_object" "object" {
#   count        = length(var.s3_website_content)
#   bucket       = aws_s3_bucket.s3_static_website.id
#   acl          = "public-read"
#   key          = lookup(var.s3_website_content[count.index], "Name", "index.html")
#   source       = lookup(var.s3_website_content[count.index], "Source", "error.txt")
#   content_type = lookup(var.s3_website_content[count.index], "Content-Type", "text/html")
#   etag         = md5(file(lookup(var.s3_website_content[count.index], "Source", "error.txt")))
# }
# 
# # TODO: Make this config independent of the above S3 objects
# resource "aws_s3_bucket_object" "config_index" {
#   count        = length(var.s3_website_content)
#   bucket       = aws_s3_bucket.config_storage.id
#   acl          = "public-read"
#   key          = lookup(var.s3_website_content[count.index], "Name", "index.html")
#   content      = "= ^ . ^ ="
#   content_type = "text/plain"
#   etag         = md5(file(lookup(var.s3_website_content[count.index], "Source", "error.txt")))
# }
# 
# resource "aws_s3_bucket_object" "config_folders" {
#   count        = length(var.equipo)
#   bucket       = aws_s3_bucket.config_storage.id
#   acl          = "public-read"
#   key          = "${var.equipo[count.index]}/"
#   content      = ""  # Empty to create prefix
#   content_type = "text/plain"
# }
