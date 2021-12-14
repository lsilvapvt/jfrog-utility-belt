# XRay REST API - Sample usage 

These are sample curl commands for some of the [XRay REST API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API) actions.

Have the following variables defined in your environment before issuing the commands on this page.

```
export JPD_PROTOCOL="https"
export JPD_DOMAIN="myartifactory.jfrog.io"
export ADMIN_USERNAME="YOUR_ADMIN_USERID"
export ADMIN_PASSWORD="ENCRYPTED_PASSWORD"
```

---

#### XRAY Reports 

- **List XRay Reports** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GetReportsList)  
  
  ```
  curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/reports?direction=asc&page_num=1&num_of_rows=30&order_by=status" \
    -d '{"filters" : {"status" : ["aborted"]}}'
  ```


- **Get report details by ID** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GetReportDetailsByID)  
  
  ```
  curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
  -X GET "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/reports/231"
  ```

- **Create a report for repositories scan** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GenerateVulnerabilitiesReport)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/reports/vulnerabilities" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{
            "name": "log4jshell-repositories-report",
            "resources" : {
                "repositories": [
                    {
                        "name": "shire-maven-dev-local"
                    }
                ]
            },
            "filters": {
                "cve": "CVE-2021-44228"
            }
        }'
  ```


- **Create a report for builds scan** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GenerateVulnerabilitiesReport)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/reports/vulnerabilities" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{
            "name": "log4jshell-build-report",
            "resources" : {
                "builds": {
                    "names": [
                        "themavenbuild"
                    ],
                    "number_of_latest_versions": 5
                }
            },
            "filters": {
                "cve": "CVE-2021-44228"
            }
        }'
  ```

- **Create a report for release bundles scan** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GenerateVulnerabilitiesReport)   
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/reports/vulnerabilities" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{
            "name": "log4jshell-rb-report",
            "resources" : {
                "release_bundles": {
                    "names": [
                        "themavenrb"
                    ],
                    "number_of_latest_versions": 5
                }
            },
            "filters": {
                "cve": "CVE-2021-44228"
            }
        }'
    ```

- **Get contents of a vulnerabilities report** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GetViolationsReportContent)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/reports/vulnerabilities/254?direction=asc&page_num=1&num_of_rows=30&order_by=cve"
  ```

- **Export and visualize report contents in JSON/PDF/CSV format** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-Export)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X GET "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/reports/export/254?file_name=build_vuln&format=json" \
    --output build_report.zip 
  ```

---

#### Indexing and Summaries 

- **Get ID of Artifactory Binary Manager for XRay** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GetBinaryManager)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X GET "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/binMgr"  | jq ".[0].id"
  ```


- **Get Repositories Indexed** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GetReposIndexingConfiguration)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X GET "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/binMgr/c0358340-490d-45ce-a496-7475f61d4179/repos"
  ```

- **Get Builds Indexed** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GetBuildsIndexingConfiguration)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X GET "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/binMgr/c0358340-490d-45ce-a496-7475f61d4179/builds"
  ```

- **Get Build summary** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-BuildSummary)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
      -X GET "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/summary/build?build_name=themavenbuild&build_number=1639427584"
  ```


- **Get Artifactory summary** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-ArtifactSummary)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/summary/artifact" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{"paths": ["default/shire-maven-dev-local/com/mycompany/app/my-app/1.24.3/my-app-1.24.3.jar"]}'
  ```
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/summary/artifact" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{"checksums": ["ef239952ee3a0d331ac37f04c3305fc241c5f97acab223a61d0a7ea075bf49be"]}'
  ```


- **Forces reindex of artifacts or builds** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-ForceReindex)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/forceReindex" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{
            "artifacts": [
                {
                    "repository": "shire-maven-dev-local", 
                    "path": "com/mycompany/app/my-app/1.24.3/my-app-1.24.3.jar"
                }
            ]
        }'
  ```        

---

#### Searches, Graphs and Exports


- **Find Components by CVE** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-FindComponentbyCVE)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/component/searchByCves" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{
            "cves": [
                "CVE-2021-44228"
            ]
        }'
  ```

- **Find CVEs by Component** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-FindCVEsbyComponent)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/component/searchCvesByComponents" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{
            "components_id": ["gav://com.mycompany.app:my-app:1.24.3"]
        }'
  ```


- **Get Artifact Dependency Graph** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GetArtifactDependencyGraph)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/dependencyGraph/artifact" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{
            "path": "default/shire-maven-dev-local/com/mycompany/app/my-app/1.24.3/my-app-1.24.3.jar"
        }'
  ```


- **Get Build Dependendy Graph** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GetBuildDependencyGraph)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/dependencyGraph/build" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{
            "build_name":"themavenbuild",
            "build_number":"1639427584"
        }'
  ```


- **Export Component details to PDF/JSON/CSV** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-ExportComponentDetails)   
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/component/exportDetails" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{
            "violations": false,
            "include_ignored_violations": true,   
            "license": false,
            "security": true,
            "exclude_unknown": true,
            "component_name": "com.mycompany.app:my-app:1.24.3",
            "package_type": "maven",
            "output_format": "json",
            "sha_256" : "ef239952ee3a0d331ac37f04c3305fc241c5f97acab223a61d0a7ea075bf49be"
        }' --output component_info.zip
  ```

---

#### Indexing and Scanning


- **Scan Artifact** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-ScanArtifact)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/scanArtifact" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{
            "componentID": "gav://com.mycompany.app:my-app:1.24.3"
        }'
  ```


- **Scan a build v1** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-ScanBuildV1)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/scanBuild" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{
            "buildName":"themavenbuild",
            "buildNumber":"1639427584",
            "rescan": true,
            "filters": {
                "includeLicenses": false
            }        
        }'
  ```

- **Index and Scan Resources on Demand** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-ScanNow)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v2/index" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{
            "repo_path":"shire-maven-dev-local/com/mycompany/app/my-app/1.24.3/my-app-1.24.3.jar"
        }'
  ```

- **Get scan status** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-ScanStatus)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/scan/status/artifact" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{
            "repository_pkg_type": "Maven",
            "path": "shire-maven-dev-local/com/mycompany/app/my-app/1.24.3/my-app-1.24.3.jar",
            "sha256": "ef239952ee3a0d331ac37f04c3305fc241c5f97acab223a61d0a7ea075bf49be"
        }'
  ```

---
