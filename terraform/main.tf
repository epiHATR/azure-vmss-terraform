terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.34.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_uuid" "gateway_ip_configuration" {
}
resource "random_uuid" "frontend_port_name" {
}
resource "random_uuid" "frontend_ip_configuration" {
}
resource "random_uuid" "backend_address_pool_name" {
}
resource "random_uuid" "backend_http_settings_name" {
}
resource "random_uuid" "http_listener_name" {
}
resource "random_uuid" "request_routing_rule_name" {
}

locals {
  resource_group_name            = var.resource_group_name
  vnet_name                      = var.vnet_name
  vnet_address_space             = var.address_space
  subnet_name                    = var.subnet_name
  subnet_address_prefix          = var.subnet_address_prefix
  frontend_subnet_address_prefix = var.frontend_subnet_address_prefix
  bastion_subnet_name            = var.bastion_subnet_name
  bastion_subnet_address_prefix  = var.bastion_subnet_address_prefix
  vmss_name                      = var.vmss_name
  admin_username                 = var.admin_username
  admin_password                 = var.admin_password
  instances                      = var.instances

  gateway_ip_configuration   = "gc-${replace(random_uuid.gateway_ip_configuration.result, "-", "")}"
  frontend_port_name         = "fp-${replace(random_uuid.frontend_port_name.result, "-", "")}"
  frontend_ip_configuration  = "cf-${replace(random_uuid.frontend_ip_configuration.result, "-", "")}"
  backend_address_pool_name  = "bp-${replace(random_uuid.backend_address_pool_name.result, "-", "")}"
  backend_http_settings_name = "bs-${replace(random_uuid.backend_http_settings_name.result, "-", "")}"
  http_listener_name         = "ln-${replace(random_uuid.http_listener_name.result, "-", "")}"
  request_routing_rule_name  = "rl-${replace(random_uuid.request_routing_rule_name.result, "-", "")}"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

module "vnet" {
  source = "./vnet"

  resource_group_name = azurerm_resource_group.rg.name
  vnet_name           = local.vnet_name
  address_space       = local.vnet_address_space

  subnet_name                    = local.subnet_name
  subnet_address_prefix          = local.subnet_address_prefix
  frontend_subnet_address_prefix = local.frontend_subnet_address_prefix
  bastion_subnet_name            = local.bastion_subnet_name
  bastion_subnet_address_prefix  = local.bastion_subnet_address_prefix

  depends_on = [
    azurerm_resource_group.rg
  ]
}

module "vmss" {
  source = "./vmss"

  vmss_type = var.vmss_type

  vmss_rg_name = azurerm_resource_group.rg.name
  vmss_name    = local.vmss_name
  vnet_name    = local.vnet_name
  vnet_rg_name = local.resource_group_name
  subnet_name  = local.subnet_name
  instances    = local.instances

  admin_username = local.admin_username
  admin_password = local.admin_password

  nodejs_repo_url = var.nodejs_repo_url
  backend_port    = var.backend_port
  start_file      = var.start_file

  depends_on = [
    azurerm_resource_group.rg,
    module.vnet
  ]
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name

  depends_on = [
    module.vnet
  ]
}

data "azurerm_subnet" "bastion_subnet" {
  count                = var.enable_bastion == true ? 1 : 0
  name                 = var.bastion_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name

  depends_on = [
    module.vnet,
    data.azurerm_virtual_network.vnet
  ]
}

resource "azurerm_public_ip" "bastion_pip" {
  count               = var.enable_bastion == true ? 1 : 0
  name                = "${var.vnet_name}-bastion-pip"
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  location            = data.azurerm_virtual_network.vnet.location
  allocation_method   = "Static"
  sku                 = "Standard"

  depends_on = [
    data.azurerm_virtual_network.vnet
  ]
}

resource "azurerm_bastion_host" "bastion_host" {
  count               = var.enable_bastion == true ? 1 : 0
  name                = "${var.vnet_name}-bastion"
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name

  ip_configuration {
    name                 = "default"
    subnet_id            = data.azurerm_subnet.bastion_subnet.0.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.0.id
  }
  depends_on = [
    module.vmss,
    azurerm_public_ip.bastion_pip,
    data.azurerm_subnet.bastion_subnet,
    data.azurerm_virtual_network.vnet
  ]
}

data "azurerm_subnet" "frontend" {
  name                 = var.frontend_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name

  depends_on = [
    module.vnet,
    data.azurerm_virtual_network.vnet
  ]
}

resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.vnet_name}-appgw-pip"
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  location            = data.azurerm_virtual_network.vnet.location
  allocation_method   = "Static"
  sku                 = "Standard"

  depends_on = [
    data.azurerm_virtual_network.vnet
  ]
}

data "azurerm_virtual_machine_scale_set" "vmss" {
  name                = local.vmss_name
  resource_group_name = local.resource_group_name

  depends_on = [
    module.vmss
  ]
}

resource "azurerm_application_gateway" "appgw" {
  name                = "${var.vnet_name}-appgw"
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  location            = data.azurerm_virtual_network.vnet.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration
    subnet_id = data.azurerm_subnet.frontend.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = data.azurerm_virtual_machine_scale_set.vmss.instances.*.private_ip_address
  }

  backend_http_settings {
    name                  = local.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    path                  = var.healthcheck_path
    port                  = var.backend_port
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.http_listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_settings_name
    priority                   = 1
  }

  depends_on = [
    module.vnet,
    module.vmss,
    data.azurerm_virtual_network.vnet,
    azurerm_public_ip.appgw_pip,
    data.azurerm_subnet.frontend,
    data.azurerm_virtual_machine_scale_set.vmss
  ]

  tags = {
    Last_Update = timestamp()
  }
}

output "appgw_pip_address" {
  value = azurerm_public_ip.appgw_pip.ip_address

  depends_on = [
    azurerm_public_ip.appgw_pip
  ]
}