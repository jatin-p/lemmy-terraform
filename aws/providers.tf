terraform {
  required_version = ">=1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.6.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.5.1"
    }
    # ansible = {
    #   source  = "ansible/ansible"
    #   version = "~>1.1.0"
    # }
    # # Uncomment to use key gen along with main.tf resource "tls_private_key" and 
    # # "public_key" in  "admin_ssh_key" in azurerm_linux_virtual_machine resource
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0.4"
    }
  }
}
provider "aws" {
  region  = var.resource_group_location
  profile = "terraform"
}