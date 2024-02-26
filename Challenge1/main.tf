provider "azurerm" {
  features = {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "ResourceGroup1"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet for Web Tier
resource "azurerm_subnet" "web" {
  name                 = "web-subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes    = ["10.0.1.0/24"]
}

# Subnet for App Tier
resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes    = ["10.0.2.0/24"]
}

# Subnet for DB Tier
resource "azurerm_subnet" "db" {
  name                 = "db-subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes    = ["10.0.3.0/24"]
}

# Network Security Group for Web Tier
resource "azurerm_network_security_group" "web" {
  name                = "web-nsg"
  resource_group_name = azurerm_resource_group.rg.name
}

# Network Security Group for App Tier
resource "azurerm_network_security_group" "app" {
  name                = "app-nsg"
  resource_group_name = azurerm_resource_group.rg.name
}

# Network Security Group for DB Tier
resource "azurerm_network_security_group" "db" {
  name                = "db-nsg"
  resource_group_name = azurerm_resource_group.rg.name
}

# Public IP for Load Balancer
resource "azurerm_public_ip" "lb" {
  name                = "lb-public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Load Balancer
resource "azurerm_lb" "lb" {
  name                = "lb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

# Virtual Machines (Web Tier)
resource "azurerm_virtual_machine" "web" {
  count                 = 2
  name                  = "web-vm-${count.index}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  availability_set_id   = azurerm_availability_set.lb.id
  network_interface_ids = [azurerm_network_interface.web[count.index].id]
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  admin_password        = "Password1234!"

  os_profile {
    computer_name  = "web-vm-${count.index}"
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

# Virtual Machines (App Tier)
resource "azurerm_virtual_machine" "app" {
  count                 = 2
  name                  = "app-vm-${count.index}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  availability_set_id   = azurerm_availability_set.lb.id
  network_interface_ids = [azurerm_network_interface.app[count.index].id]
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  admin_password        = "Password1234!"

  os_profile {
    computer_name  = "app-vm-${count.index}"
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

# Virtual Machines (DB Tier)
resource "azurerm_virtual_machine" "db" {
  count                 = 2
  name                  = "db-vm-${count.index}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  availability_set_id   = azurerm_availability_set.lb.id
  network_interface_ids = [azurerm_network_interface.db[count.index].id]
  size                  = "Standard_DS2_v2"
  admin_username        = "adminuser"
  admin_password        = "Password1234!"

  os_profile {
    computer_name  = "db-vm-${count.index}"
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

# Database Server
resource "azurerm_sql_server" "db" {
  name                = "sql-db-server"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "B_Gen5_1"
  storage_profile     = "Standard_LRS"
  version             = "9.6"
  administrator_login          = "dbadmin"
  administrator_login_password = "Password1234!"

  auto_grow_enabled   = true
  backup_retention_days = 7
  geo_redundant_backup_enabled = false
}

# Availability Set
resource "azurerm_availability_set" "availability_set" {
  name                = "availability-set"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Network Interfaces for Web Tier
resource "azurerm_network_interface" "web" {
  count               = 2
  name                = "web-nic-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web.id
   
