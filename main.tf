terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.91.0"
    }
  }

  backend "azurerm" {
    storage_account_name = "olvicstorage"
    container_name       = "terraformcontainer"
    key                  = "terraform.tfstate"
    access_key           = "uBIig/3Wo9ad7SBQq+V1t5eoenD4UlBhaH3ZeECTCntK3azMKSQR6jG8LU+AI3hYHYl7tDmW6jEP+AStlN2LaA=="
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "volvic-prod" {
  name     = "volvic-prod-Rg02"
  location = "sweden central"
}

# Create a virtual network
resource "azurerm_virtual_network" "volvic-prod-vnet" {
  name                = "volvic-prod-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.volvic-prod.location
  resource_group_name = azurerm_resource_group.volvic-prod.name
}

# Create a subnet within the virtual network
resource "azurerm_subnet" "volvic-prod-subnet" {
  name                 = "volvic-prod-subnet"
  resource_group_name  = azurerm_resource_group.volvic-prod.name
  virtual_network_name = azurerm_virtual_network.volvic-prod-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a network interface
resource "azurerm_network_interface" "volvic-prod-nic" {
  name                = "volvic-prod-nic"
  resource_group_name = azurerm_resource_group.volvic-prod.name
  location            = azurerm_resource_group.volvic-prod.location

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.volvic-prod-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a Ubuntu virtual machine
resource "azurerm_linux_virtual_machine" "volvic-prod-vm" {
  name                = "volvic-prod-vm"
  resource_group_name = azurerm_resource_group.volvic-prod.name
  location            = azurerm_resource_group.volvic-prod.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "Ukjobs##2020"  # Set the desired password here

  network_interface_ids = [
    azurerm_network_interface.volvic-prod-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  disable_password_authentication = false  # Enable password authentication
}

# Create app service plan
resource "azurerm_service_plan" "volvic-prod-plan" {
  name                = "volvic-prod-Webappplan"
  resource_group_name = azurerm_resource_group.volvic-prod.name
  location            = azurerm_resource_group.volvic-prod.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

# Create web app
resource "azurerm_linux_web_app" "volvic-prod-webapp" {
  name                = "volvic-webapp"
  resource_group_name = azurerm_resource_group.volvic-prod.name
  location            = azurerm_service_plan.volvic-prod-plan.location
  service_plan_id     = azurerm_service_plan.volvic-prod-plan.id

  site_config {}
}
