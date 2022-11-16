targetScope = 'subscription'

param fqdn string
param chainId int
param location string = 'centralus'
param rgName string = 'truffle_demo'
param swaName string = 'web3swa'
param repoUrl string
param deployGanache bool = false

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module ganache './ganache.bicep' = if (deployGanache)  {
  name: 'ganache'
  scope: resourceGroup(rg.name)
  params: {
    fqdn: fqdn
    chainId: chainId
    location: location
  }
}

output ganacheIp string = (deployGanache) ? ganache.outputs.ganacheIp : ''
output ganacheName string = (deployGanache) ? ganache.outputs.ganacheName : ''
output ganacheFqdn string = (deployGanache) ? ganache.outputs.ganacheFqdn : ''

module web3swa './swa.bicep' = {
  name: swaName
  scope: resourceGroup(rg.name)
  params: {
    repoUrl: repoUrl
    location: location
  }
}

output swaName string = web3swa.outputs.swaName
output deploymentToken string = web3swa.outputs.deploymentToken
