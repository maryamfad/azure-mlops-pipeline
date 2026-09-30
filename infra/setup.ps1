# Creates the Azure resources for this project. Safe to run more than once.
# Usage (from the repo root):  .\infra\setup.ps1

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\config.ps1"

function Assert-Ok($step) {
    if ($LASTEXITCODE -ne 0) { throw "Step failed: $step" }
}

Write-Host "Subscription:    $SubscriptionId"
Write-Host "Resource group:  $ResourceGroup ($Location)"
Write-Host "Storage account: $StorageAccount"
Write-Host ""

Write-Host "1/5 Creating resource group..."
az group create --name $ResourceGroup --location $Location --tags $Tags --output none
Assert-Ok "create resource group"

Write-Host "2/5 Creating ADLS Gen2 storage account..."
az storage account create `
    --name $StorageAccount `
    --resource-group $ResourceGroup `
    --location $Location `
    --sku Standard_LRS `
    --kind StorageV2 `
    --enable-hierarchical-namespace true `
    --allow-blob-public-access false `
    --min-tls-version TLS1_2 `
    --tags $Tags `
    --output none
Assert-Ok "create storage account"

Write-Host "3/5 Giving you data access (Storage Blob Data Contributor)..."
$me   = az ad signed-in-user show --query id --output tsv
$saId = az storage account show --name $StorageAccount --resource-group $ResourceGroup --query id --output tsv
$existing = az role assignment list --assignee $me --scope $saId --role "Storage Blob Data Contributor" --query "length(@)" --output tsv
if ($existing -eq "0") {
    az role assignment create --assignee-object-id $me --assignee-principal-type User `
        --role "Storage Blob Data Contributor" --scope $saId --output none
    Assert-Ok "assign data role"
    Write-Host "    Role assigned. Waiting 60 seconds for it to take effect..."
    Start-Sleep -Seconds 60
} else {
    Write-Host "    Role already assigned."
}

Write-Host "4/5 Creating container '$Container'..."
az storage container create --name $Container --account-name $StorageAccount --auth-mode login --output none
Assert-Ok "create container (if this fails, wait a few minutes and rerun: the role may still be propagating)"

Write-Host "5/5 Uploading dataset..."
$dataFile = Join-Path $PSScriptRoot "..\data\raw\credit_default.csv"
if (Test-Path $dataFile) {
    az storage blob upload --account-name $StorageAccount --container-name $Container `
        --name "raw/credit_default.csv" --file $dataFile --auth-mode login --overwrite --output none
    Assert-Ok "upload dataset"
    Write-Host "    Uploaded to $Container/raw/credit_default.csv"
} else {
    Write-Host "    Skipped: $dataFile not found. Run 'python scripts/download_data.py' first, then rerun setup."
}

Write-Host ""
Write-Host "Done. Remember to run .\infra\teardown.ps1 when you finish for the day if you add paid resources."
