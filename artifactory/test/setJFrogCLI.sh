#!/bin/bash

set -e

# Pre-reqs:
# - Install JFrog CLI
# - Set the following environment variables 
export JPD_ALIAS="jpdpro"
# export JPD_PROTOCOL="https"
# export JPD_DOMAIN="my.jfrog.com"
# export JPD_USER="admin"
# export JPD_PASSWORD="YOURPWDGOESHERE"
# export JPD_ACCESSTOKEN="ACCESS_TOKEN_GOES_HERE"

# Optional: instead, set pre-req variables from kubernetes secrets previosly set by the helm install script 
export JPD_NAMESPACE="jpd"
echo "Retrieving JPD information from secrets in Kubernetes namespace $JPD_NAMESPACE"
export JPD_PROTOCOL=$(kubectl get secret jpdprotocol -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-protocol" ')
export JPD_DOMAIN=$(kubectl get secret jpddomain -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-domain" ')
export JPD_USER=$(kubectl get secret jpdadminuser -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."admin-user" ')
export JPD_PASSWORD=$(kubectl get secret jpdadminpwd -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."admin-pwd" ')
export JPD_ACCESSTOKEN=$(kubectl get secret jpdaccesstoken -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-token" ')

# export JPD_AUTH_STRING=" --user $JPD_USER:$JPD_PASSWORD "
# export JPD_AUTH_STRING=" -H \"Authorization: Bearer $JPD_ACCESSTOKEN\" "

echo "Pinging JPD with REST API"
curl -H "Authorization: Bearer $JPD_ACCESSTOKEN" $JPD_PROTOCOL://$JPD_DOMAIN/artifactory/api/system/ping

echo " "
echo "------"
echo "Configuring JFrog CLI alias $JPD_ALIAS for $JPD_PROTOCOL://$JPD_DOMAIN"
jfrog config add $JPD_ALIAS \
  --url "$JPD_PROTOCOL://$JPD_DOMAIN" \
  --access-token "$JPD_ACCESSTOKEN" \
  --overwrite --interactive=false

### TBD Access Token is required to register JPDs in later config steps. How to create it? 
  # --user "$JPD_USER" \
  # --password "$JPD_PASSWORD" \

echo "------"
echo "List details of created JFrog CLI alias"
jfrog config show $JPD_ALIAS

echo "------"
echo "Set $JPD_ALIAS as current alias"
jfrog config use $JPD_ALIAS

echo "------"
echo "Pinging JPD with JFROG CLI"
jfrog rt ping

echo " "
echo "------"
