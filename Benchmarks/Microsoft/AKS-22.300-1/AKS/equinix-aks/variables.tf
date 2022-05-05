variable "server_size" {
  type = string
  default = "n2.xlarge.x86"
}

variable "datacenter" {
  type = string
  default = "ny5"
}

variable "OS" {
  type = string
  default = "windows_2022"
}

variable "hostname" {
  type = string
  default = "aks223001"
}

variable "project_id" {
  type = string
  default = ""
}

variable "token" {
  type = string
  sensitive = true
  default = ""
}

variable "public_ssh_key" {
  type = string
  default = ""
}

variable "password" {
  type = string
  default = "Password12!@"
  sensitive = true
}