param keyVaultName string
param location string = resourceGroup().location

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: []
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
  }
}

param acrUsernameSecretName string = 'acr-username'
param acrPassword1SecretName string = 'acr-password1'
param acrPassword2SecretName string = 'acr-password2'

resource acrUsernameSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: acrUsernameSecretName
  properties: {
    value: '<your-acr-username>'
  }
}

resource acrPassword1Secret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: acrPassword1SecretName
  properties: {
    value: '<your-acr-password1>'
  }
}

resource acrPassword2Secret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: acrPassword2SecretName
  properties: {
    value: '<your-acr-password2>'
  }
}

output keyVaultResourceId string = keyVault.id
