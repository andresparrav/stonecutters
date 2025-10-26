output "resource_group_name" {
  description = "Nombre del grupo de recursos"
  value       = azurerm_resource_group.rg.name
}
# output "public_ip" {
#   description = "IP pública de la VM"
#   value       = azurerm_public_ip.pip.ip_address
# }

# output "ssh_command" {
#   description = "Comando sugerido para conectarse a la VM vía SSH"
#   value       = "ssh -i $env:USERPROFILE/.ssh/azure_lab_rsa ${var.admin_username}@${azurerm_public_ip.pip.ip_address}"
# }

output "public_ips" {
  description = "IPs públicas de las VMs (en orden)"
  value       = azurerm_public_ip.pip[*].ip_address
}

output "ssh_commands" {
  description = "Comandos SSH para cada VM (en orden)"
  value = formatlist(
    "ssh -i $env:USERPROFILE/.ssh/azure_lab_rsa ${var.admin_username}@%s",
    azurerm_public_ip.pip[*].ip_address
  )
}
