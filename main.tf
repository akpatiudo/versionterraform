terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.91.0"
    }
  }

  backend "azurerm" {
    storage_account_name = "storage012e"
    container_name       = "terraformcontainer"
    key                  = "terraform.tfstate"
    access_key           = "+7ZLlwJapGbafBi#########"
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

# Create Ubuntu virtual machine
resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-vm"
  resource_group_name = azurerm_resource_group.volvic-prod.name
  location            = azurerm_resource_group.volvic-prod.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "Ukjobs##2020"  # Set the desired password here

  network_interface_ids = [
    azurerm_network_interface.example.id,
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
}