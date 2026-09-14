targetScope = 'resourceGroup'

@description('Globally unique Azure Web App name.')
param appName string

@description('Azure region for the App Service resources.')
param location string = resourceGroup().location

@description('App Service plan SKU name.')
@allowed([
  'F1'
  'B1'
  'B2'
  'B3'
])
param planSkuName string = 'B1'

var planSkuTier = startsWith(planSkuName, 'F') ? 'Free' : 'Basic'
var planName = '${appName}-plan'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: planName
  location: location
  sku: {
    name: planSkuName
    tier: planSkuTier
    size: planSkuName
    family: startsWith(planSkuName, 'F') ? 'F' : 'B'
    capacity: 1
  }
  kind: 'app'
  properties: {
    reserved: false
  }
}

resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: appName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      defaultDocuments: [
        'index.html'
        'Default.htm'
        'default.htm'
      ]
      http20Enabled: true
      minTlsVersion: '1.2'
    }
  }
}

output webAppName string = webApp.name
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
