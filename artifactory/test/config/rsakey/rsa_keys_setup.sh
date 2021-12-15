#!/bin/bash

set -e

# Pre-reqs:
# - gpg tool installed on the client  -  brew install gpg (for Mac)
# - The following env variables defined:
# export JPD_PROTOCOL="http"
# export JPD_DOMAIN=DOMAIN_OR_IP
# export JPD_USER=MY_USER_ID
# export JPD_PASSWORD=MY_PWD

# Optional: instead, set pre-req variables from kubernetes secrets previosly set by the helm install script 
export JPD_NAMESPACE="jpd"
echo "Retrieving JPD information from secrets in Kubernetes namespace $JPD_NAMESPACE"
export JPD_PROTOCOL=$(kubectl get secret jpdprotocol -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-protocol" ')
export JPD_DOMAIN=$(kubectl get secret jpddomain -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-domain" ')
export JPD_USER=$(kubectl get secret jpdadminuser -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."admin-user" ')
export JPD_PASSWORD=$(kubectl get secret jpdadminpwd -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."admin-pwd" ')

export JPD_AUTH_STRING=" --user $JPD_USER:$JPD_PASSWORD "

# https://wiki.alpinelinux.org/wiki/Include:Abuild-keygen
echo "Generating RSA Public Key"
openssl genrsa -out tmpgen_rsa.priv 2048
echo "Generating RSA Private Key"
openssl rsa -in tmpgen_rsa.priv -pubout -out tmpgen_rsa.pub

echo "Preparing RSA info json file"
export PUBLICKEY=$(cat tmpgen_rsa.pub)
export PRIVATEKEY=$(cat tmpgen_rsa.priv)
cat > tmpgen_rsa.json <<EOF
{
  "alias": "default-rsa-key",
  "public_key" : "$PUBLICKEY",
  "private_key": "$PRIVATEKEY"
}
EOF

## Upload GPG Signing Key for Distribution (api)
echo "Upload RSA info json file to JPD $JPD_PROTOCOL://$JPD_DOMAIN"
curl $JPD_AUTH_STRING \
 -X PUT $JPD_PROTOCOL://$JPD_DOMAIN/artifactory/api/gpg/key/public \
 -H "Accept: application/json" \
 -H 'Content-Type: application/json' \
 -T tmpgen_rsa.json

echo " "

echo "Checking if key got set correctly"
# https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API#ArtifactoryRESTAPI-GetGPGPublicKey
curl $JPD_AUTH_STRING -X GET "$JPD_PROTOCOL://$JPD_DOMAIN/artifactory/api/gpg/key/public" 

# curl --user $JPD_USER:$JPD_PASSWORD -fsSL "$JPD_PROTOCOL://$JPD_DOMAIN/artifactory/api/gpg/key/public" | apt-key add -
# sudo sh -c "echo 'deb $JPD_PROTOCOL://$JPD_DOMAIN/artifactory/acmeco_deb_local trusty main' >> /etc/apt/sources.list"

echo " "
