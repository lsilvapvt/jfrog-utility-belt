#!/bin/bash

set -e

# Pre-reqs:
export DEB_REPO_LOCAL=acmeco_deb_local
export JPD_NAMESPACE="jpd"
echo "Retrieving JPD information from secrets in Kubernetes namespace $JPD_NAMESPACE"
export JPD_PROTOCOL=$(kubectl get secret jpdprotocol -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-protocol" ')
export JPD_DOMAIN=$(kubectl get secret jpddomain -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-domain" ')
export JPD_ACCESSTOKEN=$(kubectl get secret jpdaccesstoken -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."jpd-token" ')

export RB_NAME=acmecoDebCLI
export RB_VERSION=1.0.0

export JPD_ALIAS="jpdpro"
echo "Set $JPD_ALIAS as current alias"
jfrog config use $JPD_ALIAS

echo "Create unsigned $RB_NAME release bundle"
jfrog ds rbc $RB_NAME $RB_VERSION "${DEB_REPO_LOCAL}/tools/c*.deb"

echo "Sign $RB_NAME release bundle"
jfrog ds rbs $RB_NAME $RB_VERSION

# TDB issue: force creation of target repo on destination not available in cli command
echo "Distribute $RB_NAME release bundle"
jfrog ds rbd --site "edge1" $RB_NAME $RB_VERSION

echo "-------------------"
