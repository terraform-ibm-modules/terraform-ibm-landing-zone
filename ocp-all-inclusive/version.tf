terraform {
  required_version = ">= 1.0.0"
  experiments      = [module_variable_optional_attrs]
  required_providers {
    # The below tflint-ignores are required because although the below providers are not directly required by this module,
    # they are required by consuming modules, and if not set here, the top level module calling this module will not be
    # able to set alternative alias for the providers.
    # See https://github.ibm.com/GoldenEye/issues/issues/2390 for full details

    # tflint-ignore: terraform_unused_required_providers
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.49.0"
    }
    # tflint-ignore: terraform_unused_required_providers
    external = {
      source  = "hashicorp/external"
      version = ">= 2.2.3"
    }
    # tflint-ignore: terraform_unused_required_providers
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.8.0"
    }
    # tflint-ignore: terraform_unused_required_providers
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16.1"
    }
    # tflint-ignore: terraform_unused_required_providers
    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.3"
    }
    # tflint-ignore: terraform_unused_required_providers
    null = {
      version = ">= 3.2.1"
    }
    # tflint-ignore: terraform_unused_required_providers
    time = {
      version = ">= 0.9.1"
    }
  }
}
