############################################################################################################################################
# The following moved blocks allow consumers to upgrade the module from v3.5.1 or older without destroying the existing flow logs collector
# For more details, please refer - https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc/issues/379
############################################################################################################################################

moved {
  from = ibm_is_flow_log.flow_logs["management"]
  to   = module.vpc["management"].ibm_is_flow_log.flow_logs[0]
}

moved {
  from = ibm_is_flow_log.flow_logs["workload"]
  to   = module.vpc["workload"].ibm_is_flow_log.flow_logs[0]
}

moved {
  from = ibm_iam_authorization_policy.policy["flow-logs-atracker-cos-cos"]
  to   = ibm_iam_authorization_policy.policy["flow-logs-atracker-cos"]
}

moved {
  from = ibm_iam_authorization_policy.policy["flow-logs-cos-cos"]
  to   = ibm_iam_authorization_policy.policy["flow-logs-cos"]
}
