##############################################################################
# Terraform Providers
##############################################################################

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      # Atracker needs to have the v2 API
      version = ">= 1.45.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.2.2"
    }
  }
  required_version = ">=1.0"
  experiments      = [module_variable_optional_attrs]
}

##############################################################################
