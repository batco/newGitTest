@echo off

REM call ResourceGroup = 'Beacon_ResourceGroup'

REM Get updates of Azure Packages from Github
echo Installing Azure Packages from Github
call npm install -g azure-cli

This Function authenticates Login
call az login

REM Create Resource group in UKWest region
echo Creating Resource Group for Beacon Inc
call az group create -l uksouth -n Beacon_ResourceGroup 

REM This function places the CLI in a wait state until the resource is created
call az group wait --name Beacon_ResourceGroup --created

REM Make this the default Resource Group
call az configure --defaults group=Beacon_ResourceGroup
call az group list --output table

REM Create a storage account
echo Creating Storage Account for Beacon In Resource Group
call az storage account create -n beaconincstorage -g Beacon_ResourceGroup -l ukwest --sku Standard_LRS
call az storage account list --output table

REM This function creates service plan at two different locations
echo Creating Two App Service Plan
call az appservice plan create -g Beacon_ResourceGroup -n BeaconAppServPlan1 --number-of-workers 3 --sku B1 -l westeurope
call az appservice plan create -g Beacon_ResourceGroup -n BeaconAppServPlan2 --number-of-workers 3 --sku B1 -l Northeurope

REM Confirmation of successful Service Plan Creation
call az appservice plan list --output table

REM Two WebApp created with each mapped to different service plan locations
echo Creating Two Web Apps for each App Service Plan
call az webapp create -g Beacon_ResourceGroup -p BeaconAppServPlan1 -n BeaconWebApp1
call az webapp create -g Beacon_ResourceGroup -p BeaconAppServPlan2 -n BeaconWebApp2

REM list of successful creation of the WebApps
call az webapp list --output table

Rem This function opens both webapps in browser 
call az webapp browse --name BeaconWebApp1  
call az webapp browse --name BeaconWebApp2

Rem This function shows the details of both webapps
call az webapp show --name BeaconWebApp1
Call az webapp show --name BeaconWebApp2

REM This function enables Continuous deployment configuration from Github from both azure webapps
call az webapp deployment source config --name BeaconWebApp1 -g Beacon_ResourceGroup ^
 ^--repo-url https://github.com/batco/newGitTest.git --branch master --git-token a6ddbcb3e3ed2062c2b096703092817e77f69de8
call az webapp deployment source config --name BeaconWebApp2 -g Beacon_ResourceGroup ^
 ^--repo-url https://github.com/batco/newGitTest.git --branch master --git-token a6ddbcb3e3ed2062c2b096703092817e77f69de8

 REM This function opens up the WebApps
call az webapp browse --name BeaconWebApp1
call az webapp browse --name BeaconWebApp2

echo "First SQL Servers deployed to Webapp1 region West Europe"

REM Set admin login and password for First Server
set adminlogin=Server1Admin
set password=Winter011
set resourcegroup=Beacon_ResourceGroup

REM Logical name for First SQL Server
set server1name=beacon-serv1

REM The ip address range to allow access to the DB
set startip=0.0.0.0
set endip=255.255.255.255

REM create First logical server in the resource group
echo Creating First logical Server
call az sql server create -n %server1name% -g Beacon_ResourceGroup -l westeurope --admin-user %adminlogin% --admin-password %password%

echo "Configuring Firewall Rule for First Server

call az sql server firewall-rule create -g %resourcegroup% --server %server1name% -n AllowEveryOne ^
 ^--start-ip-address %startip% --end-ip-address %endip%
 
echo "Second SQL Server deployed to Webapp2 region North Europe"
 
REM Set admin login and password for Second Server
set adminlogin=Server2Admin
set password=Winter011

REM Logical name for Second SQL Server
set server2name=beacon-serv2

REM Create Second logical server in the resource group
echo Creating second Logical Server
call az sql server create -n %server2name% -g Beacon_ResourceGroup -l Northeurope --admin-user %adminlogin% --admin-password %password%

echo "Configuring Firewall Rule for Second Server

call az sql server firewall-rule create -g %resourcegroup% --server %server2name% -n AllowEveryOne ^
 ^--start-ip-address %startip% --end-ip-address %endip%

set db1=pluto
set db2=mars
 
echo "Creating Database on First Server"

REM Create a first database on first SQL server with zone redundancy as true
call az sql db create -g %resourcegroup% -s %server1name% -n %db1% --service-objective S0 

echo "Creating Second Database on second Server"
REM Create a database in second server with zone redundancy as true
call az sql db create -g %resourcegroup% -s %server2name% -n %db2% --service-objective S0 

REM This function creates availability set
echo Creating Availability Set

call az vm availability-set create BeaconAvSet -g %resourcegroup% --location westus --platform-fault-domain-count 2 ^
	^--platform-update-domain-count 2 

REM This function creates two Virtual Machines in the default resource group
echo Creating Linux Virtual Machine

set user=olanrewaju
set pass=Winter0111984

call az vm create -n BeaconVM1 -g %resourcegroup% --location westus --admin-user %user% ^
	^--admin-password %pass% --image ubuntuLTS --availability-set BeaconAvSet
	
call az vm create -n BeaconVM2 -g %resourcegroup% --location westus --admin-user %user% ^
	^--admin-password %pass% --image ubuntuLTS --availability-set BeaconAvSet
	
REM This function Creates a Backup Vault where Backup Copies, policies and recovery points are stored
echo Creating BackUpVault
call az backup vault create -l canadacentral -n BeaconVaultBkUp -g %resourcegroup%
	

 



