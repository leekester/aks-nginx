# NGINX and OSM Example Deployment
- Deploys public AKS cluster with NGINX ingress controller.
- Enables Open Service Mesh.
- Creates namespaces for each of BC, CC and PC. These are placeholder applications - not the real thing.
- Deploys placeholder HTTP applications.
- Adds ingress configuration so that HTTP requests for billing/claims/policy.inside.direct are routed to the correct backend service.
- Deploys IngressBackend configuration to allow traffic through OSM.

## To run this successfully you'll need
- The Azure CLI (https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli#install-or-update)
- The kubectl binary, located in a findable path (https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/#install-kubectl-on-windows)
- The OSM binary, located in a findable path (https://learn.microsoft.com/en-us/azure/aks/open-service-mesh-binary?pivots=client-operating-system-windows#download-and-install-the-open-service-mesh-osm-client-binary)
- Helm (https://helm.sh/docs/intro/install/)
- An Azure subscription that you can deploy into. The clusterDeploy.ps1 script creates a public AKS cluster.
