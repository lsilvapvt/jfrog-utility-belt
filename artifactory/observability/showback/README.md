# JFrog Platform usage show-back ideas 

## Use of RepoStats JFROG CLI plugin 

- Plugin's Git Repository: https://github.com/chanti529/repostats

Provides `download` and `size` statistics per repository, folder, artifacts and user.

### Examples

- List selected folders with corresponding sizes in descending order 

```bash
  jfrog repostats size folder \
        --repos docker-dev-local,docker-prod-local \
         --limit 30 --max-depth 2
```

- List selected repositories with corresponding sizes in descending order 

```bash
  jfrog repostats size repo  \
        --repos docker-dev-local,docker-prod-local \
         --limit 0
```

- List selected folders with corresponding number of downloads in descending order 

```bash
  jfrog repostats download folder \
        --repos docker-dev-local,docker-prod-local \
         --limit 50 --max-depth 2
```

- List selected repositories with corresponding number of downloads in descending order 

```bash
  jfrog repostats download repo  \
        --repos docker-dev-local,docker-prod-local \
         --limit 0
```


## The `user` option 

- `jfrog repostats size ...`   : returns the size of the artifacts uploaded by each user (item.ModifiedBy used to identify owner of artifact)

- `jfrog repostats download ...` : returns the number of downloads for each artifact uploaded by each user 


## Possibilities for usage

- Get summary of sizes of artifacts for all repos from date X until now 

  - Get Total size of artifacts for all repos with AQL or REST API

  - List all repositories with AQL
    Iterate over list in chunks of N and issue size command for that comma-separated list 
    Calculate percentage for each repo and produce graphs 

  - Save current time to be used in the next report 


- Get quantity of downloads for all artifats of each repo and translate that into total percentages for the instance from date X until now 

  - For each folder, get statistics on downloads 

  - For each folder, get statistics on sizes 

  - Calculate amount of download in bytes for each artifact based on the two values above 

  - Aggregate it per folder and then per repository 
  
  - Aggregate it for all the repos and then calculate percentages per folder/repos 

---
