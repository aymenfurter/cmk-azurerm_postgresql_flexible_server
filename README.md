# cmk-azurerm_postgresql_flexible_server
This repository contains Terraform configurations for using the PostgreSQL Preview Features using the AzAPI Provider.

```
Terraform will perform the following actions:

  # azapi_resource.default will be created
  + resource "azapi_resource" "default" {
      + body                      = jsonencode(
            {
              + properties = {
                  + administratorLogin         = "<username>"
                  + administratorLoginPassword = "<password>"
                  + availabilityZone           = "2"
                  + backup                     = {
                      + backupRetentionDays = 7
                      + geoRedundantBackup  = "Disabled"
                    }
                  + createMode                 = "Default"
                  + dataEncryption             = {
                      + primaryKeyURI                 = "https://<keyvault>.vault.azure.net/keys/<key>/<key-version>"
                      + primaryUserAssignedIdentityId = "/subscriptions/<uuid>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<identity>"
                      + type                          = "AzureKeyVault"
                    }
                  + maintenanceWindow          = {
                      + customWindow = "Disabled"
                    }
                  + network                    = {
                      + delegatedSubnetResourceId   = "/subscriptions/<uuid>/resourceGroups/cmktest-quiet-egret/providers/Microsoft.Network/virtualNetworks/<prefix>-vnet/subnets/cmktest-subnet"
                      + privateDnsZoneArmResourceId = "/subscriptions/<uuid>/resourceGroups/cmktest-quiet-egret/providers/Microsoft.Network/privateDnsZones/<prefix>-pdz.postgres.database.azure.com"
                    }
                  + storage                    = {
                      + storageSizeGB = 128
                    }
                  + version                    = "14"
                }
              + sku        = {
                  + name = "Standard_D2ds_v4"
                  + tier = "GeneralPurpose"
                }
            }
        )
      + id                        = (known after apply)
      + ignore_casing             = false
      + ignore_missing_property   = true
      + location                  = "switzerlandnorth"
      + name                      = "<yourprefix>-server"
      + output                    = (known after apply)
      + parent_id                 = "/subscriptions/<uuid>/resourceGroups/<rg>"
      + schema_validation_enabled = true
      + tags                      = (known after apply)
      + type                      = "Microsoft.DBforPostgreSQL/flexibleServers@2022-03-08-preview"

      + identity {
          + identity_ids = [
              + "/subscriptions/<uuid>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<identity>",
            ]
          + principal_id = (known after apply)
          + tenant_id    = (known after apply)
          + type         = "UserAssigned"
        }
    }
```  
    
