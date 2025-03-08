##############################################################################
# Terraform Providers
##############################################################################

terraform {
  required_version = ">= 1.9"
  # Pin to the lowest provider version of the range defined in the main module's version.tf to ensure lowest version still works
  required_providers {
    # tflint-ignore: terraform_unused_required_providers
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.76.1"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.4"
    }
  }
}

##############################################################################
