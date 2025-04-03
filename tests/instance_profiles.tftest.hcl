
override_module {
  target = module.notifications
  outputs = {
    sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:appvia-notifications"
  }
}

run "basic" {
  command = plan

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

    iam_instance_profiles = {
      ssm_instance = {
        name = "ssm_instance"
        path = "/"
        permission_arns = [
          "arn:aws:iam::aws:policy/service-role/AmazonSSMManagedInstanceCore",
          "arn:aws:iam::aws:policy/service-role/AmazonSSMFullAccess"
        ]
      }
    }
  }

  assert {
    condition     = aws_iam_role.instance_profiles["ssm_instance"].name == "ssm_instance"
    error_message = "The role should have the name ssm_instance"
  }

  assert {
    condition     = aws_iam_instance_profile.instance_profiles["ssm_instance"].role == "ssm_instance"
    error_message = "The instance profile should have the role ssm_instance"
  }

  assert {
    condition     = aws_iam_role_policy_attachment.instance_profiles["ssm_instance-arn:aws:iam::aws:policy/service-role/AmazonSSMManagedInstanceCore"] != null
    error_message = "The role policy attachment should exist"
  }

  assert {
    condition     = aws_iam_role_policy_attachment.instance_profiles["ssm_instance-arn:aws:iam::aws:policy/service-role/AmazonSSMManagedInstanceCore"].policy_arn == "arn:aws:iam::aws:policy/service-role/AmazonSSMManagedInstanceCore"
    error_message = "The role policy attachment should have the policy arn arn:aws:iam::aws:policy/service-role/AmazonSSMManagedInstanceCore"
  }

  assert {
    condition     = aws_iam_role_policy_attachment.instance_profiles["ssm_instance-arn:aws:iam::aws:policy/service-role/AmazonSSMFullAccess"] != null
    error_message = "The role policy attachment should exist"
  }

  assert {
    condition     = aws_iam_role_policy_attachment.instance_profiles["ssm_instance-arn:aws:iam::aws:policy/service-role/AmazonSSMFullAccess"].policy_arn == "arn:aws:iam::aws:policy/service-role/AmazonSSMFullAccess"
    error_message = "The role policy attachment should have the policy arn arn:aws:iam::aws:policy/service-role/AmazonSSMFullAccess"
  }

}

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
