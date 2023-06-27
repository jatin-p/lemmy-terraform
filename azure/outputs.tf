output "resource_group_name" {
  value = azurerm_resource_group.lemmy.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.lemmy.public_ip_address
}
# # Uncomment to display SSH Key along with stated resources in provders.tf and main.tf
# output "tls_private_key" {
#   value     = tls_private_key.lemmy_ssh.private_key_pem
#   sensitive = true
# }