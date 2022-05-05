terraform {
  required_providers {
    metal = {
      source = "equinix/metal"
      version = "3.3.0-alpha.3"
    }
  }
}

provider "metal" {
  auth_token = var.token
}

resource "metal_device" "akshci-controlplane" {
  count = 2
  project_id = var.project_id
  hostname = "${var.hostname}-controlplane-${count.index}"
  operating_system = var.OS
  plan             = var.server_size
  facilities       = [var.datacenter]
  billing_cycle    = "hourly"

  ip_address {
    type = "private_ipv4"
    cidr = 30
  }

  ip_address {
    type = "public_ipv4"
  }

  connection {
    type     = "password"
    user     = "aksuser"
    password = var.password
    host     = self.access_public_ipv4
  }

resource "metal_device" "akshci-workernode" {
  count = 3
  project_id = var.project_id
  hostname = "${var.hostname}-worker-${count.index}"
  operating_system = var.OS
  plan             = var.server_size
  facilities       = [var.datacenter]
  billing_cycle    = "hourly"

  ip_address {
    type = "private_ipv4"
    cidr = 30
  }
}

output "publicIP1" {
  value = metal_device.akshci-controlplane[0].access_public_ipv4
}

output "publicIP2" {
  value = metal_device.akshci-controlplane[1].access_public_ipv4
}

output "privateIP1" {
  value = metal_device.akshci-controlplane[0].access_private_ipv4
}

output "privateIP2" {
  value = metal_device.akshci-controlplane[1].access_private_ipv4
}