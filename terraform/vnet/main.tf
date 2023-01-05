data "azurerm_resource_group" "vnet_rg" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
  resource_group_name = data.azurerm_resource_group.vnet_rg.name
  location            = data.azurerm_resource_group.vnet_rg.location

  depends_on = [
    data.azurerm_resource_group.vnet_rg
  ]
}

resource "azurerm_subnet" "default" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.vnet_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefix

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_subnet" "frontend" {
  name                 = var.frontend_subnet_name
  resource_group_name  = data.azurerm_resource_group.vnet_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.frontend_subnet_address_prefix

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_subnet" "bastion" {
  name                 = var.bastion_subnet_name
  resource_group_name  = data.azurerm_resource_group.vnet_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.bastion_subnet_address_prefix

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}