#!/bin/bash

set -e

# Pre-reqs:
# - JFrog CLI with pre-defined alias for the targeted JPD

export JPD_ALIAS="jpdpro"

echo "Set $JPD_ALIAS as current alias"
jfrog config use $JPD_ALIAS

echo "Delete Debian repositories and files"
jfrog rt repo-delete acmeco_deb_local --quiet
jfrog rt repo-delete acmeco_deb_remote --quiet 
# jfrog rt repo-delete acmeco_deb --quiet

echo "Done"
