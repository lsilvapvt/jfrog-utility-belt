#!/bin/bash

set -e

# Pre-reqs:
export DEB_REPO_LOCAL=acmeco_deb_local
export JPD_NAMESPACE="jpd"
echo "Retrieving JPD information from secrets in Kubernetes namespace $JPD_NAMESPACE"
export JPD_PROTOCOL=$(kubectl get secret jpdprotocol -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-protocol" ')
export JPD_DOMAIN=$(kubectl get secret jpddomain -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-domain" ')
export JPD_ACCESSTOKEN=$(kubectl get secret jpdaccesstoken -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-token" ')

export RB_NAME=acmecoDebApi
export RB_VERSION=1.0.1
echo "Create unsigned $RB_NAME release bundle in $JPD_PROTOCOL://$JPD_DOMAIN"

cat > tmpgen_rb.json <<EOF
{
    "name": "$RB_NAME",
    "version": "$RB_VERSION",
    "dry_run": false,
    "sign_immediately": false,
    "description": "Test $RB_NAME release bundle",
    "release_notes": {
      "syntax": "plain_text",
      "content": "This is the $RB_NAME release $RB_VERSION. Thanks for your support."
    },
    "spec": {
      "queries": [
        {
          "aql": "items.find({ \"repo\" : \"$DEB_REPO_LOCAL\",\"path\" : \"tools\",\"name\" : { \"\$match\" : \"f*.deb\" } })",
          "query_name": "mysamplequery",
          "added_props": [
            {
              "key": "release",
              "values": ["$RB_VERSION"]
            }
          ]
        }
      ]
    }
  }
EOF

curl -H "Authorization: Bearer $JPD_ACCESSTOKEN" \
  -X POST $JPD_PROTOCOL://$JPD_DOMAIN/distribution/api/v1/release_bundle \
  -H "Accept: application/json" \
  -H 'Content-Type: application/json' \
  -T tmpgen_rb.json

echo " "
echo "-----"

echo "Sign $RB_NAME release bundle"
curl -H "Authorization: Bearer $JPD_ACCESSTOKEN" \
  -H "Accept: application/json" \
  -H 'Content-Type: application/json' \
  -X POST $JPD_PROTOCOL://$JPD_DOMAIN/distribution/api/v1/release_bundle/$RB_NAME/$RB_VERSION/sign

echo " "
echo "-----"
echo "Distribute $RB_NAME release bundle"
cat > tmpgen_rbd.json <<EOF
{
    "dry_run": false,
    "auto_create_missing_repositories": true,
    "distribution_rules": [
      {
        "site_name": "edge1"
      }
    ]
}
EOF

curl -H "Authorization: Bearer $JPD_ACCESSTOKEN" \
  -X POST $JPD_PROTOCOL://$JPD_DOMAIN/distribution/api/v1/distribution/$RB_NAME/$RB_VERSION \
  -H "Accept: application/json" \
  -H 'Content-Type: application/json' \
  -T tmpgen_rbd.json

echo "-------------------"

