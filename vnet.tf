resource "azurerm_virtual_network" "this" {
  name                = local.vnet_name
  location            = var.location
  address_space       = [var.cidr_range]
  resource_group_name = var.resource_group_name
  dns_servers         = var.dns_servers
  tags                = local.vnet_tags
}

resource "azurerm_subnet" "this" {
  for_each                                       = var.subnets
  name                                           = each.key
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.this.name
  address_prefixes                               = split(",", lookup(each.value, "cidr", ""))
  service_endpoints                              = lookup(each.value, "service-endpoint", null) == null ? null : var.serviceendpoint
  /* enforce_private_link_endpoint_network_policies = lookup(each.value, "enforce_private_link_endpoint_network_policies", null) == null ? false : each.value.enforce_private_link_endpoint_network_policies */
  private_endpoint_network_policies_enabled = lookup(each.value, "private_endpoint_network_policies_enabled", null) == null ? false : each.value.private_endpoint_network_policies_enabled

}


resource "azurerm_application_security_group" "this" {
  for_each            = { for v in var.asgs : v => v }
  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = local.vnet_tags
}

resource "azurerm_network_interface" "this" {

  for_each             = var.nics
  name                 = each.key
  location             = var.location
  resource_group_name  = var.resource_group_name
  enable_ip_forwarding = lookup(each.value, "enable_ip_forwarding", "true")

  ip_configuration {
    name                          = lookup(each.value, "name")
    subnet_id                     = azurerm_subnet.this[lookup(each.value, "subnet_id")].id
    private_ip_address_allocation = lookup(each.value, "private_ip_address_allocation", "")
    private_ip_address            = lookup(each.value, "private_ip_address", "")
    public_ip_address_id          = lookup(each.value, "public_ip_address_id", null) == null ? null : azurerm_public_ip.this[each.value.public_ip_address_id].id
  }

  tags = local.vnet_tags

  depends_on = [azurerm_subnet.this]
}

resource "azurerm_network_interface_application_security_group_association" "this" {

  for_each = { for k, v in var.nics :
    k => v
    if v.asg_id != ""
  }
  network_interface_id          = azurerm_network_interface.this[each.key].id
  application_security_group_id = azurerm_application_security_group.this[each.value.asg_id].id
}

resource "azurerm_network_security_group" "this" {

  for_each = { for nsg in var.nsgs :
    nsg.name => nsg
  }
  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = each.value.rules

    content {
      name                                       = security_rule.value.name
      priority                                   = security_rule.value.priority
      direction                                  = security_rule.value.direction
      access                                     = security_rule.value.access
      protocol                                   = security_rule.value.protocol
      source_port_range                          = security_rule.value.source_port_range
      destination_port_range                     = security_rule.value.destination_port_range
      source_application_security_group_ids      = lookup(security_rule.value, "source_application_security_group_ids", null) == null ? null : [azurerm_application_security_group.this[security_rule.value.source_application_security_group_ids].id]
      source_address_prefix                      = lookup(security_rule.value, "source_address_prefix", "")
      destination_address_prefix                 = lookup(security_rule.value, "destination_address_prefix", "")
      destination_application_security_group_ids = lookup(security_rule.value, "destination_application_security_group_ids", null) == null ? null : [azurerm_application_security_group.this[security_rule.value.destination_application_security_group_ids].id]
    }
  }
  tags = local.vnet_tags
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = { for k, v in var.subnets :
    k => v
    if v.nsg-association != ""
  }
  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.value.nsg-association].id
}

resource "azurerm_route_table" "this" {
  for_each = { for route in var.routetables :
    route.name => route
  }
  disable_bgp_route_propagation = var.disable_bgp_route_propagation
  name                          = each.key
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tags                          = local.vnet_tags

  dynamic "route" {
    for_each = each.value.routes
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = lookup(route.value, "next_hop_in_ip_address", null) == null ? null : route.value.next_hop_in_ip_address
    }
  }
}

resource "azurerm_subnet_route_table_association" "this" {

  for_each = { for k, v in var.subnets :
    k => v
    if v.route-table != ""
  }

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = azurerm_route_table.this[each.value.route-table].id
}

resource "azurerm_public_ip" "this" {
  for_each            = var.publicips
  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = lookup(each.value, "allocation_method")
  domain_name_label   = format("%s%s", local.publicip_name, lookup(each.value, "domain_name_label"))
  sku                 = lookup(each.value, "publicipsku", "Basic")
  tags = local.vnet_tags
}
