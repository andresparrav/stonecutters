variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "westeurope" # Amsterdam: West Europe
}

variable "prefix" {
  description = "Prefijo para nombre de recursos"
  type        = string
  default     = "az104lab"
}

variable "admin_username" {
  description = "Usuario admin de la VM"
  type        = string
  default     = "azureadmin"
}

variable "ssh_public_key_path" {
  description = "Ruta a tu llave pública SSH"
  type        = string
  default     = "~/.ssh/azure_lab_ed25519.pub"
}

variable "vm_size" {
  description = "Tamaño de la VM"
  type        = string
  default     = "Standard_B1s"
}

variable "allow_ssh_from" {
  description = "Tu IP pública para permitir SSH (CIDR /32)"
  type        = string
  default     = "0.0.0.0/0" # CAMBIA esto a TU.IP.PUBLICA/32 por seguridad
}

variable "tags" {
  description = "Etiquetas comunes"
  type        = map(string)
  default = {
    course = "az-104"
    owner  = "Pedro Zea"
    source = "Terraform"
  }
}

variable "vm_count" {
  description = "Número de VMs a desplegar"
  type        = number
  default     = 1
}
