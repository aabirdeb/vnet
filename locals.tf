locals {
  #vnet_name     = "${var.client_name}-${var.environment}-${var.location}-vnet-${var.role}"
  vnet_name     = "${var.client_name}_${var.role}_${var.environment}_vnet_${var.location}"

  publicip_name = "${var.client_name}${var.environment}${var.location}publicip"

  env_tags = {
    "role"        = var.role
    "environment" = var.environment
    "owner"       = var.owner
    "vendor"      = var.vendor
    "application" = var.client_name
    "creator"     = var.creator
  }

  vnet_tags = "${merge(local.env_tags, var.tags)}"

  routetable_assoc = flatten([
    for routetable_key, values in var.routetable_assoc : [
      for val in values : {
        routetable_id = routetable_key
        subnet_id     = val
      }
    ]
  ])

}
