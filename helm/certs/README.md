# Cert-Manager use notes 

1. Create the staging and prod issuers  
   https://cert-manager.io/docs/configuration/

2. Create the Certificate using the Certificate Resource  
   https://cert-manager.io/docs/usage/

   Check status of CertificateRequests, Orders and Challenges 

3. Extract or download certificate 

   ```
   kubectl get secret -n NAMESPACE SECRET_KEY -o json | jq -r '.data."tls.crt"' | base64 -d

   kubectl get secret -n NAMESPACE SECRET_KEY -o json | jq -r '.data."tls.key"' | base64 -d

   ```
   
