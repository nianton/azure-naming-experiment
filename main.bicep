param naming object
param location string = resourceGroup().location
param tags object

var resourceNames = {
  appServicePlan: naming.appServicePlan.name
  webApp: naming.appService.name
  storageAccount: naming.storageAccount.name
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: resourceNames.appServicePlan
  location: location
  tags: tags
  sku: {
    name: 'F1'
    capacity: 1
  }
}

resource webApplication 'Microsoft.Web/sites@2018-11-01' = {
  name: resourceNames.webApp
  location: location
  tags: union({
    'hidden-related:${resourceGroup().id}/providers/Microsoft.Web/serverfarms/${appServicePlan.name}': 'Resource'
  }, tags)
  properties: {
    serverFarmId: appServicePlan.id
  }
}

module storage 'modules/storage.module.bicep' = {
  name: 'StorageAccountDeployment'
  params: {
    location: location
    kind: 'StorageV2'
    skuName: 'Standard_LRS'
    name: resourceNames.storageAccount
    tags: tags
  }
}

output storageAccountName string = storage.outputs.name
output appServiceName string = webApplication.name
output appServicePlanName string = appServicePlan.name
