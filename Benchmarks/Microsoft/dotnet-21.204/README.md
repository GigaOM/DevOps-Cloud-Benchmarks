# About
This project is to assess Azure App Services for hosting a legacy .NET application. This is a refresh of an [already completed report](https://gigaom.com/report/costs-and-benefits-of-net-application-migration-to-the-cloud/)

# Application
We will utilize a legacy .Net Framework 4.5 application: PartsUnlimited. This is a pre-configured app provided by MS [here](https://github.com/microsoft/PartsUnlimited/tree/aspnet45)

## Prerequisites
Due to the legacy nature of the application you will need Visual Studio 2017 to compile.

# Platforms
We will utilize the following platforms for hosting:
1. Equinix Metal (On-Prem)
     - 1x Ubuntu Router/NGINX load balancer
     - ESXi Host w/ VCenter
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
  
# Deployment Steps
1. Equinix
   1. Deploy Router and VCenter via Infra/Equinix/Terraform.
   2. Download windows iso directly to esxi server into datastore1
      1. wget -c http://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso
   3. Create windows Server Base Image
      1. Install Chocolatey
      2. Install base programs: choco install notepadplusplus googlechrome vscode 
      3. Enable RDP
      4. Turn off Firewall
      5. Sysprep 
   4. Deploy sql00 and web00 from template.
   5. SQL00
      1. choco install sql-server-2019 sql-server-management-studio
   6. WEB00
      1. Install IIS ./Infra/Equinix/IIS/IIS_Setup.ps1
      2. Remove Default Website
      3. Create new website "PartsUnlimitedWebsite"
      4. Deploy project into root folder
      5. Update web.config to point to sql00
      6. test localhost:80 - (page load, test search, test cart transaction.)
   7. WEB01-03
      1. Take snapshot of WEB00 called "PreSysPrep"
      2. Sysprep and shutdown image
      3. Use Vcenter to deploy clone of web00 called web01
      4. Start VM, set Admin password
      5. test localhost:80 - (page load, test search, test cart transaction.)
      6. repeat for web02, web03
   8. Install/Configure nginx on router
      1. sudo apt install nginx
      2. replace /etc/nginx/sites-enabled/default with ./Infra/Equinix/NGINX/default
      3. setup certbot: sudo apt install certbot python3-certbot-nginx
      4. create nginx certs: sudo certbot --nginx -d shop.ferosferio.com
2. Azure
   1. Create Resource Group
   2. Migrate SQL
      1. SQL00 - MSSQL Management Studio > "PartsUnlimitedWebsite" > Tasks > Deploy Database to Microsoft Azure SQL Database
   3. Deploy AppService Via Visual Studio
      1. Point to Database created in step 2.
      2. Test Application load and checkout.
   4. Deploy CERT
      1. Migrate Cert from nginx - openssl pkcs12 -export -out certificate.pfx -inkey privkey.pem -in cert.pem
      2. Setup custom domain and import .pfk file
3. AWS