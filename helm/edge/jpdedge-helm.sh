#!/bin/bash

# Install the Artifactory Helm chart for an edge node

if [ "$#" -eq  "0" ]
then
    echo "No arguments supplied. Use either install, uninstall, upgrade or status"
else 
  export JPD_NAMESPACE="edge"
  export JPD_HELMNAME="edge"

  if [ $1 == "install" ]
  then

    # Pre-reqs - Define the following environment variables 
    # export JPD_PROTOCOL="http"
    # export JPD_DOMAIN="jpd.jfrog.pro"
    # export MASTER_KEY=$(openssl rand -hex 32)
    # export JOIN_KEY=$(openssl rand -hex 32)
    # export POSTGRES_PASSWORD=$(openssl rand -hex 12)
    # export ADMIN_PASSWORD=$(openssl rand -hex 8)
    # export ADMIN_USERNAME="admin"

    # Optional - source separate secrets.sh file to define pre-req env vars 
    source ./secrets.sh

    echo "EDGE_PROTOCOL $JPD_PROTOCOL"
    echo "EDGE_DOMAIN $JPD_DOMAIN"
    echo "MASTER_KEY $MASTER_KEY"
    echo "JOIN_KEY $JOIN_KEY"
    echo "POSTGRES_PASSWORD $POSTGRES_PASSWORD"
    echo "ADMIN_USER $ADMIN_USERNAME"
    echo "ADMIN_PASSWORD $ADMIN_PASSWORD"

    kubectl apply -f namespace.yaml
    kubectl create secret generic edgeprotocol -n ${JPD_NAMESPACE} --from-literal=jpd-protocol=${JPD_PROTOCOL}
    kubectl create secret generic edgedomain -n ${JPD_NAMESPACE} --from-literal=jpd-domain=${JPD_DOMAIN}
    kubectl create secret generic edgejoinkey -n ${JPD_NAMESPACE} --from-literal=join-key=${JOIN_KEY}
    kubectl create secret generic edgemasterkey -n ${JPD_NAMESPACE} --from-literal=master-key=${MASTER_KEY}
    kubectl create secret generic edgepostgresspwd -n ${JPD_NAMESPACE} --from-literal=postgres-pwd=${POSTGRES_PASSWORD}
    kubectl create secret generic edgeadminuser -n ${JPD_NAMESPACE} --from-literal=admin-user=${ADMIN_USERNAME}
    kubectl create secret generic edgeadminpwd -n ${JPD_NAMESPACE} --from-literal=admin-pwd=${ADMIN_PASSWORD}

    ## Prepare TLS Certificates
    ## https://www.jfrog.com/confluence/display/JFROG/Helm+Charts+for+Advanced+Users#HelmChartsforAdvancedUsers-EstablishingTLSandAddingCertificates
    kubectl create secret tls edge-tls \
            --cert=./cert.crt \
            --key=./cert.key \
            -n ${JPD_NAMESPACE}

    ## Prepare Main Artifactory Root Certificate to establish Circle of Trust
    ## https://www.jfrog.com/confluence/display/JFROG/Access+Tokens#AccessTokens-EstablishingaCircleofTrust
    ## Run this command against the main instance's K8s namespace (e.g. "jpd"): 
    ## kubectl exec jpd-artifactory-0 -n jpd -c artifactory -- cat var/etc/access/keys/root.crt > main_rt.crt
    ## kubectl exec jpd-artifactory-0 -n jpd -c artifactory -- cat var/etc/access/keys/private.key > main_rt.key
    kubectl create secret tls main-root-cert \
            --cert=./main_rt.crt \
            --key=./main_rt.key \
            -n ${JPD_NAMESPACE}

    ## Prepare the license file 
    ## https://github.com/jfrog/charts/tree/master/stable/jfrog-platform#kubernetes-secret
    # Have local license file saved as 'art.lic
    kubectl create secret generic artifactory-edge-license --from-file=./art.lic --namespace ${JPD_NAMESPACE}

    helm upgrade --install ${JPD_HELMNAME} \
                 --namespace ${JPD_NAMESPACE} \
                 --set global.masterKey=${MASTER_KEY} \
                 --set global.joinKey=${JOIN_KEY} \
                 --set global.jfrogUrl=${JPD_PROTOCOL}://${JPD_DOMAIN} \
                 --set global.jfrogUrlUI=${JPD_PROTOCOL}://${JPD_DOMAIN} \
                 --set artifactory.artifactory.admin.password=${ADMIN_PASSWORD} \
                 --set global.database.adminPassword=${POSTGRES_PASSWORD} \
                 --set postgresql.postgresqlPassword=${POSTGRES_PASSWORD} \
                 -f customvalues-ingress.yaml \
                 jfrog/jfrog-platform

  else 
    if [ $1 == "uninstall" ]
    then
       echo "Deleting Artifactory Edge Helm Chart"
       helm uninstall ${JPD_HELMNAME} -n ${JPD_NAMESPACE} 
       echo "Waiting for helm resources to be cleaned up"
       sleep 60 
       echo "Deleting JPD namespace"
       kubectl delete -f namespace.yaml

    else 
      export JPD_PROTOCOL=$(kubectl get secret edgeprotocol -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-protocol" ')
      export JPD_DOMAIN=$(kubectl get secret edgedomain -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-domain" ')
      export MASTER_KEY=$(kubectl get secret edgemasterkey -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."master-key" ')
      export JOIN_KEY=$(kubectl get secret edgejoinkey -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."join-key" ')
      export POSTGRES_PASSWORD=$(kubectl get secret edgepostgresspwd -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."postgres-pwd" ')
      export ADMIN_USER=$(kubectl get secret edgeadminuser -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."admin-user" ')
      export ADMIN_PASSWORD=$(kubectl get secret edgeadminpwd -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."admin-pwd" ')

      echo "EDGE_PROTOCOL $JPD_PROTOCOL"
      echo "EDGE_DOMAIN $JPD_DOMAIN"
      echo "MASTER_KEY $MASTER_KEY"
      echo "JOIN_KEY $JOIN_KEY"
      echo "POSTGRES_PASSWORD $POSTGRES_PASSWORD"
      echo "ADMIN_USER $ADMIN_USER"
      echo "ADMIN_PASSWORD $ADMIN_PASSWORD"

      if [ $1 == "upgrade" ]
      then
        echo "Upgrading Artifactory Edge Helm Chart"

        helm upgrade --install ${JPD_HELMNAME} \
                    --namespace ${JPD_NAMESPACE} \
                    --set global.masterKey=${MASTER_KEY} \
                    --set global.joinKey=${JOIN_KEY} \
                    --set global.jfrogUrl=${JPD_PROTOCOL}://${JPD_DOMAIN} \
                    --set global.jfrogUrlUI=${JPD_PROTOCOL}://${JPD_DOMAIN} \
                    --set artifactory.artifactory.admin.password=${ADMIN_PASSWORD} \
                    --set global.database.adminPassword=${POSTGRES_PASSWORD} \
                    --set postgresql.postgresqlPassword=${POSTGRES_PASSWORD} \
                    -f customvalues-ingress.yaml \
                    jfrog/jfrog-platform

      else 
        if [ $1 == "status" ]
        then
          echo "Status of Artifactory Edge Helm Chart"

          helm status ${JPD_HELMNAME} --namespace ${JPD_NAMESPACE}

        fi
      fi 
    fi 
  fi 
fi

## After pod is running and system is in good shape:
#
# - Create Circle of Trust - Copy main-root-cert to access keys trusted folder (https://www.jfrog.com/confluence/display/JFROG/Access+Tokens#AccessTokens-EstablishingaCircleofTrust)
#   kubectl exec -it ${JPD_HELMNAME}-artifactory-0 -n ${JPD_HELMNAME} -c artifactory -- cp var/etc/security/keys/trusted/ca.crt var/etc/access/keys/trusted/main-jpd.crt
#   
