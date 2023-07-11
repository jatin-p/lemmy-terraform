# output "s3_bucketname" {
#   value = aws_s3_bucket.s3.bucket_domain_name
# }

# Output the public IP address of the instance
output "public_ip" {
  value       = aws_instance.ubuntu-server-lts.public_ip
  description = "Public IP address of the EC2 instance"
}

output "amzn_linux_ami_id" {
  value = data.aws_ami.amazon-linux-2023.id
}

output "ubuntu_ami_id" {
  value = data.aws_ami.ubuntu-jammy-lts.id
}

# Learn our public IP address
data "http" "icanhazip" {
  url = "http://icanhazip.com"
}

output "my_ip" {
  value = chomp(data.http.icanhazip.response_body)
}

# # Uncomment to display SSH Key along with stated resources in provders.tf and main.tf
# output "tls_private_key" {
#   value     = tls_private_key.demo_key.private_key_pem
#   sensitive = true
# }