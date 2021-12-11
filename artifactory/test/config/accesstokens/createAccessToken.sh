#!/bin/bash

set -e

# Pre-reqs:
# - Set the following environment variables 
# export JPD_PROTOCOL="https"
# export JPD_DOMAIN="my.jfrog.com"
# export JPD_USER="admin"
# export JPD_PASSWORD="YOURPWDGOESHERE"

# Optional: instead, set pre-req variables from kubernetes secrets previosly set by the helm install script 
export JPD_NAMESPACE="jpd"
echo "Retrieving JPD information from secrets in Kubernetes namespace $JPD_NAMESPACE"
export JPD_PROTOCOL=$(kubectl get secret jpdprotocol -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-protocol" ')
export JPD_DOMAIN=$(kubectl get secret jpddomain -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-domain" ')
export JPD_USER=$(kubectl get secret jpdadminuser -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."admin-user" ')
export JPD_PASSWORD=$(kubectl get secret jpdadminpwd -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."admin-pwd" ')


# New API use - TBD before old RT api is fully deprecated
# Issue: new create a token API requires an existing token to create one
# curl -H "Authorization: Bearer $JFROG_ACCESSTOKEN" \
#   -X POST $JPD_PROTOCOL://$JPD_DOMAIN/access/api/v1/tokens \
#   -d @files/access/accesstoken1.json
# export JPD_ACCESSTOKEN=""

echo "------"
echo "Creating admin access token for $JPD_PROTOCOL://$JPD_DOMAIN"
curl  --user $JPD_USER:$JPD_PASSWORD \
  -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/artifactory/api/security/token" \
  -d "username=$JPD_USER" -d "scope=api:* member-of-groups:*" -d "expires_in=0" > tmpgen_token.json

export JPD_ACCESSTOKEN=$(cat tmpgen_token.json | jq -r .access_token)

curl -H "Authorization: Bearer $JPD_ACCESSTOKEN" \
  -X POST \
  $JPD_PROTOCOL://$JPD_DOMAIN/access/api/v1/tokens \
  -d "scope=applied-permissions/admin"

echo "------"
echo "Saving access token as a secret in Kubernetes namespace $JPD_NAMESPACE"
kubectl create secret generic jpdaccesstoken -n ${JPD_NAMESPACE} --from-literal=jpd-token=${JPD_ACCESSTOKEN}

# curl -H "Authorization: Bearer $JPD_ACCESSTOKEN" $JPD_PROTOCOL://$JPD_DOMAIN/artifactory/api/system
