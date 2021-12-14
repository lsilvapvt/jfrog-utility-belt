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

1. **List XRay Reports** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GetReportsList)  
  
  ```
  curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/reports?direction=asc&page_num=1&num_of_rows=30&order_by=status" \
    -d '{"filters" : {"status" : ["aborted"]}}'
  ```


2. **Get report details by ID** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GetReportDetailsByID)  
  
  ```
  curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
  -X GET "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/reports/231"
  ```

3. **Create a report for repositories scan** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GenerateVulnerabilitiesReport)  
  
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

4. **Create a report to list violations raised by specific packages in a specific docker image**  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/reports/vulnerabilities" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{
        "name": "rpm_only_in_docker",
        "resources": {
            "repositories": [
                {
                "name": "docker-dv-local"
                }
            ]
        },
        "filters": {
            "watch_names": [
                "project_one"
            ],
            "artifact": "docker://*webapp*",
            "component": "rpm://*:*:*"
        }
    }
  ```

5. **Programmatically create an XRay report**  
  (for all/as many repositories as needed - per type or package)  
  [Link to sample bash script](https://gist.github.com/lsilvapvt/e6af30b489fa19309f8450a14016598c).


6. **Create a report for builds scan** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GenerateVulnerabilitiesReport)  
  
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

7. **Create a report for release bundles scan** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GenerateVulnerabilitiesReport)   
  
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


8. **Get contents of a vulnerabilities report** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GetViolationsReportContent)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/reports/vulnerabilities/254?direction=asc&page_num=1&num_of_rows=30&order_by=cve"
  ```


9. **Export and visualize report contents in JSON/PDF/CSV format** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-Export)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X GET "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/reports/export/254?file_name=build_vuln&format=json" \
    --output build_report.zip 
  ```


---

#### Indexing and Summaries 

10. **Get ID of Artifactory Binary Manager for XRay** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GetBinaryManager)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X GET "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/binMgr"  | jq ".[0].id"
  ```


11. **Get Repositories Indexed** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GetReposIndexingConfiguration)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X GET "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/binMgr/c0358340-490d-45ce-a496-7475f61d4179/repos"
  ```


12. **Get Builds Indexed** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GetBuildsIndexingConfiguration)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X GET "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/binMgr/c0358340-490d-45ce-a496-7475f61d4179/builds"
  ```


13. **Get Build summary** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-BuildSummary)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
      -X GET "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/summary/build?build_name=themavenbuild&build_number=1639427584"
  ```


14. **Get Artifact summary** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-ArtifactSummary)  
  
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


15. **Forces reindex of artifacts or builds** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-ForceReindex)  
  
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


16. **Find Components by CVE** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-FindComponentbyCVE)  
  
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


17. **Find CVEs by Component** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-FindCVEsbyComponent)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/component/searchCvesByComponents" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{
            "components_id": ["gav://com.mycompany.app:my-app:1.24.3"]
        }'
  ```


18. **Get Artifact Dependency Graph** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GetArtifactDependencyGraph)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/dependencyGraph/artifact" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{
            "path": "default/shire-maven-dev-local/com/mycompany/app/my-app/1.24.3/my-app-1.24.3.jar"
        }'
  ```


19. **Get Build Dependendy Graph** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-GetBuildDependencyGraph)  
  
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


20. **Export Component details to PDF/JSON/CSV** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-ExportComponentDetails)   
  
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


21. **Scan Artifact** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-ScanArtifact)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v1/scanArtifact" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{
            "componentID": "gav://com.mycompany.app:my-app:1.24.3"
        }'
  ```


22. **Scan a build v1** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-ScanBuildV1)  
  
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

23. **Index and Scan Resources on Demand** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-ScanNow)  
  
  ```
    curl -u $ADMIN_USERNAME:$ADMIN_PASSWORD \
    -X POST "$JPD_PROTOCOL://$JPD_DOMAIN/xray/api/v2/index" \
    -H "Accept: application/json" \
    -H 'Content-Type: application/json' \
    -d '{
            "repo_path":"shire-maven-dev-local/com/mycompany/app/my-app/1.24.3/my-app-1.24.3.jar"
        }'
  ```

24. **Get scan status** [API](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-ScanStatus)  
  
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
