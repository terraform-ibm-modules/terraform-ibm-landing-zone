##############################################################################
# Terraform Providers
##############################################################################

terraform {
  required_version = ">= 1.3"
  # renovate is set up to keep provider version at the latest for all DA solutions
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.76.1"
    }
    # tflint-ignore: terraform_unused_required_providers
    external = {
      source  = "hashicorp/external"
      version = "2.3.4"
    }
  }
}

##############################################################################
