
# Pre-req: define environment variables
# export TF_VAR_artifactory_url=https://MYARTIFACTORY.URL.GOESHERE/artifactory
# export TF_VAR_artifactory_access_token=ARTIFACTORY_ACCESS_TOKEN_GOES_HERE
# export TF_VAR_artifactory_user_password=USER_PASSWORD_GOES_HERE

terraform {
  required_providers {
    artifactory = {
      source = "jfrog/artifactory"
      version = "2.16.1"
    }
  }
}
 
variable "artifactory_url" {
  description = "The base URL of the Artifactory deployment"
  type        = string
}

variable "artifactory_access_token" {
  description = "The access token for the Artifactory administrator"
  type        = string
}

variable "artifactory_user_password" {
  description = "The temporary password for new users"
  type        = string
}

provider "artifactory" {
 # Configuration options
  url = "${var.artifactory_url}"
  access_token = "${var.artifactory_access_token}"
}

# Create a new Artifactory group
resource "artifactory_group" "hobbits" {
  name             = "hobbits"
  description      = "Shire group"
  admin_privileges = false
}


# Create a new Pypi repository
resource "artifactory_local_repository" "pypi-libs" {
  key             = "terraform-pypi-libs"
  package_type    = "pypi"
  repo_layout_ref = "simple-default"
  description     = "A pypi repository for python packages"
}

# Create a new Maven repository with priority resolution
resource "artifactory_local_maven_repository" "mktg-dev-maven-local" {
  key                             = "mktg-dev-maven-local"
  checksum_policy_type            = "client-checksums"
  snapshot_version_behavior       = "unique"
  max_unique_snapshots            = 10
  handle_releases                 = true
  handle_snapshots                = true
  suppress_pom_consistency_checks = false
  priority_resolution              = true
  notes = "This is my test maven repo created with Terraform with priority resolution"
}


# Create a new artifactory users 
resource "artifactory_user" "frodo" {
  name   = "frodo"
  email  = "frodo@middleearth.com"
  password = "${var.artifactory_user_password}"
  groups = [
    "readers", "hobbits",
  ]
}
resource "artifactory_user" "bilbo" {
  name   = "bilbo"
  email  = "bilbo@middleearth.com"
  password = "${var.artifactory_user_password}"
  groups = [
    "readers", "hobbits",
  ]
}

