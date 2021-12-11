#!/bin/bash

# Install the JFrog Platform Helm chart 
## https://www.jfrog.com/confluence/display/JFROG/Installing+the+JFrog+Platform+Using+Helm+Chart
## https://www.jfrog.com/confluence/display/JFROG/Helm+Charts+for+Advanced+Users
## Pre-req
## - Create TLS Certificate 
## - Have license 

if [ "$#" -eq  "0" ]
then
    echo "No arguments supplied. Use either install, uninstall, upgrade or status"
else 
  export JPD_NAMESPACE="jpd"
  export JPD_HELMNAME="jpd"

  if [ $1 == "install" ]
  then

    # Pre-reqs - Define the following environment variables 
    # export JPD_PROTOCOL="https"
    # export JPD_DOMAIN="my.jfrog.io"
    # export MASTER_KEY=$(openssl rand -hex 32)
    # export JOIN_KEY=$(openssl rand -hex 32)
    # export POSTGRES_PASSWORD=$(openssl rand -hex 12)
    # export ADMIN_PASSWORD=$(openssl rand -hex 8)
    # export ADMIN_USERNAME="admin"

    # Optional - source separate secrets.sh file to define pre-req env vars 
    source ./secrets.sh

    echo "JPD_PROTOCOL $JPD_PROTOCOL"
    echo "JPD_DOMAIN $JPD_DOMAIN"
    echo "MASTER_KEY $MASTER_KEY"
    echo "JOIN_KEY $JOIN_KEY"
    echo "POSTGRES_PASSWORD $POSTGRES_PASSWORD"
    echo "ADMIN_USER $ADMIN_USERNAME"
    echo "ADMIN_PASSWORD $ADMIN_PASSWORD"

    ## Create keys and passwords as kubernetes secrets in the JPD namespace
    kubectl apply -f namespace.yaml
    kubectl create secret generic jpdprotocol -n ${JPD_NAMESPACE} --from-literal=jpd-protocol=${JPD_PROTOCOL}
    kubectl create secret generic jpddomain -n ${JPD_NAMESPACE} --from-literal=jpd-domain=${JPD_DOMAIN}
    kubectl create secret generic jpdjoinkey -n ${JPD_NAMESPACE} --from-literal=join-key=${JOIN_KEY}
    kubectl create secret generic jpdmasterkey -n ${JPD_NAMESPACE} --from-literal=master-key=${MASTER_KEY}
    kubectl create secret generic jpdpostgresspwd -n ${JPD_NAMESPACE} --from-literal=postgres-pwd=${POSTGRES_PASSWORD}
    kubectl create secret generic jpdadminuser -n ${JPD_NAMESPACE} --from-literal=admin-user=${ADMIN_USERNAME}
    kubectl create secret generic jpdadminpwd -n ${JPD_NAMESPACE} --from-literal=admin-pwd=${ADMIN_PASSWORD}

    ## Prepare TLS Certificates
    ## https://www.jfrog.com/confluence/display/JFROG/Helm+Charts+for+Advanced+Users#HelmChartsforAdvancedUsers-EstablishingTLSandAddingCertificates
    kubectl create secret tls jpd-tls \
            --cert=./cert.crt \
            --key=./cert.key \
            -n ${JPD_NAMESPACE}

    ## Prepare the license file 
    ## https://github.com/jfrog/charts/tree/master/stable/jfrog-platform#kubernetes-secret
    # Have local license file saved as 'art.lic
    kubectl create secret generic artifactory-cluster-license --from-file=./art.lic --namespace ${JPD_NAMESPACE}

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

                #  --set databaseUpgradeReady='true' \
                #  --set artifactory.artifactory.replicator.enabled='true' \
                #  --set artifactory.artifactory.consoleLog='true' \
                #  --set artifactory.artifactory.openMetrics.enabled='true' \
                #  --set global.masterKeySecretName=jpdmasterkey \
                #  --set global.joinKeySecretName=jpdjoinkey \

  else 
    if [ $1 == "uninstall" ]
    then
       echo "Deleting Helm Chart"
       helm uninstall ${JPD_HELMNAME} -n ${JPD_NAMESPACE} 
       echo "Waiting for helm resources to be cleaned up"
       sleep 60 
       echo "Deleting JPD namespace"
       kubectl delete -f namespace.yaml

    else 
      echo "Retrieving JPD information from secrets in Kubernetes namespace $JPD_NAMESPACE"
      export JPD_PROTOCOL=$(kubectl get secret jpdprotocol -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-protocol" ')
      export JPD_DOMAIN=$(kubectl get secret jpddomain -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-domain" ')
      export MASTER_KEY=$(kubectl get secret jpdmasterkey -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."master-key" ')
      export JOIN_KEY=$(kubectl get secret jpdjoinkey -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."join-key" ')
      export POSTGRES_PASSWORD=$(kubectl get secret jpdpostgresspwd -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."postgres-pwd" ')
      export ADMIN_USER=$(kubectl get secret jpdadminuser -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."admin-user" ')
      export ADMIN_PASSWORD=$(kubectl get secret jpdadminpwd -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."admin-pwd" ')

      echo "JPD_PROTOCOL $JPD_PROTOCOL"
      echo "JPD_DOMAIN $JPD_DOMAIN"
      echo "MASTER_KEY $MASTER_KEY"
      echo "JOIN_KEY $JOIN_KEY"
      echo "POSTGRES_PASSWORD $POSTGRES_PASSWORD"
      echo "ADMIN_USER $ADMIN_USER"
      echo "ADMIN_PASSWORD $ADMIN_PASSWORD"

      if [ $1 == "upgrade" ]
      then
        echo "Upgrading Helm Chart"

        helm upgrade ${JPD_HELMNAME} \
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
          echo "Status of JPD Helm Chart"

          helm status ${JPD_HELMNAME} --namespace ${JPD_NAMESPACE}

        fi
      fi 
    fi 
  fi 
fi


## Check certs: echo -n | openssl s_client -connect jpd.workshops.zone:443 -servername jpd.workshops.zone | openssl x509
## Clear DNS cache on Mac BigSur: sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder


# TBD: 
# - identify that system is up and running (check state of pods and ping command result?)
# kubectl wait --namespace ingress-nginx \
#   --for=condition=ready pod \
#   --selector=app.kubernetes.io/component=controller \
#   --timeout=120s
#
# - Prep for Edge install: Copy root cert to edge install folder 
#   To get root cert and private key of main Artifactory: 
#   kubectl exec jpd-artifactory-0 -n jpd -c artifactory -- cat var/etc/access/keys/root.crt > main_rt.crt
#   kubectl exec jpd-artifactory-0 -n jpd -c artifactory -- cat var/etc/access/keys/private.key > main_rt.key
#
# - Create Access Token - TBD 
#   TBD issue: how to automatically create one with the Access API, which requires another Access Token for auth?
#
# - Prep CLI config with Access Token or USER/PWD
#
# - Deploy EDGE and configure Circle of Trust with root cert of main JPD
#
# - Add EDGE as JPD platform node (https://www.jfrog.com/confluence/display/JFROG/Managing+Platform+Deployments)
# - Update HOME JPD location details
#
# - Create GPG keys, register public key for distribution and then propagate it
#
# - Pre-load sample artifacts 
#
# - Distribution: - Create Release bundle, Sign and Distribute it to Edge - use API cals script 
#
# - XRay - DB sync 
#   TBD issue: how to programmatically trigger the initial XUC DB sync?
#   TBD issue: check if DB sync is ready? How ?
#
# - XRay - Add builds, files and release bundles to indexing. Trigger initial index.
# 
# - XRay - Add Policies, Watches and Reports 
# 
# - Pipelines - configure nodes, dynamic nodes
#             - configure test pipeline for RB release creation and distribution
#
# - Smoke Test ?
# 
