// Licensed under the MIT license.

// This template is used to create network resources.
targetScope = 'resourceGroup'

// Parameters
param location string
param prefix string
param tags object
param vnetAddressPrefix string = '10.2.0.0/16'

param servicesSubnetAddressPrefix string = '10.2.1.0/24'

param functionSubnetAddressPrefix string = '10.2.2.0/24'
param dnsServers array

// Variables
var servicesSubnetName = 'ServicesSubnet'
var functionSubnetName = 'FunctionSubnet'
var routeTableName = '${prefix}-routetable'
var nsgName = '${prefix}-nsg'

// Resources
resource routeTable 'Microsoft.Network/routeTables@2020-11-01' = {
  name: routeTableName
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: false
    routes: []
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: '${prefix}-vnet'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: dnsServers
    }
    enableDdosProtection: false
    subnets: [
      {
        name: servicesSubnetName
        properties: {
          addressPrefix: servicesSubnetAddressPrefix
          addressPrefixes: []
          networkSecurityGroup: {
            id: nsg.id
          }
          routeTable: {
            id: routeTable.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
          serviceEndpointPolicies: []
          serviceEndpoints: []
        }
      }
      {
        name: functionSubnetName
        properties: {
          addressPrefix: functionSubnetAddressPrefix
          addressPrefixes: []
          networkSecurityGroup: {
            id: nsg.id
          }
          routeTable: {
            id: routeTable.id
          }
          delegations: [
            {
              name: 'AppServicePlanDelegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          serviceEndpointPolicies: []
          serviceEndpoints: []
        }
      }
    ]
  }
}

// Outputs
output servicesSubnetId string = vnet.properties.subnets[0].id
output functionSubnetId string = vnet.properties.subnets[1].id
