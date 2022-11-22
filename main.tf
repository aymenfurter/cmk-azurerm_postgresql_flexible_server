resource "random_pet" "rg-name" {
  prefix = var.name_prefix
}

resource "azurerm_resource_group" "default" {
  name     = random_pet.rg-name.id
  location = var.location
}

resource "azurerm_virtual_network" "default" {
  name                = "${var.name_prefix}-vnet"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_network_security_group" "default" {
  name                = "${var.name_prefix}-nsg"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet" "default" {
  name                 = "${var.name_prefix}-subnet"
  virtual_network_name = azurerm_virtual_network.default.name
  resource_group_name  = azurerm_resource_group.default.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "default" {
  subnet_id                 = azurerm_subnet.default.id
  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_private_dns_zone" "default" {
  name                = "${var.name_prefix}-pdz.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.default.name

  depends_on = [azurerm_subnet_network_security_group_association.default]
}

resource "azurerm_private_dns_zone_virtual_network_link" "default" {
  name                  = "${var.name_prefix}-pdzvnetlink.com"
  private_dns_zone_name = azurerm_private_dns_zone.default.name
  virtual_network_id    = azurerm_virtual_network.default.id
  resource_group_name   = azurerm_resource_group.default.name
}

/*
This was the previous Terraform Configuration using standard terraform provider

resource "azurerm_postgresql_flexible_server" "default" {
  name                   = "${var.name_prefix}-server"
  resource_group_name    = azurerm_resource_group.default.name
  location               = azurerm_resource_group.default.location
  version                = "13"
  delegated_subnet_id    = azurerm_subnet.default.id
  private_dns_zone_id    = azurerm_private_dns_zone.default.id
  administrator_login    = "myusername"
  administrator_password = "mypassword"
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  backup_retention_days  = 7

  depends_on = [azurerm_private_dns_zone_virtual_network_link.default]
}*/

resource "azapi_resource" "default" {
  type = "Microsoft.DBforPostgreSQL/flexibleServers@2022-03-08-preview"
  name = "${var.name_prefix}-server"
  location = azurerm_resource_group.default.location
  parent_id = azurerm_resource_group.default.id
  depends_on = [azurerm_private_dns_zone_virtual_network_link.default]
  identity {
    type = "UserAssigned"
    identity_ids = ["/subscriptions/<uuid>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<identity>"]
  }
  body = jsonencode({
    properties = {
      administratorLogin = "myusername"
      administratorLoginPassword = "mypassword"
      availabilityZone = "2"
      backup = {
        backupRetentionDays = 7
        geoRedundantBackup = "Disabled"
      }
      createMode = "Default"
      network = {
        delegatedSubnetResourceId = azurerm_subnet.default.id
        privateDnsZoneArmResourceId = azurerm_private_dns_zone.default.id
      }            
      storage = {
        storageSizeGB = 128
      }
      dataEncryption = {
        type = "AzureKeyVault"
        primaryUserAssignedIdentityId = "/subscriptions/<uuid>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<identity>",
        primaryKeyURI = "https://<vault>.vault.azure.net/keys/<key>/<keyversion>"
      }
      maintenanceWindow = {
        customWindow: "Disabled"
      } 
      version = "14"
    }
    sku = {
      name = "Standard_D2ds_v4"
      tier = "GeneralPurpose"
    }
  })
}

resource "azurerm_postgresql_flexible_server_database" "default" {
  name      = "${var.name_prefix}-db"
  server_id = azapi_resource.default.id
  collation = "en_US.UTF8"
  charset   = "UTF8"
}

variable "name_prefix" {
  default     = "yourcmkprefix"
  description = "Prefix of the resource name."
}

variable "location" {
  default     = "switzerlandnorth"
  description = "Location of the resource."
}