# Deletes EVERYTHING in this project's resource group.
# Usage (from the repo root):  .\infra\teardown.ps1         (asks to confirm)
#                              .\infra\teardown.ps1 -Force  (no prompt)

param([switch]$Force)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\config.ps1"

$exists = az group exists --name $ResourceGroup
if ($exists -ne "true") {
    Write-Host "Resource group $ResourceGroup does not exist. Nothing to delete."
    exit 0
}

Write-Host "Resources that will be deleted:"
az resource list --resource-group $ResourceGroup --query "[].{name:name, type:type}" --output table

if (-not $Force) {
    $answer = Read-Host "Type the resource group name ($ResourceGroup) to confirm"
    if ($answer -ne $ResourceGroup) { Write-Host "Cancelled."; exit 0 }
}

az group delete --name $ResourceGroup --yes --no-wait
if ($LASTEXITCODE -ne 0) { throw "Delete failed" }
Write-Host "Deletion started. It takes a few minutes; check with: az group exists --name $ResourceGroup"
