# Shared settings for setup.ps1 and teardown.ps1.
# Change $Project or $Location here; everything else is derived.

$Project  = "mlopspipe"
$Location = "canadacentral"

$ResourceGroup = "rg-$Project"
$Container     = "datasets"
$Tags          = @("project=$Project", "purpose=learning", "owner=$env:USERNAME")

# Storage account names must be globally unique, 3-24 lowercase letters/numbers.
# We add the first 6 characters of your subscription ID so the name is unique
# but stays the same every time you run the scripts.
$SubscriptionId = az account show --query id --output tsv
if (-not $SubscriptionId) { throw "Not logged in. Run 'az login' first." }
$StorageAccount = ("st" + $Project + $SubscriptionId.Substring(0, 6)).ToLower()
