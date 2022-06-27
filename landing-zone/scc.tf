##############################################################################
# Security and Compliance Center
##############################################################################

resource "ibm_scc_account_settings" "ibm_scc_account_settings_instance" {
  count = var.security_compliance_center.enable_scc ? 1 : 0
  location {
    location_id = var.security_compliance_center.location_id
  }
}

resource "ibm_scc_posture_collector" "collector" {
  count       = var.security_compliance_center.enable_scc ? 1 : 0
  description = var.security_compliance_center.collector_description
  is_public   = var.security_compliance_center.is_public
  managed_by  = "ibm"
  name        = "${var.prefix}-collector"
}

resource "ibm_scc_posture_scope" "scc_scope" {
  count           = var.security_compliance_center.enable_scc ? 1 : 0
  collector_ids   = [ibm_scc_posture_collector.collector[0].id]
  credential_id   = var.security_compliance_center.credential_id
  credential_type = "ibm"
  description     = var.security_compliance_center.scope_description
  name            = "${var.prefix}-${var.security_compliance_center.scope_name}"
}

##############################################################################