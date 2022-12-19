# NGINX and OSM Example Deployment
- Deploys public AKS cluster with NGINX ingress controller.
- Enables Open Service Mesh.
- Creates namespaces for each of BC, CC and PC. These are placeholder applications - not the real thing.
- Deploys placeholder HTTP applications.
- Adds ingress configuration so that HTTP requests for billing/claims/policy.inside.direct are routed to the correct backend service.
<<<<<<< HEAD
- Deploys IngressBackend configuration to allow traffic through OSM.
=======
- Deploys IngressBackend configuration to allow traffic through OSM.
>>>>>>> 16771c6a4a0c53338e6b42572e8bc38fafffba70
