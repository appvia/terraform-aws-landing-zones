
provider "aws" {
  region  = "eu-west-2"
  profile = "appvia-io-support-dev"
}

provider "aws" {
  alias   = "network"
  region  = "eu-west-2"
  profile = "appvia-io-network"
}

provider "aws" {
  alias   = "tenant"
  region  = "eu-west-2"
  profile = "appvia-io-support-dev"
}
