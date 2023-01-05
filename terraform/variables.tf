variable "resource_group_name" {
  description = "Name of Azure resource group where VMSS located on"
  type = string
}

variable "resource_group_location" {
  description = "Location of the azure resource group"
  type    = string
  default = "northeurope"
}

variable "vnet_name" {
  description = "Virtual network name where VMSS connected to"
  type = string
}

variable "address_space" {
  description = "Address space of the virtual network"
  type    = list(string)
  default = ["10.80.0.0/16"]
}

variable "subnet_name" {
  description = "Default subnet to be created"
  type    = string
  default = "default"
}

variable "subnet_address_prefix" {
  description = "Address prefix of the subnet"
  type = list(string)
}

variable "vmss_name" {
  description = "VMSS name"
  type = string
}

variable "instances" {
  description = "Number of instances"
  type    = number
  default = 2
}

variable "admin_username" {
  description = "Admin username of the VMSS instance"
  type    = string
  default = "adminuser"
}

variable "admin_password" {
  description = "Admin password of the VMSS instance"
  type = string
}

variable "vmss_type" {
  description = "VMSS operating system type"
  type    = string
  default = "linux"
}

variable "frontend_subnet_name" {
  description = "Subnet name of the public IP address"
  type    = string
  default = "frontend"
}

variable "frontend_subnet_address_prefix" {
  description = "Address prefix of the front-end subnet"
  type = list(string)
}

variable "bastion_subnet_name" {
  type = string
  default = "AzureBastionSubnet"
}

variable "bastion_subnet_address_prefix" {
  type = list(string)
}

variable "nodejs_repo_url" {
  description = "Repository url where the nodejs app located."
  type = string
}

variable "backend_port" {
  description = "Port of the backend check"
  type = number
}

variable "start_file" {
  description = "cloud-init start file."
  type = string
}

variable "healthcheck_path" {
  description = "Path of the backend check"
  type = string
  default = "/"
}

variable "enable_bastion" {
  description = "Enable bastion access"
  type = bool
  default = false
}