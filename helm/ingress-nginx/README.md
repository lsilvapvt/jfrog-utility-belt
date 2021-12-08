# NGINX ingress 

### Helm Install Notes 

[Documentation](https://kubernetes.github.io/ingress-nginx/deploy/#quick-start)

```
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```  