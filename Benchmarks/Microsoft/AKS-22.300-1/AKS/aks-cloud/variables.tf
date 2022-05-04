variable "name" {
  type = string
  default = "msbenchmarkaks"
}

variable "resource_group_name" {
  type = string
  default = "msaks"
}

variable "location" {
  type = string
  default = "eastus"
}

variable "node_count" {
  type = string
  default = 3
}

variable "vm_size" {
    default = "Standard_D4S_v5"
  type = string
}