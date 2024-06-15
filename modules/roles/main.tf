
locals {
  ## Is the name of the assumed role 
  assumed_role_name = data.aws_iam_session_context.current.issuer_name
  ## Is the name of the role we use to assume into the account to perform the landing zone configuraion 
  landing_zone_base_role_name = trimsuffix(local.assumed_role_name, "-ro")
  ## Indicates if we are using the read only role 
  landing_zone_read_only = endswith(local.assumed_role_name, "-ro")
  ## The suffix to add to the role name to indicate it is a read only role 
  landing_zone_role_suffix = local.landing_zone_read_only ? "-ro" : ""
  ## Is the name of the role we use to assume into the identity account to perform any role assignments 
  identity_role_name = format("%s-cross%s", local.landing_zone_base_role_name, local.landing_zone_role_suffix)
  ## Is the naem of the role we use to assume into the network account to perform any network related configuration
  network_role_name = format("%s-cross%s", local.landing_zone_base_role_name, local.landing_zone_role_suffix)
}
