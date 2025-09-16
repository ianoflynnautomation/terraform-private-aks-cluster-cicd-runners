variable "storage_account_id" {
  description = "(Required) Specifies the ID of the storage account to which the management policy should be applied."
  type        = string

}

variable "management_policy_rules" {
  description = "(Required) Specifies the management policy rules."
  type = list(object({
    name    = string
    enabled = bool
    filters = object({
      prefix_match = list(string)
      blob_types   = list(string)
      match_blob_index_tags = optional(list(object({
        name      = string
        operation = string
        value     = string
      })))
    })
    actions = optional(object({
      base_blob = optional(object({
        tier_to_cool_after_days_since_modification_greater_than    = optional(number)
        tier_to_archive_after_days_since_modification_greater_than = optional(number)
        delete_after_days_since_modification_greater_than          = optional(number)
      }))
      snapshot = optional(object({
        change_tier_to_archive_after_days_since_creation = optional(number)
        change_tier_to_cool_after_days_since_creation    = optional(number)
        delete_after_days_since_creation_greater_than    = optional(number)
      }))
      version = optional(object({
        change_tier_to_archive_after_days_since_creation = optional(number)
        change_tier_to_cool_after_days_since_creation    = optional(number)
        delete_after_days_since_creation                 = optional(number)
      }))
    }))
  }))
}
