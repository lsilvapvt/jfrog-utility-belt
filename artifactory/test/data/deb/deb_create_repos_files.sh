#!/bin/bash

set -e

# Pre-reqs:
# - JFrog CLI with pre-defined alias for the targeted JPD

export JPD_ALIAS="jpdpro"

echo "Set $JPD_ALIAS as current alias"
jfrog config use $JPD_ALIAS

export DEB_REPO_LOCAL=acmeco_deb_local
export DEB_REPO_REMOTE=acmeco_deb_remote
export DEB_REPO_VIRTUAL=acmeco_deb
# create deb repositories 
echo "Create DEB repositories"
jfrog rt repo-create deb_local_repo.json
jfrog rt repo-create deb_remote_repo.json
# jfrog rt repo-create deb_virtual_repo.json

# Download sample files and then upload to repository 
cat ./deb_files.txt | while read fileEntry
  do
    echo "Downloading ${fileEntry}"
    wget ${fileEntry}
    fileName=$(basename ${fileEntry})
    echo "Uploading file ${fileName}"
    jfrog rt upload ./${fileName} ${DEB_REPO_LOCAL}/tools/
    echo "Deleting ${fileName}"
    rm ${fileName}
    echo "-------------------"
  done
