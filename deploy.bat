@echo off

call az webapp deployment source config --name BeaconWebApp1 -g Beacon_ResourceGroup ^
 ^--repo-url https://github.com/batco/newGitTest.git --branch master --git-token efa83e85d3cc3eddd7c5a7df702ca2feed83efef


