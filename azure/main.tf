locals {
  common_tags = {
    environment = "test"
  }
}

resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

# Define a resource group
# https://registry.terraform.io/providers/hashicorp/azurerm/3.62.1/docs/resources/resource_group
resource "azurerm_resource_group" "lemmy" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id

  tags = local.common_tags
}


# Define virtual network
# https://registry.terraform.io/providers/hashicorp/azurerm/3.62.1/docs/resources/virtual_network
resource "azurerm_virtual_network" "lemmy" {
  name                = "lemmy-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.lemmy.location
  resource_group_name = azurerm_resource_group.lemmy.name

  tags = local.common_tags
}

# Define subnet
# https://registry.terraform.io/providers/hashicorp/azurerm/3.62.1/docs/resources/subnet
resource "azurerm_subnet" "lemmy" {
  name                 = "lemmy-subnet"
  resource_group_name  = azurerm_resource_group.lemmy.name
  virtual_network_name = azurerm_virtual_network.lemmy.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Define public IP address
# https://registry.terraform.io/providers/hashicorp/azurerm/3.62.1/docs/resources/public_ip
resource "azurerm_public_ip" "lemmy" {
  name                = "lemmy-publicip"
  location            = azurerm_resource_group.lemmy.location
  resource_group_name = azurerm_resource_group.lemmy.name
  allocation_method   = "Dynamic"

  tags = local.common_tags
}

# Define network security group
# https://registry.terraform.io/providers/hashicorp/azurerm/3.62.1/docs/resources/network_security_group
resource "azurerm_network_security_group" "lemmy" {
  name                = "lemmy-nsg"
  location            = azurerm_resource_group.lemmy.location
  resource_group_name = azurerm_resource_group.lemmy.name

  tags = local.common_tags
}

# Define network security group rule
# https://registry.terraform.io/providers/hashicorp/azurerm/3.62.1/docs/resources/network_security_rule
# Create Network Security Group and rule based on variables.tf map of rules
resource "azurerm_network_security_rule" "lemmy" {
  # youtube video explaining for_each https://youtu.be/CvgfttjqMH8
  for_each                    = var.network_security_rules
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  destination_port_range      = each.value.destination_port_range
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.lemmy.name
  network_security_group_name = azurerm_network_security_group.lemmy.name
}

# Define network interface
# https://registry.terraform.io/providers/hashicorp/azurerm/3.62.1/docs/resources/network_interface
resource "azurerm_network_interface" "lemmy" {
  name                = "lemmy-nic"
  location            = azurerm_resource_group.lemmy.location
  resource_group_name = azurerm_resource_group.lemmy.name

  ip_configuration {
    name                          = "lemmy-ipconfig"
    subnet_id                     = azurerm_subnet.lemmy.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lemmy.id
  }
}

# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.lemmy.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
# https://registry.terraform.io/providers/hashicorp/azurerm/3.62.1/docs/data-sources/storage_account
resource "azurerm_storage_account" "my_storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = azurerm_resource_group.lemmy.location
  resource_group_name      = azurerm_resource_group.lemmy.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.common_tags
}

# # Create  an SSH key to log into VM (or use existing key by pointing to file)
# # https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key
# resource "tls_private_key" "lemmy_ssh" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }


# Define a LINUX virtual machine which supersedes old "azurerm_virtual_machine" resource
# https://registry.terraform.io/providers/hashicorp/azurerm/3.62.1/docs/resources/linux_virtual_machine
resource "azurerm_linux_virtual_machine" "lemmy" {
  name                  = "lemmy-vm"
  location              = azurerm_resource_group.lemmy.location
  resource_group_name   = azurerm_resource_group.lemmy.name
  network_interface_ids = [azurerm_network_interface.lemmy.id]
  size                  = var.vm_size


  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    name                 = "lemmy-OSdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/lemmyazurekey.pub")
    # comment line above and the commented "tls_private_key" to generate/use SSH key below
    # public_key = tls_private_key.example_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }

  tags = local.common_tags
}