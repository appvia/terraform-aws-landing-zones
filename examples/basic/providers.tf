
provider "aws" {
  region  = var.region
  profile = "appvia-io-support-dev"
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
