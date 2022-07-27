##############################################################################
# Secrets Manager
##############################################################################

resource "ibm_resource_instance" "secrets_manager" {
  count             = var.secrets_manager.use_secrets_manager ? 1 : 0
  name              = var.secrets_manager.name
  service           = "secrets-manager"
  location          = var.region
  plan              = "standard"
  resource_group_id = var.secrets_manager.resource_group == null ? null : local.resource_groups[var.secrets_manager.resource_group]


  parameters = {
    kms_key = (
      lookup(var.secrets_manager, "kms_key_name", null) != null
      ? module.key_management.key_map[var.secrets_manager.kms_key_name].id
      : null
    )
  }

  timeouts {
    create = "1h"
    delete = "1h"
  }

  depends_on = [ibm_iam_authorization_policy.policy]
}

##############################################################################
