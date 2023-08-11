locals {
    autoclass = {
        enabled = true
    }

    lifecycle_rule = {
        action = {
          type          = "SetStorageClass" 
          storage_class = "Nearline storage"
        }
        condition = {
          age                   = 18
          created_before        = "2025-10-02"
          custom_time_before    = "2025-10-02"
          matches_prefix        = ["test", "qual"]
          matches_storage_class = ["STANDARD", "NEARLINE"]
          num_newer_versions    = 0
        }
    }

    versioning = {
      enabled = true
    }

    website = {
      main_page_suffix = "test"
      not_found_page   = "/error-page.fr"
    }

    cors = {
      origin          = ["http://my-origin-example.com"]
      method          = ["GET", "POST"]
      response_header = ["*"]
      max_age_seconds = 18
    }

    retention_policy = {
      is_locked        = false
      retention_period = 10
    }

    labels = {
      "label1" = "test-label1",
      "label2" = "test-label2"
    }

    logging = {
      log_bucket        = "another-bucket"
      log_object_prefix = "log"
    }

    encryption = {
      default_kms_key_name = "myawesomekey123"
    }

    custom_placement_config = {
      data_locations = ["europe-west9", "europe-west5"]
    }

    roles = {
      "roles/storage.objectCreator" = ["user:jane@example.com", "user:jane2@example.com"],
      "roles/storage.admin"         = ["user:jane@example.com"]
    }

    role_entity = ["OWNER:user-my.email@gmail.com","READER:group-mygroup"]
}


module "complex_bucket_example" {
    source                      = "../../../bucket"
    bucket_name                 = "my-awesome-bucket-132456789"
    force_destroy               = false 
    storage_class               = "STANDARD"
    autoclass                   = local.autoclass
    lifecycle_rule              = local.lifecycle_rule
    versioning                  = local.versioning
    website                     = local.website
    cors                        = local.cors
    default_event_based_hold    = false
    retention_policy            = local.retention_policy
    labels                      = local.labels
    logging                     = local.logging
    requester_pays              = false
    encryption                  = local.encryption
    uniform_bucket_level_access = false
    public_access_prevention    = "inherited"
    custom_placement_config     = local.custom_placement_config
    role_entity                 = local.role_entity
    roles                       = local.roles
    location                    = "europe-west9"
}