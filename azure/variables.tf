variable "resource_group_location" {
  type        = string
  description = "Location for all resources."
  default     = "northcentralus"
}

variable "resource_group_name_prefix" {
  type        = string
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
  default     = "rg"
}

variable "vm_size" {
  type        = string
  description = "Size the the Virtual machine being deployed."
  default = "Standard_B2s"
}

variable "network_security_rules" {
  type = map(object({
    name                   = string
    priority               = number
    direction              = string
    access                 = string
    protocol               = string
    destination_port_range = string
  }))
  default = {
    lemmy_ssh = {
      name                   = "lemmy-nsg-rule-ssh"
      priority               = 100
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      destination_port_range = "22"
    },
    lemmy_http = {
      name                   = "lemmy-nsg-rule-http"
      priority               = 110
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      destination_port_range = "80"
    },
    lemmy_https = {
      name                   = "lemmy-nsg-rule-https"
      priority               = 120
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      destination_port_range = "443"
    },
    lemmy_outbound = {
      name                   = "outbound-rule"
      priority               = 200
      direction              = "Outbound"
      access                 = "Allow"
      protocol               = "*"
      destination_port_range = "*"
    },
  }
}