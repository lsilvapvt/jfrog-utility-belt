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
export JPD_PROTOCOL=$(kubectl get secret jpdprotocol -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-protocol" ')
export JPD_DOMAIN=$(kubectl get secret jpddomain -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-domain" ')
export JPD_USER=$(kubectl get secret jpdadminuser -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."admin-user" ')
export JPD_PASSWORD=$(kubectl get secret jpdadminpwd -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."admin-pwd" ')

export JPD_AUTH_STRING=" --user $JPD_USER:$JPD_PASSWORD "

# Generate the gpg key in non-interactive mode
# https://www.gnupg.org/documentation/manuals/gnupg-devel/Unattended-GPG-key-generation.html
# https://gist.github.com/woods/8970150
echo "Generating gpg keys"
gpg --batch --generate-key <<EOF
  Key-Type: RSA
  Key-Length: 2048
  Subkey-Type: RSA
  Subkey-Length: 2048
  Name-Real: acmedist
  Name-Email: acme@jfrog.com
  Expire-Date: 0
  %no-ask-passphrase
  %no-protection
  %commit
  %echo done
EOF

# Export Private Key
echo "Exporting Private Keys"
gpg --output acmedistkey.gpg --armor --yes --export-secret-keys acmedist

# Export Public Key
echo "Exporting Public Keys"
gpg --output acmedistpub.gpg --armor --yes --export acmedist

# just in case, example to replace new line with \n and convert into a one liner
#      awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' acmedistpub.gpg
# example on how to remove last empty line of the gpg files 
#     sed '${/^$/d;}' acmedistpub.gpg > tmppub.gpg 

echo "Preparing GPG info json file"
export PUBLICKEY=$(cat acmedistpub.gpg)
export PRIVATEKEY=$(cat acmedistkey.gpg)
cat > acmegpgkey.json <<EOF
{
  "key": {
     "alias": "default-gpg-key",
     "public_key" : "$PUBLICKEY",
     "private_key": "$PRIVATEKEY"
  },
  "propagate_to_edge_nodes" : true,
  "fail_on_propagation_failure": false,
  "set_as_default": true
}  
EOF

## Upload GPG Signing Key for Distribution (api)
echo "Upload GPG info json file to JPD"

# API failed when using Access Token
# curl -H "Authorization: Bearer $JFROG_ACCESSTOKEN" -X POST $JFROG_PROTOCOL://$JFROG_URL/distribution/api/v1/keys/gpg/ -H 'Content-Type: application/json' -T acmegpgkey.json
# use basic auth instead 
curl $JPD_AUTH_STRING \
 -X POST $JPD_PROTOCOL://$JPD_DOMAIN/distribution/api/v1/keys/gpg \
 -H "Accept: application/json" \
 -H 'Content-Type: application/json' \
 -T acmegpgkey.json

echo " "

#  curl -u $USER_ID:$ENCRYPTED_PWD -X GET $JFROG_PROTOCOL://$JFROG_URL/distribution/api/v1/keys/ 
