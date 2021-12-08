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
export EDGE_NAMESPACE="edge"
export JPD_PROTOCOL=$(kubectl get secret edgeprotocol -n ${EDGE_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-protocol" ')
export JPD_DOMAIN=$(kubectl get secret edgedomain -n ${EDGE_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-domain" ')
export JPD_JOIN_KEY=$(kubectl get secret edgejoinkey -n ${EDGE_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."join-key" ')

echo "Set $JPD_ALIAS as current alias"
jfrog config use $JPD_ALIAS

cat > tmpgen_jpd.json <<EOF
{
  "name" : "edge1",
  "url" : "${JPD_PROTOCOL}://${JPD_DOMAIN}",
  "token" : "${JPD_JOIN_KEY}",
  "location" : {
    "city_name" : "Raleigh",
    "country_code" : "US",
    "latitude": 35.7721,
    "longitude": -78.63861
  },
  "tags" : []
}
EOF

echo "Registering JPD"
jfrog mc jpd-add ./tmpgen_jpd.json 
