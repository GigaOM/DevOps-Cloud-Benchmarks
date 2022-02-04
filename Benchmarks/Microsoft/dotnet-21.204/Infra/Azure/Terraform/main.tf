############################
# VARIABLES
############################

variable "prefix" {
    type = string
    description = "Prefix for resources"
    default = "21-204-PU"
}

variable "location" {
    type = string
    description = "Azure region"
    default = "East US 2"
}

variable "asp_tier" {
    type = string
    description = "Tier for App Service Plan (Standard, PremiumV2)"
    default = "PremiumV3"
}

variable "asp_size" {
    type = string
    description = "Size for App Service Plan (S2, P1v2)"
    default = "P1V3"
}

variable "capacity" {
  type = string
  description = "Number of instances for App Service Plan"
  default = "4"
}

variable "dbuser" {
  type = string
  default = "sqladmin"
}

variable "dbpassword" {
  type = string
}

############################
# PROVIDERS
############################

provider "azurerm" {
  version = "~>2.0"
  features {}
}

############################
# RESOURCES
############################

data "http" "my_ip" {
    url = "http://ifconfig.me"
}

#### App Service

resource "azurerm_resource_group" "partsunlimited" {
  name     = "21.204BenchmarkRM"
  location = var.location
}

resource "azurerm_app_service_plan" "partsunlimited" {
  name                = "PartsUnlimited-${var.prefix}"
  location            = azurerm_resource_group.partsunlimited.location
  resource_group_name = azurerm_resource_group.partsunlimited.name

  sku {
    tier = var.asp_tier
    size = var.asp_size
    capacity = var.capacity
  }
}

resource "azurerm_app_service" "example" {
  name                = "PartsUnlimited-${var.prefix}"
  location            = azurerm_resource_group.partsunlimited.location
  resource_group_name = azurerm_resource_group.partsunlimited.name
  app_service_plan_id = azurerm_app_service_plan.partsunlimited.id

  client_affinity_enabled = false
  

  site_config {
    dotnet_framework_version = "v4.0"
    always_on = true
  }

  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "6.9.1"
  }

  connection_string {
    name  = "PartsUnlimitedWebsite"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.sqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.sqldb.name};User Id=${var.dbuser}@${azurerm_mssql_server.sqlserver.name};Password=${var.dbpassword}"
  }
}


#### Azure SQL

resource "azurerm_mssql_server" "sqlserver" {
  name                         = "21-204-partsunlimited"
  resource_group_name          = azurerm_resource_group.partsunlimited.name
  location                     = azurerm_resource_group.partsunlimited.location
  version                      = "12.0"
  administrator_login          = var.dbuser
  administrator_login_password = var.dbpassword

}

resource "azurerm_mssql_database" "sqldb" {
  name                = "PartsUnlimited${var.prefix}"
  server_id        = azurerm_mssql_server.sqlserver.id

  max_size_gb    = 50
  sku_name = "GP_Gen5_4"

}

resource "azurerm_sql_firewall_rule" "allowazure" {
  name                = "AllowAzureServices"
  resource_group_name = azurerm_resource_group.partsunlimited.name
  server_name         = azurerm_mssql_server.sqlserver.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_sql_firewall_rule" "allowlocal" {
  name                = "AllowClientIP"
  resource_group_name = azurerm_resource_group.partsunlimited.name
  server_name         = azurerm_mssql_server.sqlserver.name
  start_ip_address    = data.http.my_ip.body
  end_ip_address      = data.http.my_ip.body
}

output "ConnectionString1" {
  value = "${connection_string.value}"
  
}


output "NextSteps" {
  value = "Utilize Visual Studio Publish to Azure function to deploy application to app service ${azurerm_app_service_plan.partsunlimited.name} "

}