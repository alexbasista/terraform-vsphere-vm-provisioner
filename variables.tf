#################################################
# Data Sources (vCenter lookups)
#################################################
variable "datacenter" {
  type        = string
  description = "Name of the vCenter Datacenter to deploy VM(s) in."
}

variable "resource_pool" {
  type        = string
  description = "ESX Cluster Resource Pool that VM will be deployed to. Specify name of ESX Cluster to deploy VM(s) into 'root' Resource Pool of ESX Cluster."
}

variable "datastore_cluster" {
  type        = string
  description = "Datastore Cluster to deploy VM(s) on. Only specify if datastore is not specified."
  default     = ""
}

variable "datastore" {
  type        = string
  description = "Datastore to deploy VM(s) on. Only specify if datastore_cluster is not specified."
  default     = ""
}

variable "vm_template" {
  type        = string
  description = "Name of existing VM Template to deploy VM(s) from."
}

variable "vm_portgroup" {
  type        = string
  description = "Name of existing VM Port Group to use for the VM(s) Network Adapter."

}

variable "tags" {
  description = "Existing Tags to attach to VM(s)."
  type        = map(string)
  default     = null
}

#################################################
# VM Specifications Map (one or more unique VMs)
#################################################
# variable "vm_specs" {
#   type = map(object({
#     vm_name              = string
#     num_cpus             = string
#     num_cores_per_socket = string
#     memory               = string
#     ip_addr              = string
#     subnet_mask          = string
#     gateway              = string
#     additional_disks = map(object({
#       label            = string
#       size             = string
#       unit_number      = string
#       thin_provisioned = string
#       eagerly_scrub    = string
#       })
#     ) }
#   ))
# }

#################################################
# Global VM Settings
#################################################
variable "is_windows_image" {
  type        = bool
  description = "Boolean flag to notify when the custom image is windows based."
  default     = true
}

variable "vm_folder" {
  type        = string
  description = "vCenter Folder within specified ESX Cluster or Resource Pool to place VM(s) in."
  default     = null
}

variable "wait_for_guest_net_timeout" {
  type        = number
  description = "Amount of time (minutes) to wait for an available IP address on VM(s) NICs."
  default     = 5
}

variable "wait_for_guest_net_routable" {
  type        = bool
  description = "Controls whether or not the guest network waiter waits for a routable address."
  default     = true
}

variable "wait_for_guest_ip_timeout" {
  type        = number
  description = "Amount of time (minutes) to wait for an available guest IP address on VM(s)/"
  default     = 0
}

variable "custom_attributes" {
  type        = map
  description = "Map of custom attribute IDs to attribute values to set on VM(s)."
  default     = null
}

variable "extra_config" {
  type        = map
  description = "Extra configuration data for VM(s). Can be used to supply advanced parameters not normally in configuration, such as instance metadata.'disk.enableUUID', 'True'."
  default     = null
}

variable "annotation" {
  type        = string
  description = "A user-provided description of VM(s). The default is no annotation."
  default     = null
}

variable "clone_timeout" {
  type        = number
  description = "Timeout value (minutes) to wait for VM clone operation(s) to complete."
  default     = 30
}

variable "enable_disk_uuid" {
  type        = bool
  description = "Expose the UUIDs of attached virtual disks to the virtual machine, allowing access to them in the guest."
  default     = false
}

#################################################
# Global VM Customizations
#################################################
variable "dns_suffix_list" {
  description = "A list of DNS search domains to add to the DNS configuration on the virtual machine."
  type        = list(string)
  default     = null
}

#################################################
# Windows VM Customizations
#################################################
variable "dns_server_list" {
  type        = list(string)
  description = "List of DNS servers to add to VM(s)."
  default     = null
}

variable "admin_password" {
  type        = string
  description = "The administrator password for VM(s). (Required) when using join_windomain option"
  default     = null
}

variable "join_domain" {
  type        = string
  description = "The domain to join for this virtual machine. One of this or workgroup must be included."
  default     = null
}

variable "domain_admin_user" {
  type        = string
  description = "Domain admin user to join the server to AD.(Required) when using join_windomain option"
  default     = null
}

variable "domain_admin_password" {
  type        = string
  description = "Domain admin user password to join the VM(s) to AD. Required if join_domain option"
  default     = null
}

variable "auto_logon" {
  type        = bool
  description = "Specifies whether or not the VM automatically logs on as Administrator. Default: false"
  default     = true
}

variable "auto_logon_count" {
  type        = string
  description = "Specifies how many times the VM should auto-logon the Administrator account when auto_logon is true. This should be set accordingly to ensure that all of your commands that run in run_once_command_list can log in to run"
  default     = null
}

variable "time_zone" {
  type        = string
  description = "The new time zone for the virtual machine. This is a numeric, sysprep-dictated, timezone code."
  default     = null
}

variable "run_once_command_list" {
  type        = list(string)
  description = "List of Comamnd to run during first logon (Automatic login set to 1)"
  default     = []
}

variable "product_key" {
  type        = string
  description = "Product key for VM(s)."
  default     = null
}

variable "full_name" {
  type        = string
  description = "Full name of local admin user of VM(s)."
  default     = "Administrator"
}

