terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.17.0"
    }
  }
}
provider "azurerm" {
  environment = "usgovernment"
  features {}
}