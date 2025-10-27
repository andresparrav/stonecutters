# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

# ---- Resource Group ----
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg1"
  location = var.location
  tags     = var.tags
}

# ---- Red: VNet + Subnet ----
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-snet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

# ---- Seguridad: NSG con SSH desde tu IP ----
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  security_rule {
    name                       = "Allow-SSH-From-Pedro-Home"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allow_ssh_from
    destination_address_prefix = "*"
  }
}

# ---- IP Pública para la VM ----
resource "azurerm_public_ip" "pip" {
  count               = var.vm_count
  name                = format("${var.prefix}-pip-%02d", count.index + 1)
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  tags                = var.tags
}

# ---- NIC + asociación al NSG ----
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = format("${var.prefix}-nic-%02d", count.index + 1)
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ---- VM Linux (Ubuntu LTS) ----
resource "azurerm_linux_virtual_machine" "vm" {
  count                 = var.vm_count
  name                  = format("${var.prefix}-vm-%02d", count.index + 1)
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  tags                  = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  disable_password_authentication = true
}
