# Configure the Microsoft Azure Active Directory Provider
provider "azuread" {
  version = "=0.7.0"
}

provider "azurerm" {
  version = "=2.10"
  features {}
}

provider "github" {
  token = var.github-token
  organization = var.app-repo-org
  individual = false
  version = "~> 2.8"
}

provider "random" {
  version = "~> 2.2"
}


# Generate a random password for the deployer SP
resource "random_password" "deployer-password" {
  length = 24
  special = true
  override_special = "!#$%^&*()"
}

data "azurerm_client_config" "current" {
}

# Create the Unidex application
resource "azuread_application" "unidex" {
  name = "UnidexDemo"
}

# Create an application for the Unidex deployer
resource "azuread_application" "unidex-deployer" {
  name = "UnidexDeploy"
}

# Create a service principal to deploy the application
resource "azuread_service_principal" "SP-Unidex-Deploy" {
  application_id = azuread_application.unidex-deployer.application_id
}

# Set a password that will by synced to a Github Action secret
resource "azuread_service_principal_password" "SP-Unidex-Deploy-Password" {
  service_principal_id = azuread_service_principal.SP-Unidex-Deploy.id
  value = random_password.deployer-password.result
  # expire after 30 days
  end_date_relative = "720h"
}

resource "azurerm_resource_group" "rg-unidex-demo" {
  name = "rg-unidex-demo"
  location = "Central US"
}

resource "azurerm_user_assigned_identity" "SP-Unidex-Run" {
  name = "SP-Unidex-Run"
  resource_group_name = azurerm_resource_group.rg-unidex-demo.name
  location = azurerm_resource_group.rg-unidex-demo.location
}

resource "azurerm_app_service_plan" "asp-unidex-demo" {
  name = "asp-unidex-demo"
  location = azurerm_resource_group.rg-unidex-demo.location
  resource_group_name = azurerm_resource_group.rg-unidex-demo.name
  kind = "Linux"
  reserved = true

  sku {
    tier = "Free"
    size = "F1"
  }

}

resource "azurerm_app_service" "as-unidex-demo" {
  name = "as-unidex-demo"
  location = azurerm_resource_group.rg-unidex-demo.location
  resource_group_name = azurerm_resource_group.rg-unidex-demo.name
  app_service_plan_id = azurerm_app_service_plan.asp-unidex-demo.id

  site_config {
    dotnet_framework_version = "v4.0"
    use_32_bit_worker_process = true
    linux_fx_version = "DOTNETCORE|3.1"
  }

  identity {
    type = "SystemAssigned"
    identity_ids = [azurerm_user_assigned_identity.SP-Unidex-Run.id]
  }
}

resource "azurerm_role_assignment" "SP-Unidex-Deploy-Contributor" {
  scope = azurerm_app_service.as-unidex-demo.id
  role_definition_name = "Contributor"
  principal_id = azuread_service_principal.SP-Unidex-Deploy.object_id
}

resource "github_actions_secret" "SP-Unidex-Deploy-Password" {
  repository = var.app-repo
  secret_name = "SP_Unidex_Deploy_Password"
  plaintext_value = <<EOS
{
  "clientId": "${ azuread_service_principal.SP-Unidex-Deploy.application_id }",
  "clientSecret": "${ random_password.deployer-password.result }",
  "subscriptionId": "${ data.azurerm_client_config.current.subscription_id }",
  "tenantId": "${ data.azurerm_client_config.current.tenant_id }",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
EOS
}
