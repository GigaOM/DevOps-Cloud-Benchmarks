variable "project_id" {
  type = string
  default = ""
}

variable "region" {
  type = string
  default = "us-east1"
}

variable "vpc_name" {
  type = string
  default = "default"
}

variable "subnet_name" {
  type = string
  default = "default"
}

variable "node_count" {
  type = string
  default = 3
}

variable "cluster_name" {
  type = string
  default = "msbenchmarkgkecloud"
}