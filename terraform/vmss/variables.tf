variable "vmss_rg_name" {
  type = string
}

variable "vmss_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "vnet_rg_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "vmss_type" {
  type = string
}

variable "instances" {
  type    = number
  default = 2
}

variable "admin_username" {
  type    = string
  default = "adminuser"
}

variable "admin_password" {
  type = string
}

variable "cloudconfig_file" {
  type    = string
  default = "cloud-init.config"
}

variable "nodejs_repo_url" {
  type = string
}

variable "backend_port" {
  type = number
}

variable "start_file" {
  type = string
}