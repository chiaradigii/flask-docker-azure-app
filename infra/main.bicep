param keyVaultName string
param containerRegistryName string
param containerRegistryImageName string
param containerRegistryImageVersion string = 'main-latest'
param appServicePlanName string
param siteName string
param location string = resourceGroup().location
param keyVaultSecretNameACRUsername string = 'acr-username'
param keyVaultSecretNameACRPassword1 string = 'acr-password1'
param keyVaultSecretNameACRPassword2 string = 'acr-password2'

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}
module containerRegistry 'modules/container-registry/registry/main.bicep' = {
  dependsOn: [
    keyvault
  ]
  name: '${uniqueString(deployment().name)}acr'
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
    adminCredentialsKeyVaultResourceId: resourceId('Microsoft.KeyVault/vaults', keyVaultName)
    adminCredentialsKeyVaultSecretUserName: keyVaultSecretNameACRUsername
    adminCredentialsKeyVaultSecretUserPassword1: keyVaultSecretNameACRPassword1
    adminCredentialsKeyVaultSecretUserPassword2: keyVaultSecretNameACRPassword2
  }
}


module serverfarm 'modules/web/serverfarm/main.bicep' = {
  name: '${uniqueString(deployment().name)}-asp'
  params: {
    name: appServicePlanName
    location: location
    sku: {
      capacity: '1'
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    reserved: true
  }
}

module website 'modules/web/site/main.bicep' = {
  dependsOn: [
    containerRegistry
    serverfarm
    keyvault
  ]
  name: '${uniqueString(deployment().name)}-site'
  params: {
    name: siteName
    location: location
    kind: 'app'
    serverFarmResourceId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
    }
    dockerRegistryServerUrl: 'https://${containerRegistryName}.azurecr.io'
    dockerRegistryServerUserName: keyvault.getSecret(keyVaultSecretNameACRUsername)
    dockerRegistryServerPassword: keyvault.getSecret(keyVaultSecretNameACRPassword1)
  }
}
