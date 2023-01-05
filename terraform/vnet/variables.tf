variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "address_space" {
  type    = list(string)
  default = ["10.80.0.0/16"]
}

variable "subnet_name" {
  type    = string
  default = "default"
}

variable "subnet_address_prefix" {
  type = list(string)
}

variable "frontend_subnet_name" {
  type    = string
  default = "frontend"
}

variable "frontend_subnet_address_prefix" {
  type = list(string)
}

variable "bastion_subnet_name" {
  type = string
  default = "AzureBastionSubnet"
}

variable "bastion_subnet_address_prefix" {
  type = list(string)
}