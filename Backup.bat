@echo off

REM call ResourceGroup = 'Beacon_ResourceGroup'

REM Get updates of Azure Packages from Github
REM call npm install -g azure-cli

REM Delete current Resource Group
REM call az group delete -n Beacon_ResourceGroup --no-wait --yes

REM Place the CLI in wait state until a condition is met
REM call az group wait --name Beacon_ResourceGroup --deleted

call az login


REM Create Resource group in UKWest region
call az group create -l uksouth -n Beacon_ResourceGroup 

call az group wait --name Beacon_ResourceGroup --created

REM Make this the default Resource Group
call az configure --defaults group=Beacon_ResourceGroup
call az group list --output table

REM Create a storage account
call az storage account create -n beaconincstorage -g Beacon_ResourceGroup -l ukwest --sku Standard_LRS
call az storage account list --output table

REM This function creates service plan at two different locations
call az appservice plan create -g Beacon_ResourceGroup -n BeaconAppServPlan1 --number-of-workers 3 --sku B1 -l westeurope
call az appservice plan create -g Beacon_ResourceGroup -n BeaconAppServPlan2 --number-of-workers 3 --sku B1 -l Northeurope

REM Confirmation of successful Service Plan Creation
call az appservice plan list --output table

REM Two WebApp created with each mapped to different service plan locations
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
 ^--repo-url https://github.com/batco/newGitTest.git --branch master --git-token 7c07a8bd07cc35ab72758e09a14000127e561696
call az webapp deployment source config --name BeaconWebApp2 -g Beacon_ResourceGroup ^
 ^--repo-url https://github.com/batco/newGitTest.git --branch master --git-token 7c07a8bd07cc35ab72758e09a14000127e561696

 REM This function opens up the WebApps
call az webapp browse --name BeaconWebApp1
call az webapp browse --name BeaconWebApp2

