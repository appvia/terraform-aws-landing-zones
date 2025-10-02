# Network Configuration Tests
# This file contains comprehensive tests for the network configuration

# Override the notifications module to provide a mock SNS topic
override_module {
  target = module.notifications
  outputs = {
    sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:appvia-notifications"
  }
}

# Test 1: Basic network configuration with private subnet
run "basic_network" {
  variables {
    environment    = "Production"
    owner          = "Support"
    product        = "LandingZone"
    home_region    = "eu-west-2"
    tags           = {}
    git_repository = "test"

    notifications = {
      email = {
        addresses = ["info@appvia.io"]
      }
    }

    networks = {
      "test-vpc" = {
        subnets = {
          private = {
            netmask = 24
          }
        }
        vpc = {
          enable_transit_gateway = false
          availability_zones     = 2
          cidr                   = "10.0.0.0/16"
          nat_gateway_mode       = "none"
        }
      }
    }
  }

  # Test that network module is created
  assert {
    condition     = module.networks["test-vpc"] != null
    error_message = "Network module should be created for test-vpc"
  }
}

# Test 2: Network with transit gateway configuration
run "network_with_transit_gateway" {
  variables {
    environment    = "Production"
    owner          = "Support"
    product        = "LandingZone"
    home_region    = "eu-west-2"
    tags           = {}
    git_repository = "test"

    notifications = {
      email = {
        addresses = ["info@appvia.io"]
      }
    }

    networks = {
      "test-vpc" = {
        subnets = {
          private = {
            netmask = 24
          }
        }
        vpc = {
          enable_transit_gateway = true
          availability_zones     = 2
          cidr                   = "10.0.0.0/16"
          nat_gateway_mode       = "none"
        }
        transit_gateway = {
          gateway_id = "tgw-1234567890"
          gateway_routes = {
            private = "10.0.0.0/8"
          }
        }
      }
    }
  }

  # Test that network module is created
  assert {
    condition     = module.networks["test-vpc"] != null
    error_message = "Network module should be created for test-vpc with transit gateway"
  }

  # Test that VPC ID is available from module output
  assert {
    condition     = module.networks["test-vpc"].vpc_id != null
    error_message = "VPC ID should be available from module output"
  }

  # Test that transit gateway attachment ID is available (from module output)
  assert {
    condition     = module.networks["test-vpc"].transit_gateway_attachment_id != null
    error_message = "Transit gateway attachment ID should be available from module output"
  }
}

# Test 3: Network with firewall configuration
run "network_with_firewall" {
  variables {
    environment    = "Production"
    owner          = "Support"
    product        = "LandingZone"
    home_region    = "eu-west-2"
    tags           = {}
    git_repository = "test"

    notifications = {
      email = {
        addresses = ["info@appvia.io"]
      }
    }

    networks = {
      "test-vpc" = {
        subnets = {
          private = {
            netmask = 24
          }
        }
        vpc = {
          availability_zones = 2
          cidr               = "10.0.0.0/16"
          nat_gateway_mode   = "none"
        }
        firewall = {
          capacity     = 1000
          rules_source = "alert http any any -> any any (msg:\"HTTP Traffic\"; sid:1;)"
          ip_sets = {
            WEBSERVERS = ["10.0.1.0/24"]
            DATABASE   = ["10.0.2.0/24"]
          }
          port_sets = {
            HTTP  = [80, 8080]
            HTTPS = [443, 8443]
          }
          domains_whitelist = ["example.com", "test.com"]
        }
      }
    }
  }

  # Test that network module is created
  assert {
    condition     = module.networks["test-vpc"] != null
    error_message = "Network module should be created for test-vpc with firewall"
  }
}

# Test 4: Network with IPAM configuration
run "network_with_ipam" {
  variables {
    environment    = "Production"
    owner          = "Support"
    product        = "LandingZone"
    home_region    = "eu-west-2"
    tags           = {}
    git_repository = "test"

    notifications = {
      email = {
        addresses = ["info@appvia.io"]
      }
    }

    networks = {
      "test-vpc" = {
        subnets = {
          private = {
            netmask = 24
          }
        }
        vpc = {
          availability_zones = 2
          ipam_pool_name     = "test-ipam-pool"
          netmask            = 21
          nat_gateway_mode   = "none"
        }
      }
    }
  }

  # Test that network module is created
  assert {
    condition     = module.networks["test-vpc"] != null
    error_message = "Network module should be created for test-vpc with IPAM"
  }
}

# Test 5: Network with multiple subnets
run "network_with_multiple_subnets" {
  variables {
    environment    = "Production"
    owner          = "Support"
    product        = "LandingZone"
    home_region    = "eu-west-2"
    tags           = {}
    git_repository = "test"

    notifications = {
      email = {
        addresses = ["info@appvia.io"]
      }
    }

    networks = {
      "test-vpc" = {
        subnets = {
          private = {
            netmask = 24
          }
          public = {
            netmask = 22
          }
        }
        vpc = {
          availability_zones = 2
          cidr               = "10.0.0.0/16"
          nat_gateway_mode   = "single_az"
        }
      }
    }
  }

  # Test that network module is created
  assert {
    condition     = module.networks["test-vpc"] != null
    error_message = "Network module should be created for test-vpc with multiple subnets"
  }
}

# Test 6: Network with custom tags
run "network_with_custom_tags" {
  variables {
    environment    = "Production"
    owner          = "Support"
    product        = "LandingZone"
    home_region    = "eu-west-2"
    tags           = {}
    git_repository = "test"

    notifications = {
      email = {
        addresses = ["info@appvia.io"]
      }
    }

    networks = {
      "test-vpc" = {
        subnets = {
          private = {
            netmask = 24
          }
        }
        vpc = {
          availability_zones = 2
          cidr               = "10.0.0.0/16"
          nat_gateway_mode   = "none"
        }
        tags = {
          Environment = "Test"
          Project     = "NetworkTesting"
          CostCenter  = "IT"
        }
      }
    }
  }

  # Test that network module is created
  assert {
    condition     = module.networks["test-vpc"] != null
    error_message = "Network module should be created for test-vpc with custom tags"
  }
}

# Test 7: Network with private endpoints
run "network_with_private_endpoints" {
  variables {
    environment    = "Production"
    owner          = "Support"
    product        = "LandingZone"
    home_region    = "eu-west-2"
    tags           = {}
    git_repository = "test"

    notifications = {
      email = {
        addresses = ["info@appvia.io"]
      }
    }

    networks = {
      "test-vpc" = {
        subnets = {
          private = {
            netmask = 24
          }
        }
        vpc = {
          availability_zones       = 2
          cidr                     = "10.0.0.0/16"
          nat_gateway_mode         = "none"
          enable_private_endpoints = ["s3", "dynamodb", "ec2"]
        }
      }
    }
  }

  # Test that network module is created
  assert {
    condition     = module.networks["test-vpc"] != null
    error_message = "Network module should be created for test-vpc with private endpoints"
  }
}

# Test 8: Network with transit gateway appliance mode
run "network_with_transit_gateway_appliance_mode" {
  variables {
    environment    = "Production"
    owner          = "Support"
    product        = "LandingZone"
    home_region    = "eu-west-2"
    tags           = {}
    git_repository = "test"

    notifications = {
      email = {
        addresses = ["info@appvia.io"]
      }
    }

    networks = {
      "test-vpc" = {
        subnets = {
          private = {
            netmask = 24
          }
        }
        vpc = {
          availability_zones                     = 2
          cidr                                   = "10.0.0.0/16"
          nat_gateway_mode                       = "none"
          enable_transit_gateway                 = true
          enable_transit_gateway_appliance_mode  = true
          enable_default_route_table_association = false
          enable_default_route_table_propagation = false
        }
        transit_gateway = {
          gateway_id = "tgw-1234567890"
          gateway_routes = {
            private = "10.0.0.0/8"
          }
        }
      }
    }
  }

  # Test that network module is created
  assert {
    condition     = module.networks["test-vpc"] != null
    error_message = "Network module should be created for test-vpc with transit gateway appliance mode"
  }
}

# Test 9: Multiple networks configuration
run "multiple_networks" {
  variables {
    environment    = "Production"
    owner          = "Support"
    product        = "LandingZone"
    home_region    = "eu-west-2"
    tags           = {}
    git_repository = "test"

    notifications = {
      email = {
        addresses = ["info@appvia.io"]
      }
    }

    networks = {
      "vpc-1" = {
        subnets = {
          private = {
            netmask = 24
          }
        }
        vpc = {
          availability_zones = 2
          cidr               = "10.0.0.0/16"
          nat_gateway_mode   = "none"
        }
      }
      "vpc-2" = {
        subnets = {
          private = {
            netmask = 24
          }
        }
        vpc = {
          availability_zones = 2
          cidr               = "10.1.0.0/16"
          nat_gateway_mode   = "none"
        }
        transit_gateway = {
          gateway_id = "tgw-1234567890"
          gateway_routes = {
            private = "10.0.0.0/8"
          }
        }
      }
    }
  }

  # Test that both network modules are created
  assert {
    condition     = module.networks["vpc-1"] != null
    error_message = "Network module should be created for vpc-1"
  }

  assert {
    condition     = module.networks["vpc-2"] != null
    error_message = "Network module should be created for vpc-2"
  }

  # Test that transit gateway association is created only for vpc-2
  assert {
    condition     = length(aws_ec2_transit_gateway_route_table_association.asssociation) == 0
    error_message = "Transit gateway association should not be created when no route table ID is specified"
  }
}

# Mock providers
mock_provider "aws" {}

mock_provider "aws" {
  alias  = "tenant"
  source = "./tests/providers/tenant"
}

mock_provider "aws" {
  alias  = "management"
  source = "./tests/providers/management"
}

mock_provider "aws" {
  alias  = "identity"
  source = "./tests/providers/identity"
}

mock_provider "aws" {
  alias  = "network"
  source = "./tests/providers/network"
}
