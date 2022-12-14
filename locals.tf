locals {
    managed_accounts = [ for account in var.organizations_accounts: {
            name      = account.name,
            email     = account.email,
            role_name = lookup(account, "role_name", "admin")
            tags = can(account.tags) ? account.tags : {}
        }]

    managed_accounts_configs = [ for account in var.organizations_accounts: {
            name      = account.name
        }]
        
    iam_groups = [ for group in var.groups : {
                        name = group.name
                        path = lookup(group, "path", "/")
                    }] 

    groups_policies = {for group in var.groups : group.name => {
                                        name    = group.name
                                        policy  = {
                                            for policy in try(group.policy_list, []):  
                                                "${policy.name}" => (can(policy.arn) ? policy.arn : module.iam_policies.policies[policy.name].arn)
                                                
                                        }}}

    all_groups_policies = flatten([for group_name, group in local.groups_policies: 
                                                [for policy_name, policy_arn in group.policy : 
                                                    { format("%s.%s", group_name, policy_name) = merge( {"group_name" = group_name}, 
                                                                                                    {"policy_arn" = policy_arn}) }]])


    trusted_account_roles = {for role_name, role in var.trusted_account_roles : role_name => {
                        name        = role.name
                        description = lookup(role, "description", role.name)
                        path        = lookup(role, "path", "/")
                        max_session_duration    = lookup(role, "max_session_duration", 3600)
                        force_detach_policies   = lookup(role, "force_detach_policies", false)
                        account_ids       = role.account_ids
                        tags = lookup(role, "tags", {})
                    }}

    trusted_account_roles_policies = {for role_name, role in var.trusted_account_roles : role.name => {
                                        name    = role.name
                                        policy  = {
                                            for policy in try(role.policy_list, []):  
                                                "${policy.name}" => (can(policy.arn) ? policy.arn : module.iam_policies.policies[policy.name].arn)                  
                                        }}}
    all_trusted_account_roles_policies = flatten([for role_name, role in local.trusted_account_roles_policies: 
                                                [for policy_name, policy_arn in role.policy : 
                                                    { format("%s.%s", role_name, policy_name) = merge( {"role_name" = role_name}, 
                                                                                                    {"policy_arn" = policy_arn}) }]])

    service_linked_roles = {for role_name, role in var.service_linked_roles : role.name => {
                        name        = role.name
                        description = lookup(role, "description", role.name)
                        path        = lookup(role, "path", "/")
                        max_session_duration    = lookup(role, "max_session_duration", 3600)
                        force_detach_policies   = lookup(role, "force_detach_policies", false)
                        service_names       = role.service_names
                        tags = lookup(role, "tags", {})
                    }}

    service_linked_roles_policies = {for role_name, role in var.service_linked_roles : role.name => {
                                        name    = role.name
                                        policy  = {
                                            for policy in try(role.policy_list, []):  
                                                "${policy.name}" => (can(policy.arn) ? policy.arn : module.iam_policies.policies[policy.name].arn)
                                                
                                        }}}

    all_service_linked_roles_policies = flatten([for role_name, role in local.service_linked_roles_policies: 
                                                [for policy_name, policy_arn in role.policy : 
                                                    { format("%s.%s", role_name, policy_name) = merge( {"role_name" = role_name}, 
                                                                                                    {"policy_arn" = policy_arn}) }]])


}