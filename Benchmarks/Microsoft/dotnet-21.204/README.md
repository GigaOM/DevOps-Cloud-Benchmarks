# About
This project is to assess Azure App Services for hosting a legacy .NET application. This is a refresh of an [already completed report](https://gigaom.com/report/costs-and-benefits-of-net-application-migration-to-the-cloud/)

# Application
We will utilize a legacy .Net Framework 4.5 application: PartsUnlimited. This is a pre-configured app provided by MS [here](https://github.com/microsoft/PartsUnlimited/tree/aspnet45)

## Prerequisites
Due to the legacy nature of the application you will need Visual Studio 2017 to compile.

# Platforms
We will utilize the following platforms for hosting:
1. Equinix Metal (On-Prem)
     - ESXi Host w/ VCenter
     - 1x PFSense Router
     - 1x NGINX load balancer
     - 4x Win 2016 Servers running IIS (2CPU x 8GB RAM)
     - 1x Win 2016 Server running SQL (4CPU x 16GB RAM)
  
2. Azure App Services
    - 1x Azure Load Balancer
    - Azure APP service PremiumV3 P1
    - Azure SQL

3. AWS Elastic Beanstalk
     - 1x Application Load Balancer
     - 4x Win 2016 Servers running IIS (m5d.large EC2)
     - 1x Win 2016 Server running SQL
  