##############################################################################
# Account Variables
##############################################################################

variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a lowercase letter and end with a lowerccase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string
  default     = "extra-simple"

  validation {
    error_message = "Prefix must begin with a lowercase letter and contain only lowercase letters, numbers, and - characters. Prefixes must end with a lowercase letter or number and be 16 or fewer characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix)) && length(var.prefix) <= 16
  }
}

variable "region" {
  description = "Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions."
  type        = string
  default     = "au-syd"
}

variable "ssh_key" {
  description = "Public SSH Key for VSI creation. Must be a valid SSH key that does not already exist in the deployment region."
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCVkYLJNTnn/APuRVbEFE/6/HtiUaF3HKQG5Zk7z8xm1ZbyEB+XppuH3sUagWsA4POjE7n/kwiuYtKl9Dxkut3/5DfTklFxx1HD6DL70lGV7dhp2soNQRpSHkztr8umbK6xFOlkhmmQMrz3UkaK6C201oXeBztbTuCcPNW2IUhkWlcCrDROnGjP7V6WNu+9vHEi8s0Dhh84CrcQ5ZMaT4tg+sShIV3kJe/04Wo2Z4J1WhTSAaJc64ZKzcNF3+t+0yesGLM0SiCLALsGJx3Qq85ZHeVFUo5yvpdUVyVxMNdXp5+YF5PThYsGbHubshj3O2QvBYDLgsb2A3E/O5gXvBedX/06J0gnme/Fs9CM3gs/dDOIxKDaH9bRpG6fOSfjCfPZmP6Itnxxy5LO2ZQKPdk6wLe2yvHuerIWjLd+3XK4OhgnQujKw2LPcbsNQAt7205HrRYu7PWbBjL7GdB8ZcT7wjfti2xYqa1ltpuMiC3kraTXlNT0hIW4lgbZMqUs4fRyLdJgUvI1ptlgq7DYVR7XmuLnQ9/2b3MURSIIIqdtNs9gunR7BkLalzT/W1OH8g8RS09gL6E3uq1SgefsOhGUzamOqgMyZ23KPJmgrQgYbb/wS4VryWjU+Z6FKIUZKXEVV/c1/ViynjcENK9Fyt5ddaMcRY1ZoihtmKg0pozgrQ== aashiq.jacob@ibm.com"
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}
