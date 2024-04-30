terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.89.0"
    }
  }
}

#import accounts
provider "snowflake" {
  account  = var.acount_name
  user     = var.acount_user
  password = var.acount_password
  role     = "ACCOUNTADMIN"
  alias    = "acc_admin"
}

provider "snowflake" {
  alias = "sys_admin"
  role  = "SYSADMIN"
  account  = var.acount_name
  user     = var.acount_user
  password = var.acount_password
}

provider "snowflake"  {
  alias = "security_admin"
  role  = "SECURITYADMIN"
  account  = var.acount_name
  user     = var.acount_user
  password = var.acount_password
}

provider "snowflake" {
  alias = "user_admin"
  role  = "USERADMIN"
  account  = var.acount_name
  user     = var.acount_user
  password = var.acount_password
}

#create warehouse
resource "snowflake_warehouse" "warehouse" {
  provider = snowflake.sys_admin
  name           = "POC_1_WH"
  comment        = "Warehouse dedicated for POC1"
  warehouse_size = "XSMALL"
  auto_suspend = 300
  auto_resume = true
  initially_suspended = true
}

#create database
resource "snowflake_database" "db_poc1" {
  provider = snowflake.sys_admin
  name     = "POC_1_DATABASE"
}

#create schema
resource "snowflake_schema" "schema_poc1" {
  provider   = snowflake.sys_admin
  database   = snowflake_database.db_poc1.name
  name       = "POC_1_SCHEMA"
  is_managed = true
}

#create all needed roles
resource "snowflake_role" "s_read_role" {
  provider = snowflake.acc_admin
  name     = "S_READ"
}

resource "snowflake_role" "s_write_role" {
  provider = snowflake.acc_admin
  name     = "S_WRITE"
}

resource "snowflake_role" "s_full_role" {
  provider = snowflake.acc_admin
  name     = "S_FULL"
}

resource "snowflake_role" "d_usage_role" {
  provider = snowflake.acc_admin
  name     = "D_USAGE"
}

resource "snowflake_role" "d_full_role" {
  provider = snowflake.acc_admin
  name     = "D_FULL"
}

resource "snowflake_role" "local_admin_role" {
  provider = snowflake.acc_admin
  name     = "LOCAL_ADMIN_ROLE"
}

#grant privileges to roles
resource "snowflake_grant_privileges_to_role" "s_read_grant" {
  provider = snowflake.security_admin
  privileges = ["USAGE"]
  role_name  = snowflake_role.s_read_role.name
  on_schema {
    schema_name = "\"${snowflake_database.db_poc1.name}\".\"${snowflake_schema.schema_poc1.name}\""
    }
}

resource "snowflake_grant_privileges_to_role" "s_read_select" {
  provider = snowflake.security_admin
  privileges = ["SELECT"]
  role_name  = snowflake_role.s_read_role.name
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "\"${snowflake_database.db_poc1.name}\".\"${snowflake_schema.schema_poc1.name}\""
    }
  }
}

resource "snowflake_grant_privileges_to_role" "s_read_select_on_future" {
  provider = snowflake.security_admin
  privileges = ["SELECT"]
  role_name  = snowflake_role.s_read_role.name
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "\"${snowflake_database.db_poc1.name}\".\"${snowflake_schema.schema_poc1.name}\""
    }
  }
}


resource "snowflake_grant_privileges_to_role" "s_write_grant" {
  provider = snowflake.security_admin
  privileges = ["MODIFY", "MONITOR", "USAGE", "CREATE TABLE", "CREATE EXTERNAL TABLE", "CREATE VIEW", "CREATE MATERIALIZED VIEW", "CREATE SEQUENCE", "CREATE FUNCTION", "CREATE PROCEDURE", "CREATE FILE FORMAT"]
  role_name  = snowflake_role.s_write_role.name
  on_schema {
    schema_name = "\"${snowflake_database.db_poc1.name}\".\"${snowflake_schema.schema_poc1.name}\""
    }
}

resource "snowflake_grant_privileges_to_role" "s_write_edit" {
  provider = snowflake.security_admin
  privileges = ["INSERT", "UPDATE", "DELETE"]
  role_name  = snowflake_role.s_write_role.name
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "\"${snowflake_database.db_poc1.name}\".\"${snowflake_schema.schema_poc1.name}\""
    }
  }
}

resource "snowflake_grant_privileges_to_role" "s_write_edit_on_future" {
  provider = snowflake.security_admin
  privileges = ["INSERT", "UPDATE", "DELETE"]
  role_name  = snowflake_role.s_write_role.name
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "\"${snowflake_database.db_poc1.name}\".\"${snowflake_schema.schema_poc1.name}\""
    }
  }
}

resource "snowflake_grant_privileges_to_role" "s_full_grant" {
  provider = snowflake.security_admin
  privileges = ["MODIFY", "MONITOR", "USAGE", "CREATE TABLE", "CREATE EXTERNAL TABLE", "CREATE VIEW", "CREATE MATERIALIZED VIEW", "CREATE MASKING POLICY", "CREATE SEQUENCE", "CREATE FUNCTION", "CREATE PROCEDURE", "CREATE FILE FORMAT", "CREATE STAGE", "CREATE PIPE", "CREATE STREAM", "CREATE TASK"]
  role_name  = snowflake_role.s_full_role.name
  on_schema {
    schema_name = "\"${snowflake_database.db_poc1.name}\".\"${snowflake_schema.schema_poc1.name}\""
    }
}

resource "snowflake_grant_privileges_to_role" "s_full_all" {
  provider = snowflake.security_admin
  all_privileges  = true
  role_name  = snowflake_role.s_full_role.name
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "\"${snowflake_database.db_poc1.name}\".\"${snowflake_schema.schema_poc1.name}\""
    }
  }
}


resource "snowflake_grant_privileges_to_role" "s_full_all_on_future" {
  provider = snowflake.security_admin
  all_privileges = true
  role_name  = snowflake_role.s_full_role.name
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "\"${snowflake_database.db_poc1.name}\".\"${snowflake_schema.schema_poc1.name}\""
    }
  }
}

resource "snowflake_grant_privileges_to_role" "d_usage_grant" {
  provider = snowflake.security_admin
  privileges = ["USAGE"]
  role_name  = snowflake_role.d_usage_role.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.db_poc1.name
  }
}

resource "snowflake_grant_privileges_to_role" "d_full_grant" {
  provider = snowflake.security_admin
  privileges = ["USAGE", "MODIFY", "MONITOR", "CREATE SCHEMA"]
  role_name  = snowflake_role.d_full_role.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.db_poc1.name
  }
}

resource "snowflake_warehouse_grant" "wh_grant" {
  provider = snowflake.security_admin
  warehouse_name = snowflake_warehouse.warehouse.name
  privilege      = "USAGE"
  roles = [snowflake_role.local_admin_role.name]
  with_grant_option = true
}

resource "snowflake_account_grant" "grant_create_role" {
  provider = snowflake.security_admin
  roles             = [snowflake_role.local_admin_role.name]
  privilege         = "CREATE ROLE"
  with_grant_option = false
}

resource "snowflake_account_grant" "grant_create_user" {
  provider = snowflake.security_admin
  roles             = [snowflake_role.local_admin_role.name]
  privilege         = "CREATE USER"
  with_grant_option = false
}

#grant ownership and create hierarchy
resource "snowflake_grant_ownership" "s_read_ownership" {
  provider = snowflake.security_admin
  account_role_name   = snowflake_role.s_full_role.name
  outbound_privileges = "COPY"
  on {
    object_type = "ROLE"
    object_name = snowflake_role.s_read_role.name
  }
}

resource "snowflake_grant_ownership" "s_write_ownership" {
  provider = snowflake.security_admin
  account_role_name   = snowflake_role.s_full_role.name
  outbound_privileges = "COPY"
  on {
    object_type = "ROLE"
    object_name = snowflake_role.s_write_role.name
  }
}

resource "snowflake_grant_ownership" "s_full_ownership" {
  provider = snowflake.security_admin
  account_role_name   = snowflake_role.d_full_role.name
  outbound_privileges = "COPY"
  on {
    object_type = "ROLE"
    object_name = snowflake_role.s_full_role.name
  }
}

resource "snowflake_grant_ownership" "d_usage_ownership" {
  provider = snowflake.security_admin
  account_role_name   = snowflake_role.d_full_role.name
  outbound_privileges = "COPY"
  on {
    object_type = "ROLE"
    object_name = snowflake_role.d_usage_role.name
  }
}

resource "snowflake_grant_ownership" "d_full_ownership" {
  provider = snowflake.security_admin
  account_role_name   = snowflake_role.local_admin_role.name
  outbound_privileges = "COPY"
  on {
    object_type = "ROLE"
    object_name = snowflake_role.d_full_role.name
  }
}


#grant roles to other roles
resource "snowflake_role_grants" "grant_s_read" {
  provider = snowflake.security_admin
  role_name = snowflake_role.s_read_role.name
  roles     = [snowflake_role.s_full_role.name]
}

resource "snowflake_role_grants" "grant_s_write" {
  provider = snowflake.security_admin
  role_name = snowflake_role.s_write_role.name
  roles     = [snowflake_role.s_full_role.name]
}

resource "snowflake_role_grants" "grant_s_full" {
  provider = snowflake.security_admin
  role_name = snowflake_role.s_full_role.name
  roles     = [snowflake_role.d_full_role.name]
}

resource "snowflake_role_grants" "grant_d_usage" {
  provider = snowflake.security_admin
  role_name = snowflake_role.d_usage_role.name
  roles     = [snowflake_role.d_full_role.name]
}

resource "snowflake_role_grants" "grant_d_full" {
  provider = snowflake.security_admin
  role_name = snowflake_role.d_full_role.name
  roles     = [snowflake_role.local_admin_role.name]
}

#grant local_admin role to sysadmin
resource "snowflake_role_grants" "grant_local_admin" {
  provider = snowflake.security_admin
  role_name = snowflake_role.local_admin_role.name
  roles     = ["SYSADMIN"]
}

#create admin_user
resource "snowflake_user" "ADMIN_USER" {
  provider = snowflake.user_admin
  name         = var.local_admin_name
  login_name   = var.local_admin_user
  password       = var.local_admin_password
  disabled     = false
  default_warehouse       = snowflake_warehouse.warehouse.name
  default_role            = snowflake_role.local_admin_role.name
}

#grant role to local_admin user
resource "snowflake_role_grants" "grant_admin_role_to_user" {
  provider = snowflake.security_admin
  role_name = snowflake_role.local_admin_role.name
  users = [
    snowflake_user.ADMIN_USER.name
  ]
}