
provider "aws" {
  region  = var.region
  profile = "appvia-io-support-dev"
}

provider "aws" {
  alias   = "identity"
  region  = var.region
  profile = "appvia-io-master"
}

provider "aws" {
  alias   = "network"
  region  = var.region
  profile = "appvia-io-network"
}

provider "aws" {
  alias   = "tenant"
  region  = var.region
  profile = "appvia-io-support-dev"
}

provider "aws" {
  alias   = "management"
  region  = var.region
  profile = "appvia-io-management"
}

