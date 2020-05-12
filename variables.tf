variable "dc" {
  type        = string
  description = "Name of the datacenter you want to deploy the VM to"
}

variable "vm_rp" {
  type        = string
  description = "Cluster resource pool that VM will be deployed to. you use following to choose default pool in the cluster (esxi1) or (Cluster)/Resources"
}

#variable "vm_specs" {
#    type = map(
#        object(
#            {
#                vm_name              = string
#                num_cpus             = string
#                num_cores_per_socket = string
#                memory               = string
#                ip_addr              = string
#                subnet_mask          = string
#                gateway              = string
#            }
#        )
#    )
#}

variable "ram_size" {
  description = "VM RAM size in megabytes"
  default     = 4096
}


variable "vm_template" {
  type        = string
  description = "Name of the template available in the vSphere"
}


variable "vm_portgroup" {
  description = ""
  type        = string
}

variable "ds_cluster" {
  type        = string
  description = "Datastore cluster to deploy the VM."
  default     = ""
}

variable "datastore" {
  type        = string
  description = "Datastore to deploy the VM."
  default     = ""
}

variable "vm_folder" {
  description = "The path to the folder to put this virtual machine in, relative to the datacenter that the resource pool is in."
  default     = null
}

variable "vm_dns" {
  type    = list(string)
  default = null
}

#Global Customization Variables
variable "tags" {
  description = "The names of any tags to attach to this resource. They shoud already exist"
  type        = map
  default     = null
}

variable "custom_attributes" {
  description = "Map of custom attribute ids to attribute value strings to set for virtual machine."
  type        = map
  default     = null
}

variable "extra_config" {
  description = "Extra configuration data for this virtual machine. Can be used to supply advanced parameters not normally in configuration, such as instance metadata.'disk.enableUUID', 'True'"
  type        = map
  default     = null
}

variable "annotation" {
  description = "A user-provided description of the virtual machine. The default is no annotation."
  default     = null
}

variable "clone_timeout" {
  description = "The timeout, in minutes, to wait for the virtual machine clone to complete."
  type        = number
  default     = 30
}

variable "dns_suffix_list" {
  description = "A list of DNS search domains to add to the DNS configuration on the virtual machine."
  type        = list(string)
  default     = null
}

#variable "data_disk_size_gb" {
#  description = "Storage data disk size size"
#  type        = list
#  default     = []
#}

variable "thin_provisioned" {
  description = "If true, this disk is thin provisioned, with space for the file being allocated on an as-needed basis."
  type        = list
  default     = null
}

variable "eagerly_scrub" {
  description = "if set to true, the disk space is zeroed out on VM creation. This will delay the creation of the disk or virtual machine. Cannot be set to true when thin_provisioned is true."
  type        = list
  default     = null
}

variable "enable_disk_uuid" {
  description = "Expose the UUIDs of attached virtual disks to the virtual machine, allowing access to them in the guest."
  default     = null
}

# Windows Customization Variables
variable "is_windows_image" {
  type        = bool
  description = "Boolean flag to notify when the custom image is windows based."
  default     = true
}

variable "local_adminpass" {
  type        = string
  description = "The administrator password for this virtual machine.(Required) when using join_windomain option"
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
  description = "Doamin User pssword to join the server to AD.(Required) when using join_windomain option"
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

variable "run_once" {
  type        = list(string)
  description = "List of Comamnd to run during first logon (Automatic login set to 1)"
  default     = null
}

variable "wait_for_guest_net_routable" {
  type        = bool
  description = "Controls whether or not the guest network waiter waits for a routable address. When false, the waiter does not wait for a default gateway, nor are IP addresses checked against any discovered default gateways as part of its success criteria. This property is ignored if the wait_for_guest_ip_timeout waiter is used."
  default     = true
}

variable "wait_for_guest_ip_timeout" {
  type        = number
  description = "The amount of time, in minutes, to wait for an available guest IP address on this virtual machine. This should only be used if your version of VMware Tools does not allow the wait_for_guest_net_timeout waiter to be used. A value less than 1 disables the waiter."
  default     = 0
}

variable "wait_for_guest_net_timeout" {
  type        = number
  description = "The amount of time, in minutes, to wait for an available IP address on this virtual machine's NICs. Older versions of VMware Tools do not populate this property. In those cases, this waiter can be disabled and the wait_for_guest_ip_timeout waiter can be used instead. A value less than 1 disables the waiter."
  default     = 5
}
