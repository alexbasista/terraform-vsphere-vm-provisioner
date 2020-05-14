data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_datastore_cluster" "dsc" {
  count = var.datastore_cluster != "" ? 1 : 0

  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "ds" {
  count = var.datastore != "" && var.datastore_cluster == "" ? 1 : 0

  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "rp" {
  name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "pg" {
  name          = var.vm_portgroup
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vm_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_tag_category" "category" {
  count = var.tags != null ? length(var.tags) : 0

  name = keys(var.tags)[count.index]
}

data "vsphere_tag" "tag" {
  count = var.tags != null ? length(var.tags) : 0

  name        = var.tags[keys(var.tags)[count.index]]
  category_id = data.vsphere_tag_category.category[count.index].id
}

variable "vm_specs" {
  type = map(object({
    vm_name              = string
    num_cpus             = string
    num_cores_per_socket = string
    memory               = string
    ip_addr              = string
    subnet_mask          = string
    gateway              = string
    additional_disks = map(object({
      label = string
      size  = string
      #unit_number      = string
      thin_provisioned = string
      eagerly_scrub    = string
      })
    ) }
  ))
}

resource "vsphere_virtual_machine" "windows" {
  for_each = var.is_windows_image == true ? var.vm_specs : {}

  name              = each.value.vm_name
  resource_pool_id  = data.vsphere_resource_pool.rp.id
  folder            = var.vm_folder
  tags              = data.vsphere_tag.tag[*].id
  custom_attributes = var.custom_attributes
  annotation        = var.annotation
  extra_config      = var.extra_config

  datastore_cluster_id = var.datastore_cluster != "" ? data.vsphere_datastore_cluster.dsc[0].id : null
  datastore_id         = var.datastore != "" ? data.vsphere_datastore.ds[0].id : null

  num_cpus             = each.value.num_cpus
  num_cores_per_socket = each.value.num_cores_per_socket
  memory               = each.value.memory
  guest_id             = data.vsphere_virtual_machine.template.guest_id
  scsi_type            = data.vsphere_virtual_machine.template.scsi_type

  wait_for_guest_net_routable = var.wait_for_guest_net_routable
  wait_for_guest_ip_timeout   = var.wait_for_guest_ip_timeout
  wait_for_guest_net_timeout  = var.wait_for_guest_net_timeout

  network_interface {
    network_id   = data.vsphere_network.pg.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  # Disks defined in the source vm_template
  dynamic "disk" {
    for_each = data.vsphere_virtual_machine.template.disks
    iterator = template_disks

    content {
      label            = data.vsphere_virtual_machine.template.disks[template_disks.key].label
      size             = data.vsphere_virtual_machine.template.disks[template_disks.key].size
      unit_number      = data.vsphere_virtual_machine.template.disks[template_disks.key].unit_number
      thin_provisioned = data.vsphere_virtual_machine.template.disks[template_disks.key].thin_provisioned
      eagerly_scrub    = data.vsphere_virtual_machine.template.disks[template_disks.key].eagerly_scrub
    }
  }

  # Additional disks specified in additional_disks within vm_specs map (opitonal)
  dynamic "disk" {
    for_each = each.value.additional_disks == {} ? [] : flatten([for disk in each.value.additional_disks : [
      for k, v in disk : {
        label = disk.label
        size  = disk.size
        #unit_number = disk.unit_number
        thin_provisioned = disk.thin_provisioned
        eagerly_scrub    = disk.eagerly_scrub
      }
      ]
    ])

    iterator = additional_disk

    content {
      label = additional_disk.value.label
      size  = additional_disk.value.size
      #unit_number      = additional_disk.value.unit_number
      thin_provisioned = additional_disk.value.thin_provisioned
      eagerly_scrub    = additional_disk.value.eagerly_scrub
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    timeout       = var.clone_timeout

    customize {
      windows_options {
        computer_name         = each.value.vm_name
        admin_password        = var.admin_password
        join_domain           = var.join_domain
        domain_admin_user     = var.domain_admin_user
        domain_admin_password = var.domain_admin_password
        organization_name     = var.organization_name
        run_once_command_list = var.run_once
        auto_logon            = var.auto_logon
        auto_logon_count      = var.auto_logon_count
        time_zone             = var.time_zone
        product_key           = var.product_key
        full_name             = var.full_name
      }

      network_interface {
        ipv4_address = each.value.ip_addr
        ipv4_netmask = each.value.subnet_mask
      }

      dns_server_list = var.dns_server_list
      dns_suffix_list = var.dns_suffix_list
      ipv4_gateway    = each.value.gateway
    }
  }
}
