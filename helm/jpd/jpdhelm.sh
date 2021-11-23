#!/bin/bash
if [ "$#" -eq  "0" ]
then
    echo "No arguments supplied. Use either install, uninstall, upgrade or status"
else 
  export JPD_NAMESPACE="jpd"
  export JPD_HELMNAME="jpd"

  if [ $1 == "install" ]
  then
    # Install the JFrog Platform Helm chart 
    ## https://www.jfrog.com/confluence/display/JFROG/Installing+the+JFrog+Platform+Using+Helm+Chart
    ## https://www.jfrog.com/confluence/display/JFROG/Helm+Charts+for+Advanced+Users

    ## Create keys and passwords as kubernetes secrets in the JPD namespace
    export MASTER_KEY=$(openssl rand -hex 32)
    export JOIN_KEY=$(openssl rand -hex 32)
    export POSTGRES_PASSWORD=$(openssl rand -hex 12)
    export ADMIN_PASSWORD=$(openssl rand -hex 8)

    echo "MASTER_KEY $MASTER_KEY"
    echo "JOIN_KEY $JOIN_KEY"
    echo "POSTGRES_PASSWORD $POSTGRES_PASSWORD"
    echo "ADMIN_PASSWORD $ADMIN_PASSWORD"

    kubectl apply -f namespace.yaml
    kubectl create secret generic jpdjoinkey -n ${JPD_NAMESPACE} --from-literal=join-key=${JOIN_KEY}
    kubectl create secret generic jpdmasterkey -n ${JPD_NAMESPACE} --from-literal=master-key=${MASTER_KEY}
    kubectl create secret generic jpdpostgresspwd -n ${JPD_NAMESPACE} --from-literal=postgres-pwd=${POSTGRES_PASSWORD}
    kubectl create secret generic jpdadminpwd -n ${JPD_NAMESPACE} --from-literal=admin-pwd=${ADMIN_PASSWORD}

    ## Prepare TLS Certificates
    ## https://www.jfrog.com/confluence/display/JFROG/Helm+Charts+for+Advanced+Users#HelmChartsforAdvancedUsers-EstablishingTLSandAddingCertificates
    kubectl create secret tls jpd-tls \
            --cert=./cert.crt \
            --key=./cert.key \
            -n ${JPD_NAMESPACE}

    ## Prepare the license file 
    ## https://github.com/jfrog/charts/tree/master/stable/jfrog-platform#kubernetes-secret
    # Have local license file saved as 'art.lic
    kubectl create secret generic artifactory-cluster-license --from-file=./art.lic --namespace ${JPD_NAMESPACE}

    helm upgrade --install ${JPD_HELMNAME} \
                 --namespace ${JPD_NAMESPACE} \
                 --set global.masterKey=${MASTER_KEY} \
                 --set global.joinKey=${JOIN_KEY} \
                 --set artifactory.artifactory.admin.password=${ADMIN_PASSWORD} \
                 --set global.database.adminPassword=${POSTGRES_PASSWORD} \
                 --set postgresql.postgresqlPassword=${POSTGRES_PASSWORD} \
                 -f customvalues.yaml \
                 jfrog/jfrog-platform

                #  --set databaseUpgradeReady='true' \
                #  --set artifactory.artifactory.consoleLog='true' \
                #  --set artifactory.artifactory.openMetrics.enabled='true' \
                #  --set global.masterKeySecretName=jpdmasterkey \
                #  --set global.joinKeySecretName=jpdjoinkey \

  else 
    if [ $1 == "uninstall" ]
    then
       echo "Deleting Helm Chart"
       helm uninstall ${JPD_HELMNAME} -n ${JPD_NAMESPACE} 
       echo "Waiting for helm resources to be cleaned up"
       sleep 60 
       echo "Deleting JPD namespace"
       kubectl delete -f namespace.yaml

    else 
      export MASTER_KEY=$(kubectl get secret jpdmasterkey -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."master-key" ')
      export JOIN_KEY=$(kubectl get secret jpdjoinkey -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."join-key" ')
      export POSTGRES_PASSWORD=$(kubectl get secret jpdpostgresspwd -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."postgres-pwd" ')
      export ADMIN_PASSWORD=$(kubectl get secret jpdadminpwd -n ${JPD_NAMESPACE} -o json | jq -r '.data | map_values(@base64d) | ."admin-pwd" ')

      echo "MASTER_KEY $MASTER_KEY"
      echo "JOIN_KEY $JOIN_KEY"
      echo "POSTGRES_PASSWORD $POSTGRES_PASSWORD"
      echo "ADMIN_PASSWORD $ADMIN_PASSWORD"

      if [ $1 == "upgrade" ]
      then
        echo "Upgrading Helm Chart"

        helm upgrade --install ${JPD_HELMNAME} \
                    --namespace ${JPD_NAMESPACE} \
                    --set global.masterKey=${MASTER_KEY} \
                    --set global.joinKey=${JOIN_KEY} \
                    --set artifactory.artifactory.admin.password=${ADMIN_PASSWORD} \
                    --set global.database.adminPassword=${POSTGRES_PASSWORD} \
                    --set postgresql.postgresqlPassword=${POSTGRES_PASSWORD} \
                    -f customvalues.yaml \
                    jfrog/jfrog-platform

      else 
        if [ $1 == "status" ]
        then
          echo "Status of JPD Helm Chart"

          helm status ${JPD_HELMNAME} --namespace ${JPD_NAMESPACE}

        fi
      fi 
    fi 
  fi 
fi


## Check certs: echo -n | openssl s_client -connect jpd.workshops.zone:443 -servername jpd.workshops.zone | openssl x509
## Clear DNS cache on Mac BigSur: sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
