terraform {
  required_version = ">=1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.63.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.5.1"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "~>1.1.0"
    }
    # # Uncomment to use key gen along with main.tf resource "tls_private_key" and 
    # # "public_key" in  "admin_ssh_key" in azurerm_linux_virtual_machine resource
    # tls = {
    #   source = "hashicorp/tls"
    #   version = "~>4.0.4"
    # }
  }
}
provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}