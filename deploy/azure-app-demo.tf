# Configure the Microsoft Azure Active Directory Provider
provider "azuread" {
  version = "=0.7.0"
}

provider "azurerm" {
  version = "=2.10"
  features {}
}

# Create an application
resource "azuread_application" "unidex" {
  name = "UnidexDemo"
}

# Create a service principal
resource "azuread_service_principal" "SP-Unidex-Run" {
  application_id = azuread_application.unidex.application_id
}

resource "azurerm_resource_group" "unidex-demo" {
  name = "rg-unidex-demo"
  location = "Central US"
}

resource "azurerm_app_service_plan" "unidex-demo" {
  name = "asp-unidex-demo"
  location = azurerm_resource_group.unidex-demo.location
  resource_group_name = azurerm_resource_group.unidex-demo.name
  kind = "Linux"
  reserved = true

  sku {
    tier = "Free"
    size = "F1"
  }
}
