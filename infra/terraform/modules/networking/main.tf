# =============================================================================
# VNet and Subnets for Private Endpoint Deployment

# =============================================================================

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "backend" {
  name                 = "backend-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.0.0/24"]

  private_endpoint_network_policies = "Enabled"
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/23"]

  delegation {
    name = "container-apps"
    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "gateway" {
  count                = var.use_vpn_gateway ? 1 : 0
  name                 = "GatewaySubnet" # Must be named exactly GatewaySubnet
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.3.0/27"]
}

resource "azurerm_subnet" "dns_resolver" {
  count                = var.use_vpn_gateway ? 1 : 0
  name                 = "dns-resolver-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.4.0/28"]

  delegation {
    name = "dns-resolver"
    service_delegation {
      name = "Microsoft.Network/dnsResolvers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_network_security_group" "backend" {
  name                = "${var.vnet_name}-backend-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "backend" {
  subnet_id                 = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.backend.id
}

# VPN Gateway (optional)
resource "azurerm_public_ip" "gateway" {
  count               = var.use_vpn_gateway ? 1 : 0
  name                = "${var.vpn_gateway_name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "this" {
  count               = var.use_vpn_gateway ? 1 : 0
  name                = var.vpn_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"
  tags                = var.tags

  ip_configuration {
    name                 = "default"
    public_ip_address_id = azurerm_public_ip.gateway[0].id
    subnet_id            = azurerm_subnet.gateway[0].id
  }

  vpn_client_configuration {
    address_space = ["172.16.0.0/24"]
    vpn_client_protocols = ["OpenVPN"]

    root_certificate {
      name             = "P2SRootCert"
      public_cert_data = ""
    }
  }
}

# DNS Resolver (optional — for VPN clients to resolve private DNS)
resource "azurerm_private_dns_resolver" "this" {
  count               = var.use_vpn_gateway ? 1 : 0
  name                = var.dns_resolver_name
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_network_id  = azurerm_virtual_network.this.id
  tags                = var.tags
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "this" {
  count                   = var.use_vpn_gateway ? 1 : 0
  name                    = "${var.dns_resolver_name}-inbound"
  private_dns_resolver_id = azurerm_private_dns_resolver.this[0].id
  location                = var.location
  tags                    = var.tags

  ip_configurations {
    subnet_id = azurerm_subnet.dns_resolver[0].id
  }
}
