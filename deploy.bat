@echo off

call az webapp deployment source config --name BeaconWebApp1 -g Beacon_ResourceGroup ^
 ^--repo-url https://github.com/batco/newGitTest.git --branch master --git-token 1d3f6833fdc29c962a3e4f1c1c2f7deb3904be4c


