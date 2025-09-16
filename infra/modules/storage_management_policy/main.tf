terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.42.0"
    }
  }
}

resource "azurerm_storage_management_policy" "mgmt_policy" {
  storage_account_id = var.storage_account_id

  dynamic "rule" {
    for_each = var.management_policy_rules

    content {
      name    = rule.value.name
      enabled = rule.value.enabled

      filters {
        prefix_match = rule.value.filters.prefix_match
        blob_types   = rule.value.filters.blob_types

        dynamic "match_blob_index_tag" {
          for_each = rule.value.filters.match_blob_index_tags != null ? rule.value.filters.match_blob_index_tags : []
          content {
            name      = match_blob_index_tag.value.name
            operation = match_blob_index_tag.value.operation
            value     = match_blob_index_tag.value.value
          }
        }
      }

      actions {
        base_blob {
          tier_to_cool_after_days_since_modification_greater_than    = try(rule.value.actions.base_blob.tier_to_cool_after_days_since_modification_greater_than, null)
          tier_to_archive_after_days_since_modification_greater_than = try(rule.value.actions.base_blob.tier_to_archive_after_days_since_modification_greater_than, null)
          delete_after_days_since_modification_greater_than          = try(rule.value.actions.base_blob.delete_after_days_since_modification_greater_than, null)
        }
        snapshot {
          change_tier_to_archive_after_days_since_creation = try(rule.value.actions.snapshot.change_tier_to_archive_after_days_since_creation, null)
          change_tier_to_cool_after_days_since_creation    = try(rule.value.actions.snapshot.change_tier_to_cool_after_days_since_creation, null)
          delete_after_days_since_creation_greater_than    = try(rule.value.actions.snapshot.delete_after_days_since_creation_greater_than, null)
        }
        version {
          change_tier_to_archive_after_days_since_creation = try(rule.value.actions.version.change_tier_to_archive_after_days_since_creation, null)
          change_tier_to_cool_after_days_since_creation    = try(rule.value.actions.version.change_tier_to_cool_after_days_since_creation, null)
          delete_after_days_since_creation                 = try(rule.value.actions.version.delete_after_days_since_creation, null)
        }
      }
    }
  }
}
