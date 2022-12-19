# NGINX and OSM Example Deployment
Deploys public AKS cluster with NGINX ingress controller.
Enables Open Service Mesh.
Creates namespaces for each of BC, CC and PC. These are placeholder applications - not the real thing.
Deploys placeholder HTTP applications.
Adds ingress configuration so that HTTP requests for billing/claims/policy.inside.direct are routed to the correct backend service.
Deploys IngressBackend configuration to allow traffic through OSM.
