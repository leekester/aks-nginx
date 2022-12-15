kubectl apply -f aks-helloworld-one.yaml --namespace ingress-nginx
kubectl apply -f aks-helloworld-two.yaml --namespace ingress-nginx 
kubectl apply -f hello-world-ingress.yaml --namespace ingress-nginx