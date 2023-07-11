# These two resources along with locals block help generate a random bucket name with prefix
# defined in variables.tf comment out these 3 blocks and replace with bucket string if you have
# existing bucket you'd like to use
# resource "random_pet" "s3_name" {
#   prefix = var.s3_bucket_name_prefix
# }

# resource "random_id" "unique_id" {
#   byte_length = 2
# }

# locals {
#   bucket_prefix = "${random_pet.s3_name.id}-${random_id.unique_id.hex}"
# }

# # https://registry.terraform.io/providers/hashicorp/aws/5.7.0/docs/resources/s3_bucket
# resource "aws_s3_bucket" "s3" {
#   bucket = "${local.bucket_prefix}"
# }

# #  https://registry.terraform.io/providers/hashicorp/aws/5.7.0/docs/resources/s3_bucket_ownership_controls
# resource "aws_s3_bucket_ownership_controls" "s3ctls" {
#   bucket = aws_s3_bucket.s3.id
#   rule {
#     object_ownership = "BucketOwnerPreferred"
#   }
# }

# # https://registry.terraform.io/providers/hashicorp/aws/5.7.0/docs/resources/s3_bucket_acl
# resource "aws_s3_bucket_acl" "s3-acl" {
#   depends_on = [aws_s3_bucket_ownership_controls.s3ctls]
#   bucket = aws_s3_bucket.s3.id
#   acl = "private"
# }
