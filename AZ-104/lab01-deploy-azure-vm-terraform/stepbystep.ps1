# LAB VM Deploy using Terraform

# Install Terraform
winget install --id Hashicorp.Terraform  -e

# Verify Terraform installation
terraform -version

# Install the Azure PowerShell module
Install-Module -Name Az -Repository PSGallery -Force

# Log in to Azure
Connect-AzAccount
az login #AZ CLI

# Set the subscription context
Set-AzContext -Subscription "45c0820c-add4-4b9a-bc72-db6b8141ce97"
az account set --subscription "subscription-id" #AZ CLI

# Verify the current context
Get-AzContext
az account show #AZ CLI

# Create a service principal for Terraform
az ad sp create-for-rbac --name pzTerraform --role="Contributor" --scopes="/subscriptions/45c0820c-add4-4b9a-bc72-db6b8141ce97"

# {
#   "appId": "15fa78d8-7806-4d27-978d-8a9b7922d0ab",
#   "displayName": "pzTerraform",
#   "password": "B6w8Q~JPWmX65lQ0G0R4~WrDSQIz4-2q_aNzUbme",
#   "tenant": "877b2d19-c5a4-4326-8e3d-b9bf32f6c2fe"
# }

# Set environment variables for Terraform authentication
$Env:ARM_CLIENT_ID = "15fa78d8-7806-4d27-978d-8a9b7922d0ab"
$Env:ARM_CLIENT_SECRET = "B6w8Q~JPWmX65lQ0G0R4~WrDSQIz4-2q_aNzUbme"
$Env:ARM_SUBSCRIPTION_ID = "45c0820c-add4-4b9a-bc72-db6b8141ce97"
$Env:ARM_TENANT_ID = "877b2d19-c5a4-4326-8e3d-b9bf32f6c2fe"

# Create Terraform project structure
& '.\templates\Terraform file structure.ps1'

# Comandos Utiles
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
terraform state list
terraform show
terraform output
terraform apply -auto-approve -var "" 

terraform plan -out vm.out
time terraform destroy -auto-approve

# Generate SSH key pair for VM access
ssh-keygen -t rsa -b 4096 -C "azure-lab-rsa" -f $env:USERPROFILE\.ssh\azure_lab_rsa

# Get your public IP address in CIDR notation
$myIp = (Invoke-RestMethod -Uri "https://api.ipify.org?format=json").ip; "$myIp/32"

# Clean up environment variables
Remove-Item Env:\ARM_CLIENT_ID
Remove-Item Env:\ARM_CLIENT_SECRET
Remove-Item Env:\ARM_SUBSCRIPTION_ID
Remove-Item Env:\ARM_TENANT_ID


