$resourceGroup = "rg-aks"
$location = "uksouth"
$clusterName = "aks-playground"
$keyVaultName = ("kvmatt" + (Get-Random -Minimum 100000000 -Maximum 999999999))
$federatedIdentityName = ("aks-id" + $clusterName)
$crName = ("acrmatt" + (Get-Random -Minimum 100000000 -Maximum 999999999))
$nodesize = "Standard_B2s"
$nodeCount = "1"
$serviceAccountName = "sa-workload-identity"
$serviceAccountNamespace = "ns-workloadid"
$subscriptionId = (az account show --query id --output tsv)
$userAssignedIdentityName = "$clusterName-uami"

# Ingress configuration
$bcIngress = "bc-ingress"

# If required, install the pod identity feature
Write-Host "Install/enable the workload identity feature..." -ForegroundColor Yellow
az extension add --name aks-preview
az extension update --name aks-preview
az feature register `
  --namespace "Microsoft.ContainerService" `
  --name "EnableWorkloadIdentityPreview"
az provider register --namespace Microsoft.ContainerService

# Create AKS cluster
Write-Host "Creating AKS cluster $clusterName in resource group $resourceGroup" -ForegroundColor Yellow
az group create `
  --name $resourceGroup `
  --location $location
az aks create `
  --resource-group $resourceGroup `
  --name $clusterName `
  --node-count $nodeCount `
  --enable-oidc-issuer `
  --enable-workload-identity `
  --generate-ssh-keys

# Create Managed Identity
Write-Host "Creating Managed Identity $userAssignedIdentityName" -ForegroundColor Yellow
az identity create `
  --name $userAssignedIdentityName `
  --resource-group $resourceGroup `
  --location $location `
  --subscription $subscriptionId
$userAssignedIdentityId = az identity show --resource-group $resourceGroup --name $userAssignedIdentityName --query 'clientId' -otsv

# Create Key Vault
Write-Host "Creating Key Vault $keyVaultName" -ForegroundColor Yellow
az keyvault create `
  --name $keyVaultName `
  --resource-group $resourceGroup `
  --location $location
az keyvault set-policy `
  --name $keyVaultName `
  --secret-permissions get `
  --spn $userAssignedIdentityId

# Get OIDC issuer URL
Write-Host "Retrieving OIDC issuer URL" -ForegroundColor Yellow
$aksIssuerUrl = (az aks show --name $clusterName -g $resourceGroup --query "oidcIssuerProfile.issuerUrl" -otsv)

# Retrieve AKS admin credentials
Write-Host "Retrieving AKS credentials" -ForegroundColor Yellow
az aks get-credentials --name $clusterName --resource-group $resourceGroup --overwrite-existing

# Create service account
Write-Host "Creating namespace $serviceAccountNamespace and service account $serviceAccountName" -ForegroundColor Yellow
kubectl create namespace $serviceAccountNamespace
@"
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: "$userAssignedIdentityId"
  labels:
    azure.workload.identity/use: "true"
  name: "$serviceAccountName"
  namespace: "$serviceAccountNamespace"
"@ | kubectl apply -f -

# Establish federated identity credential
az identity federated-credential create `
  --name $federatedIdentityName `
  --identity-name $userAssignedIdentityName `
  --resource-group $resourceGroup `
  --issuer $aksIssuerUrl `
  --subject system:serviceaccount:$serviceAccountNamespace`:$serviceAccountName

# Configure ingress

$ingressNamespace = "ns-ingress"
$appNamespace = "hello-world"
# kubectl create namespace ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx `
  --create-namespace `
  --namespace $ingressNamespace `
  --set controller.replicaCount=1 `
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz `
  --set controller.nodeSelector."kubernetes\.io/os"=linux `
  --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux

kubectl create ns $appNamespace
kubectl apply -f aks-helloworld-one.yaml --namespace $appNamespace
kubectl apply -f aks-helloworld-two.yaml --namespace $appNamespace 
kubectl apply -f hello-world-ingress.yaml --namespace $appNamespace