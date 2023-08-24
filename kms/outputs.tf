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
##############################################################################

output "keys" {
  description = "List of names and ids for keys created."
  value = concat([
    for kms_key in var.keys :
    {
      name   = kms_key.name
      id     = ibm_kms_key.key[kms_key.name].id
      crn    = ibm_kms_key.key[kms_key.name].crn
      key_id = ibm_kms_key.key[kms_key.name].key_id
    } if lookup(kms_key, "crn", null) == null
    ],
    [
      for kms_key in var.keys :
      {
        name = kms_key.name
        crn  = kms_key.crn
      } if lookup(kms_key, "crn", null) != null
    ]
  )
}

output "key_map" {
  description = "Map of ids and keys for keys created"
  value = merge({
    for kms_key in var.keys :
    (kms_key.name) => {
      name   = kms_key.name
      id     = ibm_kms_key.key[kms_key.name].id
      crn    = ibm_kms_key.key[kms_key.name].crn
      key_id = ibm_kms_key.key[kms_key.name].key_id
    } if lookup(kms_key, "crn", null) == null
    },
    {
      for kms_key in var.keys :
      (kms_key.name) => {
        name = kms_key.name
        crn  = kms_key.crn
      } if lookup(kms_key, "crn", null) != null
  })
}

##############################################################################
