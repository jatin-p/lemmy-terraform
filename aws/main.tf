# https://registry.terraform.io/providers/hashicorp/aws/5.7.0/docs/resources/vpc
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { "Name" = "VPC (Managed by Terraform)" }
}

# https://registry.terraform.io/providers/hashicorp/aws/5.7.0/docs/resources/internet_gateway
resource "aws_internet_gateway" "inetgw" {
  vpc_id = aws_vpc.vpc.id
  tags   = { "Name" = "Internet Gateway (Managed by Terraform)" }
}

# https://registry.terraform.io/providers/hashicorp/aws/5.7.0/docs/resources/subnet
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  tags       = { "Name" = "Subnet (Managed by Terraform)" }
}

# https://registry.terraform.io/providers/hashicorp/aws/5.7.0/docs/resources/route_table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.inetgw.id
  }
  tags = { "Name" = "Route Table (Managed by Terraform)" }
}

# https://registry.terraform.io/providers/hashicorp/aws/5.7.0/docs/resources/route_table_association
resource "aws_route_table_association" "my_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

# https://registry.terraform.io/providers/hashicorp/aws/5.7.0/docs/resources/security_group
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add other necessary inbound rules here

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { "Name" = "Security Group (Managed by Terraform)" }
}

# https://registry.terraform.io/providers/hashicorp/aws/5.7.0/docs/resources/security_group_rule
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

# resource "aws_security_group_rule" "ssh-in" {
#   security_group_id = aws_security_group.sg.id
#   description       = "Allowed to SSH into server from same IP of machine that runs this script (Managed by Terraform)"
#   type              = "ingress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   cidr_blocks       = [join("/", [chomp(data.http.icanhazip.response_body), "32"])]
#   ipv6_cidr_blocks  = []
# }


# # Resource to Create Key Pair
# # https://cloudkatha.com/how-to-create-key-pair-in-aws-using-terraform-in-right-way/
# resource "aws_key_pair" "generated_key" {
#   key_name   = var.key_pair_name
#   public_key = tls_private_key.demo_key.public_key_openssh
#   # To use key you created using "ssh-keygen -t rsa -b 4096" on windows uncomment line below
#   # public_key = file("demokey.pub")
# }

# # Resource to create a SSH private key
# # https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key
# resource "tls_private_key" "demo_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# # Save terraform key to your computer (Windows)
# resource "local_file" "local_key_pair" {
#   # Change name in variables.tf
#   filename        = "${var.key_pair_name}.pem"
#   file_permission = "0400"
#   content         = tls_private_key.demo_key.private_key_pem
# }
resource "aws_key_pair" "existing" {
  key_name   = "my-existing-key"
  public_key = file("~/.ssh/awskey.pub")
}
# https://registry.terraform.io/providers/hashicorp/aws/5.7.0/docs/resources/instance
resource "aws_instance" "ubuntu-server-lts" {
  ami           = data.aws_ami.ubuntu-jammy-lts.id
  instance_type = var.vm_size
  # To use generated key for testing uncomment line below and comment out line "file("~/.ssh/awskey.pub")"
  # key_name = aws_key_pair.generated_key.key_name
  key_name                    = aws_key_pair.existing.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  # Specify root device type & size in GB
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "8"
    delete_on_termination = true
  }
  tags = {
    "Name" = "Ubuntu Server 22.04 LTS (managed by terraform)"
  }
}