variable "resource_group_location" {
  type        = string
  description = "Location for all resources"
  default     = "us-east-2"
}

variable "s3_bucket_name_prefix" {
  type        = string
  description = "Prefix of the S3 bucket name that's combined with a random ID"
  default     = "lemmy"
}

variable "key_pair_name" {
  type    = string
  default = "awskey"
}

variable "vm_size" {
  type        = string
  description = "Size the the Virtual machine being deployed."
  default     = "t2.micro"
}


variable "network_security_rules" {
  type = map(object({
    description      = string
    type             = string
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    security_groups  = list(string)
    from_port        = number
    to_port          = number
    self             = bool
  }))
  default = {
    "http" = {
      description = "http in"
      type        = "ingress"
      protocol    = "tcp"
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      from_port        = 80
      to_port          = 80
      self             = false
    },
    "https" = {
      description = "HTTPS in"
      type        = "ingress"
      protocol    = "tcp"
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      from_port        = 443
      to_port          = 443
      self             = false
    },
    # "outbound" = {
    #   description = "outbound all"
    #   type        = "egress"
    #   protocol    = "-1"
    #   cidr_blocks = [
    #     "0.0.0.0/0",
    #   ]
    #   ipv6_cidr_blocks = []
    #   prefix_list_ids  = []
    #   security_groups  = []
    #   from_port        = 0
    #   to_port          = 0
    #   self             = false
    # },
  }
}

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon-linux-2023" {
  most_recent = true
  # Full params to filter for AMI here:
  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html
  owners = ["amazon"]
  filter {
    name = "name"
    # To ensure we do NOT use minimial AMI, start w/ "al2023-ami-2023"
    values = ["al2023-ami-2023*-x86_64"]
  }

  #   filter {
  #     name = "root-device-type"
  #     values = ["ebs"]
  #   }
}

data "aws_ami" "ubuntu-jammy-lts" {
  most_recent = true
  # Owner ID found here:
  # https://ubuntu.com/tutorials/search-and-launch-ubuntu-22-04-in-aws-using-cli#2-search-for-the-right-ami
  owners = ["679593333241"]
  filter {
    name = "name"
    # To ensure we ONLY use the server AMI and not others like EKS, Pro, etc.
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server*"]
  }

}