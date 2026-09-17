##############################################################################
# PowerVS LPAR Module - Variables
#
# The provider block is owned by the caller, and must be configured with
# the region/zone of the workspace identified by pi_cloud_instance_id. This
# module only declares the ibm provider requirement in versions.tf.
##############################################################################

variable "pi_cloud_instance_id" {
  description = "GUID of the PowerVS workspace to deploy the LPAR into (the workspace_guid output of the powervs-workspace module)."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.pi_cloud_instance_id))
    error_message = "pi_cloud_instance_id must be a UUID (the workspace GUID), not a workspace name or CRN."
  }
}

variable "name" {
  description = "Name of the LPAR (Power Systems Virtual Server instance). Must be 1-47 characters, lowercase letters, digits and hyphens only, and cannot start or end with a hyphen."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,45}[a-z0-9])?$", var.name))
    error_message = "name must be 1-47 characters, lowercase letters/digits/hyphens only, and cannot start or end with a hyphen."
  }
}

variable "os_type" {
  description = "Operating system family of the image being deployed. Purely descriptive except for the pi_ibmi_* variables below, which only apply when os_type is \"ibmi\"."
  type        = string

  validation {
    condition     = contains(["aix", "ibmi", "linux"], var.os_type)
    error_message = "os_type must be one of: aix, ibmi, linux."
  }
}

variable "image_id" {
  description = "ID of the boot image to deploy (a stock image or one already imported/captured into this workspace's catalog). Look this up with the ibm_pi_image or ibm_pi_catalog_images data source; the module does not resolve names to IDs."
  type        = string

  validation {
    condition     = length(var.image_id) > 0
    error_message = "image_id must not be empty."
  }
}

variable "sys_type" {
  description = "Host system type to place the LPAR on (e.g. s922, e980, s1022). See IBM Cloud docs for the system types available in the target zone."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]*$", var.sys_type))
    error_message = "sys_type must be a lowercase alphanumeric system type code (e.g. s922, e980, s1022)."
  }
}

variable "processors" {
  description = "Number of vCPUs (processor units) assigned to the LPAR, visible to the guest OS. Fractional values are allowed for shared/capped processor types (e.g. 0.25, 0.5, 1)."
  type        = number

  validation {
    condition     = var.processors > 0
    error_message = "processors must be greater than 0."
  }
}

variable "proc_type" {
  description = "Processor mode for the LPAR."
  type        = string
  default     = "shared"

  validation {
    condition     = contains(["shared", "capped", "dedicated"], var.proc_type)
    error_message = "proc_type must be one of: shared, capped, dedicated."
  }
}

variable "memory" {
  description = "Memory assigned to the LPAR, in GiB."
  type        = number

  validation {
    condition     = var.memory > 0
    error_message = "memory must be greater than 0."
  }
}

variable "storage_type" {
  description = "Storage tier for the boot volume and any data volumes that don't set their own tier. Leave null to let the platform default (currently tier3)."
  type        = string
  default     = null

  validation {
    condition     = var.storage_type == null || contains(["tier0", "tier1", "tier3", "tier5k"], var.storage_type)
    error_message = "storage_type must be one of: tier0, tier1, tier3, tier5k, or null to use the platform default."
  }
}

variable "boot_volume_replication_enabled" {
  description = "Whether the boot volume should be replication-enabled."
  type        = bool
  default     = false
}

variable "pin_policy" {
  description = "Pinning policy for the LPAR against its physical host."
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "soft", "hard"], var.pin_policy)
    error_message = "pin_policy must be one of: none, soft, hard."
  }
}

variable "key_pair_name" {
  description = "Name of an SSH key already registered in the workspace (e.g. the ssh_key_name used with the powervs-workspace module) to grant access to the LPAR. Leave null to deploy without one (not recommended)."
  type        = string
  default     = null
}

variable "networks" {
  description = <<-EOT
    Networks to attach to the LPAR. Each entry references a subnet
    (network) ID already created in the workspace, e.g. one of the
    values in the powervs-workspace module's subnet_ids output.

    - network_id: ID of the subnet/network to attach.
    - ip_address: optional static IP to request on that subnet; leave
      null to let the platform assign one from the subnet's pool.
  EOT
  type = list(object({
    network_id = string
    ip_address = optional(string)
  }))

  validation {
    condition     = length(var.networks) > 0
    error_message = "At least one network must be attached to the LPAR."
  }
}

variable "volumes" {
  description = <<-EOT
    Additional data volumes to create and attach to the LPAR, beyond the
    boot volume that comes from the image. Each volume is created with
    ibm_pi_volume and attached with ibm_pi_volume_attach.

    - name:      volume name, unique within the list.
    - size:      volume size in GiB.
    - tier:      storage tier for this volume; defaults to var.storage_type when null.
    - shareable: whether the volume can be attached to more than one LPAR.
  EOT
  type = list(object({
    name      = string
    size      = number
    tier      = optional(string)
    shareable = optional(bool, false)
  }))
  default = []

  validation {
    condition     = length(var.volumes) == length(distinct([for v in var.volumes : v.name]))
    error_message = "volume names must be unique within the volumes list."
  }

  validation {
    condition     = alltrue([for v in var.volumes : v.size > 0])
    error_message = "each volume's size must be greater than 0 GiB."
  }

  validation {
    condition     = alltrue([for v in var.volumes : v.tier == null || contains(["tier0", "tier1", "tier3", "tier5k"], v.tier)])
    error_message = "each volume's tier must be one of: tier0, tier1, tier3, tier5k, or null."
  }
}

variable "user_data" {
  description = "cloud-init user data to pass to the instance during creation (plain text or base64). Leave null for none."
  type        = string
  default     = null
  sensitive   = true
}

variable "health_status" {
  description = "Health status Terraform polls for before considering the LPAR create/update complete."
  type        = string
  default     = "OK"

  validation {
    condition     = contains(["OK", "WARNING"], var.health_status)
    error_message = "health_status must be either OK or WARNING."
  }
}

variable "user_tags" {
  description = "User tags attached to the LPAR resource."
  type        = list(string)
  default     = []
}

##############################################################################
# IBM i specific licensing (ignored for os_type = "aix" or "linux")
##############################################################################

variable "ibmi_css" {
  description = "IBM i Cloud Storage Solution license flag. Only meaningful when os_type is \"ibmi\"."
  type        = bool
  default     = false

  validation {
    condition     = var.ibmi_css == false || var.os_type == "ibmi"
    error_message = "ibmi_css can only be set to true when os_type is \"ibmi\"."
  }
}

variable "ibmi_pha" {
  description = "IBM i Power High Availability license flag. Only meaningful when os_type is \"ibmi\"."
  type        = bool
  default     = false

  validation {
    condition     = var.ibmi_pha == false || var.os_type == "ibmi"
    error_message = "ibmi_pha can only be set to true when os_type is \"ibmi\"."
  }
}

variable "ibmi_rds_users" {
  description = "Number of IBM i Rational Dev Studio user licenses. Only meaningful when os_type is \"ibmi\"."
  type        = number
  default     = 0

  validation {
    condition     = var.ibmi_rds_users >= 0
    error_message = "ibmi_rds_users must be 0 or greater."
  }

  validation {
    condition     = var.ibmi_rds_users == 0 || var.os_type == "ibmi"
    error_message = "ibmi_rds_users can only be set when os_type is \"ibmi\"."
  }
}
