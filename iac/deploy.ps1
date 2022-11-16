[CmdletBinding()]
param (
    [Parameter(Position = 0)]
    [string]
    $rgName = "Web3DevOps_dev",

    [Parameter(Position = 1)]
    [string]
    $location = "centralus",

    [string]
    $repoUrl,

    [string]
    $fqdn,

    [int]
    $chainId = 1385,

    [switch]
    $deployGanache
)

Write-Verbose $repoUrl

Write-Output "Deploying the Azure infrastructure"

$useGanache = $($deployGanache.IsPresent.ToString())

$deployment = $(az deployment sub create --name $rgName `
                --location $location `
                --template-file ./main.bicep `
                --parameters fqdn=$fqdn `
                --parameters chainId=$chainId `
                --parameters location=$location `
                --parameters rgName=$rgName `
                --parameters repoUrl=$repoUrl `
                --parameters deployGanache=$useGanache `
                --output json) | ConvertFrom-Json

if ($deployGanache.IsPresent) {
    $ganacheIp = $deployment.properties.outputs.ganacheIp.value
    $ganacheName = $deployment.properties.outputs.ganacheName.value
    $ganacheFqdn = $deployment.properties.outputs.ganacheFqdn.value

    Write-Host "The IP of Ganache is http://$($ganacheIp):8545"
    Write-Host "The FQDN of Ganache is http://$($deployment.properties.outputs.ganacheFqdn.value):8545"
    Write-Host "The Name of Ganache is: $ganacheName"
    Write-Host "The Fqdn of Gnache is: $ganacheFqdn"

    # write to GitHub ENV for refereced by other steps
    Add-Content -Path $env:GITHUB_ENV -value "ganacheIp=$ganacheIp"
    Add-Content -Path $env:GITHUB_ENV -value "ganacheName=$ganacheName"
    Add-Content -Path $env:GITHUB_ENV -value "ganacheFqdn=$ganacheFqdn"
}

$swaName = $deployment.properties.outputs.swaName.value
$deploymentToken = $deployment.properties.outputs.deploymentToken.value
Write-Host "the name of swa is $swaName"
Write-Host "the deploymentToken of swa is $deploymentToken"

Add-Content -Path $env:GITHUB_ENV -value "swaName=$swaName"
Add-Content -Path $env:GITHUB_ENV -value "rgName=$rgName"
Add-Content -Path $env:GITHUB_ENV -value "deploymentToken=$deploymentToken"