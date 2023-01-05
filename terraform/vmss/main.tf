data "azurerm_resource_group" "vmss_rg" {
  name = var.vmss_rg_name
}

data "azurerm_subnet" "vmss_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_rg_name
}

resource "local_file" "cloudconfig" {
  content = templatefile(
    "${path.module}/${var.cloudconfig_file}",
    {
      admin_username  = var.admin_username
      hashed_password = bcrypt(var.admin_password)
      nodejs_repo_url = var.nodejs_repo_url
      backend_port    = var.backend_port
      start_file      = var.start_file
    }
  )
  filename = "${path.module}/${var.cloudconfig_file}.temp"
}

data "local_file" "cloudinit_file" {
    filename = "${path.module}/${var.cloudconfig_file}.temp"

    depends_on = [
      local_file.cloudconfig
    ]
}

resource "azurerm_linux_virtual_machine_scale_set" "linux_vmss" {
  name                = var.vmss_name
  resource_group_name = data.azurerm_resource_group.vmss_rg.name
  location            = data.azurerm_resource_group.vmss_rg.location
  sku                 = "Standard_D2s_v3"
  instances           = var.instances
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  disable_password_authentication = false

  custom_data = data.local_file.cloudinit_file.content_base64

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "default"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = data.azurerm_subnet.vmss_subnet.id
    }
  }

  depends_on = [
    data.azurerm_resource_group.vmss_rg,
    data.azurerm_subnet.vmss_subnet,
    data.local_file.cloudinit_file
  ]
}
