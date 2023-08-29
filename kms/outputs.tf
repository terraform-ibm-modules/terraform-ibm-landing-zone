##############################################################################
# KMS Outputs
##############################################################################

output "key_management_name" {
  description = "Name of key management service"
  value       = var.key_management.use_hs_crypto == true ? data.ibm_resource_instance.hpcs_instance[0].name : var.key_management.use_data == true ? data.ibm_resource_instance.kms[0].name : var.key_management.name == null ? null : ibm_resource_instance.kms[0].name
}

output "key_management_crn" {
  description = "CRN for KMS instance"
  value       = var.key_management.use_hs_crypto == true ? data.ibm_resource_instance.hpcs_instance[0].crn : var.key_management.use_data == true ? data.ibm_resource_instance.kms[0].crn : var.key_management.name == null ? null : ibm_resource_instance.kms[0].crn
}

output "key_management_guid" {
  description = "GUID for KMS instance"
  value       = local.key_management_guid
}

##############################################################################


##############################################################################
# Key Rings
##############################################################################

output "key_rings" {
  description = "Key rings created by module"
  value       = ibm_kms_key_rings.rings
}

##############################################################################


##############################################################################
# Keys
# Combine lists of provisioned keys and pre-existing keys (supplied with CRNs)
##############################################################################

output "keys" {
  description = "List of names and ids for keys configured."
  value = concat([
    for kms_key in local.keys_to_create :
    {
      name   = kms_key.name
      id     = ibm_kms_key.key[kms_key.name].id
      crn    = ibm_kms_key.key[kms_key.name].crn
      key_id = ibm_kms_key.key[kms_key.name].key_id
    }
    ],
    [
      for kms_key in local.existing_keys :
      {
        name = kms_key.name
        id   = kms_key.crn # For keys the id an CRN are the same
        crn  = kms_key.crn
      }
  ])
}

output "key_map" {
  description = "Map of ids and keys for keys configured"
  value = merge({
    for kms_key in local.keys_to_create :
    (kms_key.name) => {
      name   = kms_key.name
      id     = ibm_kms_key.key[kms_key.name].id
      crn    = ibm_kms_key.key[kms_key.name].crn
      key_id = ibm_kms_key.key[kms_key.name].key_id
    }
    },
    {
      for kms_key in local.existing_keys :
      (kms_key.name) => {
        name = kms_key.name
        id   = kms_key.crn # For keys the id an CRN are the same
        crn  = kms_key.crn
      }
    }
  )
}

##############################################################################
