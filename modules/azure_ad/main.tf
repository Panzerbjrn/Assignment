# Azure AD Module - Test Groups and Users

locals {
  name_prefix = var.name_prefix
  instance_id = var.instance_id
  domain_name = var.domain_name
}


# Azure AD Groups


resource "azuread_group" "developers" {
  display_name     = join("-", [local.name_prefix, local.instance_id, "developers"])
  description      = "Developer group for ${local.name_prefix} - Contributor access"
  security_enabled = true
}

resource "azuread_group" "dba" {
  display_name     = join("-", [local.name_prefix, local.instance_id, "dba"])
  description      = "DBA group for ${local.name_prefix} - SQL Security Manager and Cosmos DB access"
  security_enabled = true
}

resource "azuread_group" "operations" {
  display_name     = join("-", [local.name_prefix, local.instance_id, "operations"])
  description      = "Operations group for ${local.name_prefix} - Monitoring and Website Contributor"
  security_enabled = true
}

resource "azuread_group" "auditors" {
  display_name     = join("-", [local.name_prefix, local.instance_id, "auditors"])
  description      = "Auditor group for ${local.name_prefix} - Read-only and Log Analytics access"
  security_enabled = true
}


# Azure AD Test Users


resource "azuread_user" "test_developer" {
  count               = var.create_test_users ? 1 : 0
  user_principal_name = "testdev-${var.environment}@${local.domain_name}"
  display_name        = "${local.name_prefix} Test Developer"
  mail_nickname       = "testdev-${var.environment}"
  password            = var.test_user_password
  department          = "Development"
  job_title           = "Developer"
}

resource "azuread_user" "test_dba" {
  count               = var.create_test_users ? 1 : 0
  user_principal_name = "testdba-${var.environment}@${local.domain_name}"
  display_name        = "${local.name_prefix} Test DBA"
  mail_nickname       = "testdba-${var.environment}"
  password            = var.test_user_password
  department          = "Database Administration"
  job_title           = "Database Administrator"
}

resource "azuread_user" "test_ops" {
  count               = var.create_test_users ? 1 : 0
  user_principal_name = "testops-${var.environment}@${local.domain_name}"
  display_name        = "${local.name_prefix} Test Operations"
  mail_nickname       = "testops-${var.environment}"
  password            = var.test_user_password
  department          = "Operations"
  job_title           = "Operations Engineer"
}

resource "azuread_user" "test_auditor" {
  count               = var.create_test_users ? 1 : 0
  user_principal_name = "testauditor-${var.environment}@${local.domain_name}"
  display_name        = "${local.name_prefix} Test Auditor"
  mail_nickname       = "testauditor-${var.environment}"
  password            = var.test_user_password
  department          = "Compliance"
  job_title           = "Auditor"
}


# Group Memberships


resource "azuread_group_member" "developer" {
  count            = var.create_test_users ? 1 : 0
  group_object_id  = azuread_group.developers.id
  member_object_id = azuread_user.test_developer[0].id
}

resource "azuread_group_member" "dba" {
  count            = var.create_test_users ? 1 : 0
  group_object_id  = azuread_group.dba.id
  member_object_id = azuread_user.test_dba[0].id
}

resource "azuread_group_member" "ops" {
  count            = var.create_test_users ? 1 : 0
  group_object_id  = azuread_group.operations.id
  member_object_id = azuread_user.test_ops[0].id
}

resource "azuread_group_member" "auditor" {
  count            = var.create_test_users ? 1 : 0
  group_object_id  = azuread_group.auditors.id
  member_object_id = azuread_user.test_auditor[0].id
}

