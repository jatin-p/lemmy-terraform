resource "random_pet" "s3_name" {
  prefix = var.s3_bucket_name_prefix
}

resource "random_id" "unique_id" {
  byte_length = 2
}

locals {
  bucket_prefix = "${random_pet.s3_name.id}-${random_id.unique_id.hex}"
}

# https://registry.terraform.io/providers/hashicorp/aws/5.6.2/docs/resources/s3_bucket
resource "aws_s3_bucket" "s3" {
  bucket = "${local.bucket_prefix}"
}

#  https://registry.terraform.io/providers/hashicorp/aws/5.6.2/docs/resources/s3_bucket_ownership_controls
resource "aws_s3_bucket_ownership_controls" "s3ctls" {
  bucket = aws_s3_bucket.s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/5.6.2/docs/resources/s3_bucket_acl
resource "aws_s3_bucket_acl" "s3-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.s3ctls]
  bucket = aws_s3_bucket.s3.id
  acl = "private"
}

# https://registry.terraform.io/providers/hashicorp/aws/5.6.2/docs/resources/vpc
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { "Name" = "S3 bucket ACL (Managed by Terraform)" }
}

# https://registry.terraform.io/providers/hashicorp/aws/5.6.2/docs/resources/internet_gateway
resource "aws_internet_gateway" "inetgw" {
  vpc_id = aws_vpc.vpc.id
  tags   = { "Name" = "Internet Gateway (Managed by Terraform)" }
}

# https://registry.terraform.io/providers/hashicorp/aws/5.6.2/docs/resources/subnet
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  tags       = { "Name" = "Subnet (Managed by Terraform)" }
}

# https://registry.terraform.io/providers/hashicorp/aws/5.6.2/docs/resources/route_table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.inetgw.id
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/5.6.2/docs/resources/route_table_association
resource "aws_route_table_association" "my_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

# https://registry.terraform.io/providers/hashicorp/aws/5.6.2/docs/resources/security_group
resource "aws_security_group" "sg" {

}

# https://registry.terraform.io/providers/hashicorp/aws/5.6.2/docs/resources/security_group_rule
resource "aws_security_group_rule" "network" {
  for_each          = var.network_security_rules
  description       = each.value.description
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  ipv6_cidr_blocks  = each.value.ipv6_cidr_blocks
  security_group_id = aws_security_group.sg.id
}
resource "aws_security_group_rule" "ssh-in" {
  security_group_id = aws_security_group.sg.id
  description       = "Allowed to SSH into server from same IP of machine that runs this script (Managed by Terraform)"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [join("/", [chomp(data.http.icanhazip.response_body), "32"])]
  ipv6_cidr_blocks  = []
}


# Resource to Create Key Pair
# https://cloudkatha.com/how-to-create-key-pair-in-aws-using-terraform-in-right-way/
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.demo_key.public_key_openssh
  # To use key you created using "ssh-keygen -t rsa -b 4096" on windows uncomment line below
  # public_key = file("demokey.pub")
}

# Resource to create a SSH private key
# https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key
resource "tls_private_key" "demo_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save terraform key to your computer (Windows)
resource "local_file" "local_key_pair" {
  # Change name in variables.tf
  filename        = "${var.key_pair_name}.pem"
  file_permission = "0400"
  content         = tls_private_key.demo_key.private_key_pem
}

# https://registry.terraform.io/providers/hashicorp/aws/5.6.2/docs/resources/instance
resource "aws_instance" "ubuntu-server-lts" {
  ami           = data.aws_ami.ubuntu-jammy-lts.id
  instance_type = var.vm_size
  # To use generated key for testing uncomment line below and comment out "aws-ubuntu-ssh-key"
  key_name = aws_key_pair.generated_key.key_name
  tags = {
    "Name" = "Ubuntu Server 22.04 LTS (managed by terraform)"
  }
}
