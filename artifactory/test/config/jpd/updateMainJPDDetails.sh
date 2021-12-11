#!/bin/bash

set -e

# Pre-reqs:
# - Install JFrog CLI and set the appropriate alias to the main JPD using an Access Token for auth
# - Set the following environment variables 
export JPD_ALIAS="jpdpro"
# export JPD_PROTOCOL="https"
# export JPD_DOMAIN="my.jfrog.com"
# export JPD_JOIN_KEY="XXXXXXX"

# Optional: instead, set pre-req variables from kubernetes secrets previosly set by the helm install script 
export JPD_NAMESPACE="jpd"
echo "Retrieving JPD information from secrets in Kubernetes namespace $JPD_NAMESPACE"
export JPD_PROTOCOL=$(kubectl get secret jpdprotocol -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-protocol" ')
export JPD_DOMAIN=$(kubectl get secret jpddomain -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-domain" ')
export JPD_ACCESSTOKEN=$(kubectl get secret jpdaccesstoken -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-token" ')

export JPD_HOME_ID="JPD-1"

echo "Update HOME JPD info"

cat > tmpgen_home.json <<EOF
{
  "name" : "HOME",
  "url" : "${JPD_PROTOCOL}://${JPD_DOMAIN}",
  "location" : {
    "city_name" : "Denver",
    "country_code" : "US",
    "latitude": 39.73915,
    "longitude": -104.9847
  }
}
EOF

curl -H "Authorization: Bearer $JPD_ACCESSTOKEN" \
  -X PUT $JPD_PROTOCOL://$JPD_DOMAIN/mc/api/v1/jpds/$JPD_HOME_ID \
  -H "Accept: application/json" \
  -H 'Content-Type: application/json' \
  -T tmpgen_home.json

echo " "
echo "-----"
