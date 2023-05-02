variable role {
  description = "This determines the purpose of vnet. Example dmz, aks, transit etc"
  default     = "unknown"
}

variable client_name {
  description = "This determines the client. Ex - Voyager, Mars, Dr.Comp"
  default     = "unknown"
}

variable resource_group_name {
  description = "Default resource group name that the network will be created in."
}

variable location {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
}


variable cidr_range {
  description = "The address space that is used by the virtual network."
  default     = "10.0.0.0/16"
}

# If no values specified, this defaults to Azure DNS
variable dns_servers {
  description = "The DNS servers to be used with vNet."
  type        = list(string)
  default     = []
}


variable environment {
  description = "Target environment"
}

variable tags {
  description = "The tags to associate with your network and subnets."
  type        = map(string)
}



variable subnets {
  description = "Map of subnet objects. name, cidr, and service_endpoints supported"
  type        = map(any)
  default     = {}
}

variable publicips {
  type    = map(any)
  default = {}
}


variable routetable_assoc {
  type    = map(any)
  default = {}
}

variable nics {
  type    = map(any)
  default = {}
}

variable appgateway {
  type    = list(any)
  default = []
}

variable serviceendpoint {
  type    = list(any)
  default = ["Microsoft.Storage"]
}

variable bastionhost {
  type    = map(any)
  default = {}
}

variable virtualmachines {
  type    = map(any)
  default = {}
}


variable asgs {
  type    = list(any)
  default = []
}

variable routetables {
  description = "Route Tables along with routes"
  type        = list(any)
  default     = []
}

variable nsgs {
  description = "Network security_groups along with rules"
  type        = list(any)
  default     = []
}


variable priority {
  description = "priority of the vnet to create"
  default     = "unknown"
}

variable direction {
  description = "direction of the vnet to create"
  default     = "unknown"
}

variable access {
  description = "access of the vnet to create"
  default     = "unknown"
}

variable protocol {
  description = "protocol of the vnet to create"
  default     = "unknown"
}

variable disable_bgp_route_propagation {
  description = "Boolean value indicating if route propagation is needed"
  default     = false
}




variable backend_address_pool_name {
  description = "backend_address_pool_name"
  default     = "unknown"
}

variable "keyvaultcert" {
  type    = map(any)
  default = {}
}


variable "tenantid" {
  description = "Target environment"
  default     = "unknown"
}

variable "skuname" {
  description = "Target environment"
  default     = "unknown"
}

variable "objectid" {
  description = "Target environment"
  default     = "unknown"
}

variable "keyVault" {
  description = "Map of keyvault"
  type        = list(any)
  default     = []
}

variable "certname" {
  description = "Target environment"
  default     = "self-signed-cert"
}

variable "keyvaultname" {
  description = "Target environment"
  default     = "nonprod-kv-vca"
}

variable "publicipsku" {
  description = "Target environment"
  default     = "Basic"
}

variable owner {
  description = "POC for this project"
  default     = "unknown"

}

variable vendor {
  description = "Service provider responsible for project"
  default     = "unknown"

}

variable creator {
  description = "Person/Team responsible for resource"
  default     = "unknown"

}
